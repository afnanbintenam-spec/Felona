import 'dart:typed_data';
import 'package:dio/dio.dart' show FormData, MultipartFile, DioException;
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/services/gemini_service.dart';
import 'package:felo_na/features/ai/data/models/scan_result_model.dart';

/// Remote data source for AI features.
///
/// - Waste scanning hits the backend `/ai/scan` endpoint, which runs
///   the model server-side and persists eco points.
/// - Chat uses the [GeminiService] Gemini SDK directly (no backend round-trip
///   needed for conversational messages).
abstract class AiRemoteDataSource {
  Future<ScanResultModel> scanWaste(Uint8List imageBytes);
  Future<String> chat(String message);
  void resetChat();
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final ApiClient _apiClient;
  final GeminiService _geminiService;

  AiRemoteDataSourceImpl({
    required ApiClient apiClient,
    required GeminiService geminiService,
  })  : _apiClient = apiClient,
        _geminiService = geminiService;

  @override
  Future<ScanResultModel> scanWaste(Uint8List imageBytes) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: 'scan.jpg'),
      });

      final response = await _apiClient.uploadMultipart('/ai/scan', formData);

      return ScanResultModel.fromJson(
          response.data['scan'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?.toString() ??
          'AI scan failed. Please try again.';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException('Unexpected error during scan: $e');
    }
  }

  @override
  Future<String> chat(String message) async {
    try {
      return await _geminiService.chat(message);
    } catch (e) {
      throw ServerException('Chat unavailable. Please check your connection.');
    }
  }

  @override
  void resetChat() => _geminiService.resetChat();
}
