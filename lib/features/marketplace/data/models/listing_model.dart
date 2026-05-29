import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';

/// Data model for Listing with JSON serialization.
class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.category,
    required super.imageUrls,
    required super.sellerId,
    required super.sellerName,
    super.sellerAvatarUrl,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.location,
    super.isFavorite,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: _parseCategory(json['category'] as String),
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerId: (json['seller_id'] ?? json['sellerId']) as String,
      sellerName: (json['seller_name'] ?? json['sellerName']) as String,
      sellerAvatarUrl:
          (json['seller_avatar_url'] ?? json['sellerAvatarUrl']) as String?,
      status: _parseStatus(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String,
      ),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String)
          : null,
      location: json['location'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': _categoryToString(category),
      'image_urls': imageUrls,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_avatar_url': sellerAvatarUrl,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'location': location,
      'is_favorite': isFavorite,
    };
  }

  factory ListingModel.fromEntity(Listing listing) {
    return ListingModel(
      id: listing.id,
      title: listing.title,
      description: listing.description,
      price: listing.price,
      category: listing.category,
      imageUrls: listing.imageUrls,
      sellerId: listing.sellerId,
      sellerName: listing.sellerName,
      sellerAvatarUrl: listing.sellerAvatarUrl,
      status: listing.status,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
      location: listing.location,
      isFavorite: listing.isFavorite,
    );
  }

  static ListingCategory _parseCategory(String value) {
    switch (value.toLowerCase()) {
      case 'furniture':
        return ListingCategory.furniture;
      case 'electronics':
        return ListingCategory.electronics;
      case 'books':
        return ListingCategory.books;
      case 'appliances':
        return ListingCategory.appliances;
      case 'office':
        return ListingCategory.office;
      case 'reusable':
        return ListingCategory.reusable;
      case 'scrap':
        return ListingCategory.scrap;
      default:
        return ListingCategory.reusable;
    }
  }

  static String _categoryToString(ListingCategory category) {
    return category.name;
  }

  static ListingStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ListingStatus.active;
      case 'sold':
        return ListingStatus.sold;
      case 'inactive':
        return ListingStatus.inactive;
      default:
        return ListingStatus.active;
    }
  }

  static String _statusToString(ListingStatus status) {
    return status.name;
  }
}
