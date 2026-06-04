import 'package:equatable/equatable.dart';

/// Represents a conversation thread between a buyer and seller about a listing.
class Conversation extends Equatable {
  final String id;
  final String listingId;
  final String listingTitle;
  final String? listingImageUrl;
  final double listingPrice;
  final String buyerId;
  final String buyerName;
  final String? buyerAvatarUrl;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    this.listingImageUrl,
    required this.listingPrice,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatarUrl,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        listingPrice,
        buyerId,
        sellerId,
        lastMessage,
        lastMessageAt,
        unreadCount,
        createdAt,
      ];
}
