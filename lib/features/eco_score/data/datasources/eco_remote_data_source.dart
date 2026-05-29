import 'package:dio/dio.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/eco_score/data/models/eco_stats_model.dart';

/// Remote data source for eco score operations.
abstract class EcoRemoteDataSource {
  Future<EcoStatsModel> getEcoStats();
  Future<List<PointHistoryModel>> getPointHistory({int page, int limit});
  Future<EcoStatsModel> addPoints({required int points, required String reason, String? relatedId});
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit});
}

class EcoRemoteDataSourceImpl implements EcoRemoteDataSource {
  final ApiClient _apiClient;

  static const String _ecoPath = '/eco';

  EcoRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<EcoStatsModel> getEcoStats() async {
    try {
      final response = await _apiClient.get('$_ecoPath/stats');
      return EcoStatsModel.fromJson(response.data['stats'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PointHistoryModel>> getPointHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '$_ecoPath/history',
        queryParameters: {'page': page, 'limit': limit},
      );

      final history = (response.data['history'] as List<dynamic>)
          .map((json) => PointHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return history;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<EcoStatsModel> addPoints({
    required int points,
    required String reason,
    String? relatedId,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_ecoPath/points',
        data: {
          'points': points,
          'reason': reason,
          'related_id': relatedId,
        },
      );
      return EcoStatsModel.fromJson(response.data['stats'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '$_ecoPath/leaderboard',
        queryParameters: {'limit': limit},
      );
      return (response.data['leaderboard'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
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
