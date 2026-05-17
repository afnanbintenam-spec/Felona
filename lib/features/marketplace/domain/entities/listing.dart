import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Listing entity representing a marketplace item.
///
/// This is a domain entity for items listed in the marketplace.
class Listing extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final ListingCategory category;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final bool isFavorite;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.isFavorite = false,
  });

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    ListingCategory? category,
    List<String>? imageUrls,
    String? sellerId,
    String? sellerName,
    String? sellerAvatarUrl,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    bool? isFavorite,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatarUrl: sellerAvatarUrl ?? this.sellerAvatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        category,
        imageUrls,
        sellerId,
        sellerName,
        sellerAvatarUrl,
        status,
        createdAt,
        updatedAt,
        location,
        isFavorite,
      ];
}
