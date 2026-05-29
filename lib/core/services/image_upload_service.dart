import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Service for handling image uploads across the app.
///
/// Supports:
/// - Profile picture upload
/// - Listing image upload
/// - Waste scan image upload
class ImageUploadService {
  final ApiClient _apiClient;
  final ImagePicker _picker = ImagePicker();

  ImageUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Pick an image from gallery.
  Future<XFile?> pickFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: imageQuality,
    );
  }

  /// Pick an image from camera.
  Future<XFile?> pickFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: imageQuality,
    );
  }

  /// Pick multiple images from gallery.
  Future<List<XFile>> pickMultipleImages({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    return await _picker.pickMultiImage(
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: imageQuality,
    );
  }

  /// Upload a profile picture.
  ///
  /// Returns the URL of the uploaded image.
  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.uploadMultipart(
      '/auth/profile/$userId/picture',
      formData,
    );

    return response.data['profile_picture_url'] as String;
  }

  /// Upload a listing image.
  ///
  /// Returns the URL of the uploaded image.
  Future<String> uploadListingImage({required String filePath}) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.uploadMultipart(
      '/uploads/listing-image',
      formData,
    );

    return response.data['url'] as String;
  }

  /// Upload multiple listing images.
  ///
  /// Returns a list of uploaded image URLs.
  Future<List<String>> uploadListingImages({required List<String> filePaths}) async {
    final urls = <String>[];

    for (final path in filePaths) {
      try {
        final url = await uploadListingImage(filePath: path);
        urls.add(url);
      } catch (e) {
        debugPrint('[ImageUpload] Failed to upload $path: $e');
        // Continue uploading remaining images
      }
    }

    return urls;
  }

  /// Upload image bytes (for web or in-memory images).
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String filename,
    required String uploadPath,
    String fieldName = 'image',
  }) async {
    final formData = FormData.fromMap({
      fieldName: MultipartFile.fromBytes(bytes, filename: filename),
    });

    final response = await _apiClient.uploadMultipart(uploadPath, formData);
    return response.data['url'] as String;
  }
}
