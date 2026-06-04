import 'package:felo_na/features/messaging/domain/entities/conversation.dart';

/// Data model for [Conversation] with JSON serialization.
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.listingId,
    required super.listingTitle,
    super.listingImageUrl,
    required super.listingPrice,
    required super.buyerId,
    required super.buyerName,
    super.buyerAvatarUrl,
    required super.sellerId,
    required super.sellerName,
    super.sellerAvatarUrl,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
    required super.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final listing = json['listing'] as Map<String, dynamic>? ?? {};
    final buyer = json['buyer'] as Map<String, dynamic>? ?? {};
    final seller = json['seller'] as Map<String, dynamic>? ?? {};

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      listingId: (json['listing_id'] ?? listing['id'] ?? '')?.toString() ?? '',
      listingTitle: (json['listing_title'] ?? listing['title'] ?? 'Item')?.toString() ?? 'Item',
      listingImageUrl: json['listing_image'] as String? ??
          (listing['image_urls'] is List && (listing['image_urls'] as List).isNotEmpty
              ? (listing['image_urls'] as List).first as String?
              : null),
      listingPrice: ((json['listing_price'] ?? listing['price'] ?? 0) as num).toDouble(),
      buyerId: (json['buyer_id'] ?? buyer['id'] ?? '')?.toString() ?? '',
      buyerName: (json['buyer_name'] ?? buyer['full_name'] ?? 'Buyer')?.toString() ?? 'Buyer',
      buyerAvatarUrl: json['buyer_avatar'] as String? ?? buyer['profile_picture_url'] as String?,
      sellerId: (json['seller_id'] ?? seller['id'] ?? '')?.toString() ?? '',
      sellerName: (json['seller_name'] ?? seller['full_name'] ?? 'Seller')?.toString() ?? 'Seller',
      sellerAvatarUrl: json['seller_avatar'] as String? ?? seller['profile_picture_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing_id': listingId,
        'listing_title': listingTitle,
        'listing_price': listingPrice,
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'last_message': lastMessage,
        'last_message_at': lastMessageAt?.toIso8601String(),
        'unread_count': unreadCount,
        'created_at': createdAt.toIso8601String(),
      };
}
