import 'package:dio/dio.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/messaging/data/models/conversation_model.dart';
import 'package:felo_na/features/messaging/data/models/message_model.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String sellerId,
  });
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<void> markAsRead(String conversationId);
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final ApiClient _apiClient;

  static const String _basePath = '/conversations';

  MessagingRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.get(_basePath);
      final list = (response.data['conversations'] as List<dynamic>?) ?? [];
      return list
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _apiClient.get('$_basePath/$conversationId/messages');
      final list = (response.data['messages'] as List<dynamic>?) ?? [];
      return list
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String sellerId,
  }) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'listing_id': listingId,
          'seller_id': sellerId,
        },
      );
      return ConversationModel.fromJson(
          response.data['conversation'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/$conversationId/messages',
        data: {'content': content},
      );
      return MessageModel.fromJson(
          response.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await _apiClient.patch('$_basePath/$conversationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    return ServerException(e.message ?? 'Messaging error', e.response?.statusCode);
  }
}
