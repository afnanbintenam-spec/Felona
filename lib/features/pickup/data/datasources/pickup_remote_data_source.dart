import 'package:dio/dio.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/pickup/data/models/pickup_model.dart';

/// Remote data source for pickup operations.
abstract class PickupRemoteDataSource {
  Future<List<PickupModel>> getPickups();

  Future<PickupModel> createPickup({
    required WasteCategory category,
    required double estimatedWeight,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? scheduledDate,
    PickupTimeSlot? timeSlot,
    bool isRecurring,
    RecurrenceFrequency? recurrenceFrequency,
    int? recurrenceDayOfWeek,
  });

  Future<PickupModel> getPickupById(String pickupId);
  Future<PickupModel> acceptPickup(String pickupId);
  Future<PickupModel> updatePickupStatus(String pickupId, PickupStatus status);
  Future<PickupModel> completePickup(String pickupId);
  Future<List<PickupModel>> getAvailablePickups();
  Future<List<PickupModel>> getMyPickupHistory({int page, int limit});
  Future<PickupModel> ratePickup({
    required String pickupId,
    required double rating,
    String? feedback,
  });
  Future<PickupModel> verifyPickupQr({
    required String pickupId,
    required String qrToken,
  });
  Future<PickupModel> getPickupTracking(String pickupId);
  Future<void> cancelRecurringSchedule(String scheduleId);
}

class PickupRemoteDataSourceImpl implements PickupRemoteDataSource {
  final ApiClient _apiClient;

  static const String _pickupsPath = '/pickups';

  PickupRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<PickupModel>> getPickups() async {
    try {
      final response = await _apiClient.get(_pickupsPath);

      final pickups = (response.data['pickups'] as List<dynamic>)
          .map((json) => PickupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return pickups;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> createPickup({
    required WasteCategory category,
    required double estimatedWeight,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? scheduledDate,
    PickupTimeSlot? timeSlot,
    bool isRecurring = false,
    RecurrenceFrequency? recurrenceFrequency,
    int? recurrenceDayOfWeek,
  }) async {
    try {
      final data = <String, dynamic>{
        'category': category.name,
        'estimated_weight': estimatedWeight,
        'address': address,
        'notes': notes,
      };

      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (scheduledDate != null) {
        data['scheduled_date'] = scheduledDate.toIso8601String();
      }
      if (timeSlot != null) data['time_slot'] = timeSlot.apiValue;
      if (isRecurring) {
        data['is_recurring'] = true;
        if (recurrenceFrequency != null) {
          data['recurrence_frequency'] = recurrenceFrequency.name;
        }
        if (recurrenceDayOfWeek != null) {
          data['recurrence_day'] = recurrenceDayOfWeek;
        }
      }

      final response = await _apiClient.post(_pickupsPath, data: data);
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> getPickupById(String pickupId) async {
    try {
      final response = await _apiClient.get('$_pickupsPath/$pickupId');
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> acceptPickup(String pickupId) async {
    try {
      final response = await _apiClient.post('$_pickupsPath/$pickupId/accept');
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> updatePickupStatus(
      String pickupId, PickupStatus status) async {
    try {
      final statusStr = _statusToApiString(status);
      final response = await _apiClient.patch(
        '$_pickupsPath/$pickupId/status',
        data: {'status': statusStr},
      );
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> completePickup(String pickupId) async {
    try {
      final response =
          await _apiClient.post('$_pickupsPath/$pickupId/complete');
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PickupModel>> getAvailablePickups() async {
    try {
      final response = await _apiClient.get('$_pickupsPath/available');

      final pickups = (response.data['pickups'] as List<dynamic>)
          .map((json) => PickupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return pickups;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PickupModel>> getMyPickupHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '$_pickupsPath/history',
        queryParameters: {'page': page, 'limit': limit},
      );

      final pickups = (response.data['pickups'] as List<dynamic>)
          .map((json) => PickupModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return pickups;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> ratePickup({
    required String pickupId,
    required double rating,
    String? feedback,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_pickupsPath/$pickupId/rate',
        data: {
          'rating': rating,
          if (feedback != null) 'feedback': feedback,
        },
      );
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> verifyPickupQr({
    required String pickupId,
    required String qrToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_pickupsPath/$pickupId/verify-qr',
        data: {'qr_token': qrToken},
      );
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PickupModel> getPickupTracking(String pickupId) async {
    try {
      final response =
          await _apiClient.get('$_pickupsPath/$pickupId/tracking');
      return PickupModel.fromJson(
          response.data['pickup'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> cancelRecurringSchedule(String scheduleId) async {
    try {
      await _apiClient.delete('$_pickupsPath/recurring/$scheduleId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _statusToApiString(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return 'pending';
      case PickupStatus.assigned:
        return 'assigned';
      case PickupStatus.accepted:
        return 'accepted';
      case PickupStatus.onTheWay:
        return 'on_the_way';
      case PickupStatus.arrived:
        return 'arrived';
      case PickupStatus.completed:
        return 'completed';
      case PickupStatus.cancelled:
        return 'cancelled';
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
