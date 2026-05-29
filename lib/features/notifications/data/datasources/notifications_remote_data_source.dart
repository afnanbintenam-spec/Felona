import 'package:dio/dio.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/notifications/data/models/notification_model.dart';

/// Remote data source for notification operations.
abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> registerFcmToken(String token);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  static const String _notificationsPath = '/notifications';

  NotificationsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(_notificationsPath);

      final notifications = (response.data['notifications'] as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return notifications;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch('$_notificationsPath/$notificationId/read');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('$_notificationsPath/read-all');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('$_notificationsPath/$notificationId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> registerFcmToken(String token) async {
    try {
      await _apiClient.post(
        '$_notificationsPath/fcm-token',
        data: {'token': token},
      );
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
