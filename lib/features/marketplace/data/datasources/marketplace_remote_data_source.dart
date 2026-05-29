import 'dart:io';

import 'package:dio/dio.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/marketplace/data/models/listing_model.dart';

/// Remote data source for marketplace operations.
abstract class MarketplaceRemoteDataSource {
  Future<List<ListingModel>> getListings({int page, int limit});
  Future<List<ListingModel>> getListingsByCategory(ListingCategory category);
  Future<List<ListingModel>> searchListings(String query);
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required double price,
    required ListingCategory category,
    required List<String> imagePaths,
    String? location,
  });
  Future<List<ListingModel>> getMyListings();
  Future<void> toggleFavorite(String listingId);
  Future<ListingModel> getListingById(String id);
  Future<void> deleteListing(String id);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _apiClient;

  static const String _listingsPath = '/listings';

  MarketplaceRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ListingModel>> getListings({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        _listingsPath,
        queryParameters: {'page': page, 'limit': limit},
      );

      final listings = (response.data['listings'] as List<dynamic>)
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return listings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ListingModel>> getListingsByCategory(ListingCategory category) async {
    try {
      final response = await _apiClient.get(
        _listingsPath,
        queryParameters: {'category': category.name},
      );

      final listings = (response.data['listings'] as List<dynamic>)
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return listings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      final response = await _apiClient.get(
        '$_listingsPath/search',
        queryParameters: {'q': query},
      );

      final listings = (response.data['listings'] as List<dynamic>)
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return listings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required double price,
    required ListingCategory category,
    required List<String> imagePaths,
    String? location,
  }) async {
    try {
      // Upload images first
      final imageUrls = <String>[];
      for (final path in imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          final fileName = path.split(Platform.pathSeparator).last;
          final formData = FormData.fromMap({
            'image': await MultipartFile.fromFile(path, filename: fileName),
          });
          final uploadResponse = await _apiClient.uploadMultipart(
            '/uploads/listing-image',
            formData,
          );
          final url = uploadResponse.data['url'] as String?;
          if (url != null) imageUrls.add(url);
        }
      }

      // Create listing with uploaded image URLs
      final response = await _apiClient.post(
        _listingsPath,
        data: {
          'title': title,
          'description': description,
          'price': price,
          'category': category.name,
          'image_urls': imageUrls.isNotEmpty ? imageUrls : imagePaths,
          'location': location,
        },
      );

      return ListingModel.fromJson(response.data['listing'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ListingModel>> getMyListings() async {
    try {
      final response = await _apiClient.get('$_listingsPath/my');

      final listings = (response.data['listings'] as List<dynamic>)
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return listings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> toggleFavorite(String listingId) async {
    try {
      await _apiClient.post('$_listingsPath/$listingId/favorite');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ListingModel> getListingById(String id) async {
    try {
      final response = await _apiClient.get('$_listingsPath/$id');
      return ListingModel.fromJson(response.data['listing'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _apiClient.delete('$_listingsPath/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return ServerException(
      e.message ?? 'An unexpected error occurred.',
      e.response?.statusCode,
    );
  }
}
