import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/marketplace/data/models/listing_model.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';

void main() {
  final createdAt = DateTime.utc(2024, 2, 10, 8, 0, 0);
  final updatedAt = DateTime.utc(2024, 5, 20, 9, 0, 0);

  Map<String, dynamic> fullJson() => {
        'id': 'l1',
        'title': 'Old Sofa',
        'description': 'Barely used',
        'price': 1200.0,
        'category': 'furniture',
        'image_urls': ['https://img/1.jpg', 'https://img/2.jpg'],
        'seller_id': 's1',
        'seller_name': 'Dave',
        'seller_avatar_url': 'https://img/dave.jpg',
        'status': 'active',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'location': 'Dhaka',
        'is_favorite': true,
      };

  // ─────────────────────────────────────────────────────────
  // fromJson — snake_case
  // ─────────────────────────────────────────────────────────
  group('ListingModel.fromJson snake_case', () {
    test('parses all required fields', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.id, 'l1');
      expect(m.title, 'Old Sofa');
      expect(m.description, 'Barely used');
      expect(m.price, 1200.0);
      expect(m.category, ListingCategory.furniture);
      expect(m.sellerId, 's1');
      expect(m.sellerName, 'Dave');
      expect(m.status, ListingStatus.active);
      expect(m.createdAt, createdAt);
    });

    test('parses imageUrls list', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.imageUrls, ['https://img/1.jpg', 'https://img/2.jpg']);
    });

    test('parses optional fields', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.sellerAvatarUrl, 'https://img/dave.jpg');
      expect(m.updatedAt, updatedAt);
      expect(m.location, 'Dhaka');
      expect(m.isFavorite, isTrue);
    });

    test('empty image_urls list is accepted', () {
      final json = {...fullJson(), 'image_urls': <dynamic>[]};
      expect(ListingModel.fromJson(json).imageUrls, isEmpty);
    });

    test('null image_urls defaults to empty list', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('image_urls');
      expect(ListingModel.fromJson(json).imageUrls, isEmpty);
    });

    test('is_favorite defaults to false when absent', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('is_favorite');
      expect(ListingModel.fromJson(json).isFavorite, isFalse);
    });

    test('updatedAt is null when absent', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('updated_at');
      expect(ListingModel.fromJson(json).updatedAt, isNull);
    });

    test('location is null when absent', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('location');
      expect(ListingModel.fromJson(json).location, isNull);
    });

    test('sellerAvatarUrl is null when absent', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('seller_avatar_url');
      expect(ListingModel.fromJson(json).sellerAvatarUrl, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromJson — camelCase fallback
  // ─────────────────────────────────────────────────────────
  group('ListingModel.fromJson camelCase fallback', () {
    Map<String, dynamic> camelJson() => {
          'id': 'l2',
          'title': 'Laptop',
          'description': 'Works fine',
          'price': 25000.0,
          'category': 'electronics',
          'image_urls': ['https://img/lap.jpg'],
          'sellerId': 's2',
          'sellerName': 'Erin',
          'sellerAvatarUrl': 'https://img/erin.jpg',
          'status': 'active',
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
        };

    test('sellerId via camelCase', () {
      expect(ListingModel.fromJson(camelJson()).sellerId, 's2');
    });

    test('sellerName via camelCase', () {
      expect(ListingModel.fromJson(camelJson()).sellerName, 'Erin');
    });

    test('sellerAvatarUrl via camelCase', () {
      expect(ListingModel.fromJson(camelJson()).sellerAvatarUrl, 'https://img/erin.jpg');
    });

    test('createdAt via camelCase', () {
      expect(ListingModel.fromJson(camelJson()).createdAt, createdAt);
    });

    test('updatedAt via camelCase', () {
      expect(ListingModel.fromJson(camelJson()).updatedAt, updatedAt);
    });
  });

  // ─────────────────────────────────────────────────────────
  // price parsing
  // ─────────────────────────────────────────────────────────
  group('ListingModel price parsing', () {
    test('price as double', () {
      final json = {...fullJson(), 'price': 99.99};
      expect(ListingModel.fromJson(json).price, 99.99);
    });

    test('price as int is cast to double', () {
      final json = {...fullJson(), 'price': 500};
      expect(ListingModel.fromJson(json).price, 500.0);
      expect(ListingModel.fromJson(json).price, isA<double>());
    });

    test('price as String is parsed to double', () {
      final json = {...fullJson(), 'price': '750.5'};
      expect(ListingModel.fromJson(json).price, 750.5);
    });

    test('price of 0.0 is valid', () {
      final json = {...fullJson(), 'price': 0};
      expect(ListingModel.fromJson(json).price, 0.0);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Category parsing
  // ─────────────────────────────────────────────────────────
  group('ListingModel category parsing', () {
    const table = {
      'furniture': ListingCategory.furniture,
      'electronics': ListingCategory.electronics,
      'books': ListingCategory.books,
      'appliances': ListingCategory.appliances,
      'office': ListingCategory.office,
      'reusable': ListingCategory.reusable,
      'scrap': ListingCategory.scrap,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        final json = {...fullJson(), 'category': entry.key};
        expect(ListingModel.fromJson(json).category, entry.value);
      });
    }

    test('unknown category defaults to reusable', () {
      final json = {...fullJson(), 'category': 'mystery'};
      expect(ListingModel.fromJson(json).category, ListingCategory.reusable);
    });

    test('category is case-insensitive', () {
      final json = {...fullJson(), 'category': 'BOOKS'};
      expect(ListingModel.fromJson(json).category, ListingCategory.books);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Status parsing
  // ─────────────────────────────────────────────────────────
  group('ListingModel status parsing', () {
    const table = {
      'active': ListingStatus.active,
      'sold': ListingStatus.sold,
      'inactive': ListingStatus.inactive,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        final json = {...fullJson(), 'status': entry.key};
        expect(ListingModel.fromJson(json).status, entry.value);
      });
    }

    test('unknown status defaults to active', () {
      final json = {...fullJson(), 'status': 'archived'};
      expect(ListingModel.fromJson(json).status, ListingStatus.active);
    });

    test('absent status defaults to active', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('status');
      expect(ListingModel.fromJson(json).status, ListingStatus.active);
    });

    test('status is case-insensitive', () {
      final json = {...fullJson(), 'status': 'SOLD'};
      expect(ListingModel.fromJson(json).status, ListingStatus.sold);
    });
  });

  // ─────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────
  group('ListingModel.toJson', () {
    test('produces snake_case keys', () {
      final j = ListingModel.fromJson(fullJson()).toJson();
      for (final key in [
        'id', 'title', 'description', 'price', 'category',
        'image_urls', 'seller_id', 'seller_name', 'seller_avatar_url',
        'status', 'created_at', 'updated_at', 'location', 'is_favorite'
      ]) {
        expect(j.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });

    test('category serialises as enum name', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.toJson()['category'], 'furniture');
    });

    test('status serialises as enum name', () {
      final m = ListingModel.fromJson({...fullJson(), 'status': 'sold'});
      expect(m.toJson()['status'], 'sold');
    });

    test('imageUrls serialises as list', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.toJson()['image_urls'], isA<List>());
      expect(m.toJson()['image_urls'], hasLength(2));
    });

    test('null updatedAt serialises as null', () {
      final json = Map<String, dynamic>.from(fullJson())..remove('updated_at');
      final m = ListingModel.fromJson(json);
      expect(m.toJson()['updated_at'], isNull);
    });

    test('price serialises as double', () {
      final m = ListingModel.fromJson({...fullJson(), 'price': 500});
      expect(m.toJson()['price'], isA<double>());
    });

    test('is_favorite serialises correctly', () {
      final m = ListingModel.fromJson(fullJson());
      expect(m.toJson()['is_favorite'], isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────
  group('ListingModel round-trip', () {
    test('full object fromJson → toJson → fromJson', () {
      final original = ListingModel.fromJson(fullJson());
      final roundTripped = ListingModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('no-optionals object survives round-trip', () {
      final json = {
        'id': 'l99',
        'title': 'Thing',
        'description': 'Desc',
        'price': 10.0,
        'category': 'scrap',
        'seller_id': 's99',
        'seller_name': 'Min',
        'status': 'active',
        'created_at': createdAt.toIso8601String(),
      };
      final original = ListingModel.fromJson(json);
      final roundTripped = ListingModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('all categories survive round-trip', () {
      for (final cat in ListingCategory.values) {
        final json = {...fullJson(), 'category': cat.name};
        final original = ListingModel.fromJson(json);
        final roundTripped = ListingModel.fromJson(original.toJson());
        expect(roundTripped.category, cat);
      }
    });

    test('all statuses survive round-trip', () {
      for (final st in ListingStatus.values) {
        final json = {...fullJson(), 'status': st.name};
        final original = ListingModel.fromJson(json);
        final roundTripped = ListingModel.fromJson(original.toJson());
        expect(roundTripped.status, st);
      }
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromEntity
  // ─────────────────────────────────────────────────────────
  group('ListingModel.fromEntity', () {
    final entity = Listing(
      id: 'ent1',
      title: 'Chair',
      description: 'Wooden',
      price: 500.0,
      category: ListingCategory.furniture,
      imageUrls: ['https://img/chair.jpg'],
      sellerId: 'sX',
      sellerName: 'Frank',
      status: ListingStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: 'Chittagong',
      isFavorite: true,
    );

    test('all fields are copied', () {
      final model = ListingModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.price, entity.price);
      expect(model.category, entity.category);
      expect(model.imageUrls, entity.imageUrls);
      expect(model.sellerId, entity.sellerId);
      expect(model.sellerName, entity.sellerName);
      expect(model.status, entity.status);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
      expect(model.location, entity.location);
      expect(model.isFavorite, entity.isFavorite);
    });

    test('fromEntity has identical field values to source entity', () {
      final model = ListingModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.price, entity.price);
      expect(model.category, entity.category);
      expect(model.status, entity.status);
      expect(model.sellerId, entity.sellerId);
      expect(model.sellerName, entity.sellerName);
    });

    test('fromEntity null optionals are preserved', () {
      final minEntity = Listing(
        id: 'min',
        title: 'T',
        description: 'D',
        price: 0.0,
        category: ListingCategory.scrap,
        imageUrls: [],
        sellerId: 's0',
        sellerName: 'G',
        status: ListingStatus.inactive,
        createdAt: createdAt,
      );
      final model = ListingModel.fromEntity(minEntity);
      expect(model.sellerAvatarUrl, isNull);
      expect(model.updatedAt, isNull);
      expect(model.location, isNull);
      expect(model.isFavorite, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────
  // is-a check
  // ─────────────────────────────────────────────────────────
  test('ListingModel is a Listing', () {
    expect(ListingModel.fromJson(fullJson()), isA<Listing>());
  });
}
