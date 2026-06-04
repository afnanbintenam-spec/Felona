import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/data/models/pickup_model.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

void main() {
  final createdAt = DateTime.utc(2024, 3, 10, 9, 0, 0);
  final scheduledDate = DateTime.utc(2024, 3, 12);
  final acceptedAt = DateTime.utc(2024, 3, 12, 8, 30, 0);
  final completedAt = DateTime.utc(2024, 3, 12, 9, 15, 0);

  // Minimal required-only JSON (snake_case)
  Map<String, dynamic> minJson() => {
        'id': 'pr1',
        'user_id': 'u1',
        'user_name': 'Alice',
        'category': 'plastic',
        'estimated_weight': 5.0,
        'address': '123 Green St',
        'status': 'pending',
        'created_at': createdAt.toIso8601String(),
      };

  // Full JSON with all optional fields
  Map<String, dynamic> fullJson() => {
        'id': 'pr2',
        'user_id': 'u2',
        'user_name': 'Bob',
        'category': 'metal',
        'estimated_weight': 12.5,
        'address': '456 Eco Ave',
        'latitude': 23.8103,
        'longitude': 90.4125,
        'notes': 'Leave at gate',
        'status': 'on_the_way',
        'collector_id': 'c1',
        'collector_name': 'Charlie',
        'collector_phone': '+8801800000000',
        'collector_photo': 'https://img/c.jpg',
        'collector_rating': 4.8,
        'created_at': createdAt.toIso8601String(),
        'scheduled_date': scheduledDate.toIso8601String(),
        'time_slot': '08:00-10:00',
        'is_recurring': true,
        'recurrence_frequency': 'weekly',
        'recurrence_day': 2,
        'recurring_schedule_id': 'rs1',
        'accepted_at': acceptedAt.toIso8601String(),
        'completed_at': completedAt.toIso8601String(),
        'eco_points_earned': 50,
        'eta_minutes': 15,
        'collector_latitude': 23.8100,
        'collector_longitude': 90.4120,
        'qr_token': 'qr-abc-123',
        'rating': 4.5,
        'feedback': 'Great service',
      };

  // ─────────────────────────────────────────────────────────
  // fromJson — required fields
  // ─────────────────────────────────────────────────────────
  group('PickupModel.fromJson required fields', () {
    test('parses id, userId, userName', () {
      final m = PickupModel.fromJson(minJson());
      expect(m.id, 'pr1');
      expect(m.userId, 'u1');
      expect(m.userName, 'Alice');
    });

    test('parses category', () {
      expect(PickupModel.fromJson(minJson()).category, WasteCategory.plastic);
    });

    test('parses estimatedWeight as double', () {
      expect(PickupModel.fromJson(minJson()).estimatedWeight, 5.0);
      expect(PickupModel.fromJson(minJson()).estimatedWeight, isA<double>());
    });

    test('parses address', () {
      expect(PickupModel.fromJson(minJson()).address, '123 Green St');
    });

    test('parses status', () {
      expect(PickupModel.fromJson(minJson()).status, PickupStatus.pending);
    });

    test('parses createdAt', () {
      expect(PickupModel.fromJson(minJson()).createdAt, createdAt);
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromJson — optional fields present
  // ─────────────────────────────────────────────────────────
  group('PickupModel.fromJson optional fields', () {
    test('parses all optional fields from fullJson', () {
      final m = PickupModel.fromJson(fullJson());
      expect(m.latitude, 23.8103);
      expect(m.longitude, 90.4125);
      expect(m.notes, 'Leave at gate');
      expect(m.collectorId, 'c1');
      expect(m.collectorName, 'Charlie');
      expect(m.collectorPhone, '+8801800000000');
      expect(m.collectorPhoto, 'https://img/c.jpg');
      expect(m.collectorRating, closeTo(4.8, 0.001));
      expect(m.scheduledDate, scheduledDate);
      expect(m.timeSlot, PickupTimeSlot.morning1);
      expect(m.isRecurring, isTrue);
      expect(m.recurrenceFrequency, RecurrenceFrequency.weekly);
      expect(m.recurrenceDayOfWeek, 2);
      expect(m.recurringScheduleId, 'rs1');
      expect(m.acceptedAt, acceptedAt);
      expect(m.completedAt, completedAt);
      expect(m.ecoPointsEarned, 50);
      expect(m.etaMinutes, 15);
      expect(m.collectorLatitude, closeTo(23.81, 0.001));
      expect(m.collectorLongitude, closeTo(90.412, 0.001));
      expect(m.qrToken, 'qr-abc-123');
      expect(m.rating, 4.5);
      expect(m.feedback, 'Great service');
    });

    test('optional fields are null when absent in minJson', () {
      final m = PickupModel.fromJson(minJson());
      expect(m.latitude, isNull);
      expect(m.longitude, isNull);
      expect(m.notes, isNull);
      expect(m.collectorId, isNull);
      expect(m.collectorName, isNull);
      expect(m.collectorPhone, isNull);
      expect(m.collectorPhoto, isNull);
      expect(m.collectorRating, isNull);
      expect(m.scheduledDate, isNull);
      expect(m.timeSlot, isNull);
      expect(m.isRecurring, isFalse);
      expect(m.recurrenceFrequency, isNull);
      expect(m.recurrenceDayOfWeek, isNull);
      expect(m.acceptedAt, isNull);
      expect(m.completedAt, isNull);
      expect(m.ecoPointsEarned, isNull);
      expect(m.etaMinutes, isNull);
      expect(m.collectorLatitude, isNull);
      expect(m.collectorLongitude, isNull);
      expect(m.qrToken, isNull);
      expect(m.rating, isNull);
      expect(m.feedback, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromJson — camelCase fallback keys
  // ─────────────────────────────────────────────────────────
  group('PickupModel.fromJson camelCase fallback', () {
    Map<String, dynamic> camelJson() => {
          'id': 'pr3',
          'userId': 'u3',
          'userName': 'Carol',
          'category': 'glass',
          'estimatedWeight': 3.0,
          'address': '789 Rd',
          'status': 'accepted',
          'createdAt': createdAt.toIso8601String(),
          'collectorId': 'c2',
          'collectorName': 'Dan',
          'collectorPhone': '+111',
          'collectorPhoto': 'https://img/d.jpg',
          'collectorRating': 4.2,
          'scheduledDate': scheduledDate.toIso8601String(),
          'timeSlot': '10:00-12:00',
          'isRecurring': false,
          'acceptedAt': acceptedAt.toIso8601String(),
          'ecoPointsEarned': 20,
          'etaMinutes': 10,
          'collectorLatitude': 23.0,
          'collectorLongitude': 90.0,
          'qrToken': 'tok',
        };

    test('userId via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).userId, 'u3');
    });
    test('userName via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).userName, 'Carol');
    });
    test('estimatedWeight via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).estimatedWeight, 3.0);
    });
    test('createdAt via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).createdAt, createdAt);
    });
    test('collectorId via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).collectorId, 'c2');
    });
    test('collectorRating via camelCase (numeric cast bug fix)', () {
      expect(PickupModel.fromJson(camelJson()).collectorRating, closeTo(4.2, 0.001));
    });
    test('scheduledDate via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).scheduledDate, scheduledDate);
    });
    test('timeSlot via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).timeSlot, PickupTimeSlot.morning2);
    });
    test('acceptedAt via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).acceptedAt, acceptedAt);
    });
    test('collectorLatitude via camelCase (numeric cast bug fix)', () {
      expect(PickupModel.fromJson(camelJson()).collectorLatitude, 23.0);
    });
    test('collectorLongitude via camelCase (numeric cast bug fix)', () {
      expect(PickupModel.fromJson(camelJson()).collectorLongitude, 90.0);
    });
    test('qrToken via camelCase', () {
      expect(PickupModel.fromJson(camelJson()).qrToken, 'tok');
    });
  });

  // ─────────────────────────────────────────────────────────
  // Numeric casting edge cases (the fixed bugs)
  // ─────────────────────────────────────────────────────────
  group('PickupModel numeric casting', () {
    test('collectorRating as int via snake_case casts to double', () {
      final json = {...minJson(), 'collector_rating': 5};
      expect(PickupModel.fromJson(json).collectorRating, 5.0);
      expect(PickupModel.fromJson(json).collectorRating, isA<double>());
    });

    test('collectorRating as int via camelCase casts to double', () {
      final json = {...minJson(), 'collectorRating': 5};
      expect(PickupModel.fromJson(json).collectorRating, 5.0);
    });

    test('collectorLatitude as int casts to double', () {
      final json = {...minJson(), 'collector_latitude': 23};
      expect(PickupModel.fromJson(json).collectorLatitude, 23.0);
      expect(PickupModel.fromJson(json).collectorLatitude, isA<double>());
    });

    test('collectorLongitude as int casts to double', () {
      final json = {...minJson(), 'collector_longitude': 90};
      expect(PickupModel.fromJson(json).collectorLongitude, 90.0);
      expect(PickupModel.fromJson(json).collectorLongitude, isA<double>());
    });

    test('estimatedWeight as int casts to double', () {
      final json = {...minJson(), 'estimated_weight': 7};
      expect(PickupModel.fromJson(json).estimatedWeight, 7.0);
      expect(PickupModel.fromJson(json).estimatedWeight, isA<double>());
    });

    test('latitude as int casts to double', () {
      final json = {...minJson(), 'latitude': 23};
      expect(PickupModel.fromJson(json).latitude, 23.0);
    });

    test('longitude as int casts to double', () {
      final json = {...minJson(), 'longitude': 90};
      expect(PickupModel.fromJson(json).longitude, 90.0);
    });

    test('rating as int casts to double', () {
      final json = {...minJson(), 'rating': 4};
      expect(PickupModel.fromJson(json).rating, 4.0);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Category parsing
  // ─────────────────────────────────────────────────────────
  group('PickupModel category parsing', () {
    const table = {
      'plastic': WasteCategory.plastic,
      'metal': WasteCategory.metal,
      'paper': WasteCategory.paper,
      'glass': WasteCategory.glass,
      'electronics': WasteCategory.electronics,
      'other': WasteCategory.other,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        expect(
          PickupModel.fromJson({...minJson(), 'category': entry.key}).category,
          entry.value,
        );
      });
    }

    test('unknown category defaults to other', () {
      expect(
        PickupModel.fromJson({...minJson(), 'category': 'wood'}).category,
        WasteCategory.other,
      );
    });

    test('category is case-insensitive', () {
      expect(
        PickupModel.fromJson({...minJson(), 'category': 'PLASTIC'}).category,
        WasteCategory.plastic,
      );
    });
  });

  // ─────────────────────────────────────────────────────────
  // Status parsing
  // ─────────────────────────────────────────────────────────
  group('PickupModel status parsing', () {
    const table = {
      'pending': PickupStatus.pending,
      'assigned': PickupStatus.assigned,
      'accepted': PickupStatus.accepted,
      'on_the_way': PickupStatus.onTheWay,
      'arrived': PickupStatus.arrived,
      'completed': PickupStatus.completed,
      'cancelled': PickupStatus.cancelled,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        expect(
          PickupModel.fromJson({...minJson(), 'status': entry.key}).status,
          entry.value,
        );
      });
    }

    test('"ontheway" (no underscore) → onTheWay', () {
      expect(
        PickupModel.fromJson({...minJson(), 'status': 'ontheway'}).status,
        PickupStatus.onTheWay,
      );
    });

    test('unknown status defaults to pending', () {
      expect(
        PickupModel.fromJson({...minJson(), 'status': 'unknown_xyz'}).status,
        PickupStatus.pending,
      );
    });

    test('absent status defaults to pending', () {
      final json = Map<String, dynamic>.from(minJson())..remove('status');
      expect(PickupModel.fromJson(json).status, PickupStatus.pending);
    });

    test('status is case-insensitive', () {
      expect(
        PickupModel.fromJson({...minJson(), 'status': 'COMPLETED'}).status,
        PickupStatus.completed,
      );
    });
  });

  // ─────────────────────────────────────────────────────────
  // RecurrenceFrequency parsing
  // ─────────────────────────────────────────────────────────
  group('PickupModel recurrenceFrequency parsing', () {
    test('"weekly" → weekly', () {
      final json = {...minJson(), 'recurrence_frequency': 'weekly'};
      expect(PickupModel.fromJson(json).recurrenceFrequency, RecurrenceFrequency.weekly);
    });

    test('"biweekly" → biweekly', () {
      final json = {...minJson(), 'recurrence_frequency': 'biweekly'};
      expect(PickupModel.fromJson(json).recurrenceFrequency, RecurrenceFrequency.biweekly);
    });

    test('unknown recurrence defaults to weekly', () {
      final json = {...minJson(), 'recurrence_frequency': 'monthly'};
      expect(PickupModel.fromJson(json).recurrenceFrequency, RecurrenceFrequency.weekly);
    });
  });

  // ─────────────────────────────────────────────────────────
  // TimeSlot parsing
  // ─────────────────────────────────────────────────────────
  group('PickupModel timeSlot parsing', () {
    for (final slot in PickupTimeSlot.values) {
      test('${slot.apiValue} → $slot', () {
        final json = {...minJson(), 'time_slot': slot.apiValue};
        expect(PickupModel.fromJson(json).timeSlot, slot);
      });
    }

    test('absent time_slot is null', () {
      expect(PickupModel.fromJson(minJson()).timeSlot, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────
  group('PickupModel.toJson', () {
    test('produces all expected snake_case keys', () {
      final j = PickupModel.fromJson(fullJson()).toJson();
      for (final key in [
        'id', 'user_id', 'user_name', 'category', 'estimated_weight', 'address',
        'latitude', 'longitude', 'notes', 'status', 'collector_id', 'collector_name',
        'collector_phone', 'collector_photo', 'collector_rating', 'created_at',
        'scheduled_date', 'time_slot', 'is_recurring', 'recurrence_frequency',
        'recurrence_day', 'recurring_schedule_id', 'accepted_at', 'completed_at',
        'eco_points_earned', 'eta_minutes', 'collector_latitude', 'collector_longitude',
        'qr_token', 'rating', 'feedback',
      ]) {
        expect(j.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });

    test('status serialises on_the_way for onTheWay', () {
      final m = PickupModel.fromJson({...minJson(), 'status': 'on_the_way'});
      expect(m.toJson()['status'], 'on_the_way');
    });

    test('status serialises all values correctly', () {
      const expected = {
        'pending': 'pending',
        'assigned': 'assigned',
        'accepted': 'accepted',
        'on_the_way': 'on_the_way',
        'arrived': 'arrived',
        'completed': 'completed',
        'cancelled': 'cancelled',
      };
      for (final entry in expected.entries) {
        final m = PickupModel.fromJson({...minJson(), 'status': entry.key});
        expect(m.toJson()['status'], entry.value);
      }
    });

    test('category serialises as enum name', () {
      final m = PickupModel.fromJson({...minJson(), 'category': 'glass'});
      expect(m.toJson()['category'], 'glass');
    });

    test('timeSlot serialises as apiValue string', () {
      final m = PickupModel.fromJson({...minJson(), 'time_slot': '12:00-14:00'});
      expect(m.toJson()['time_slot'], '12:00-14:00');
    });

    test('null optionals remain null in toJson', () {
      final j = PickupModel.fromJson(minJson()).toJson();
      expect(j['latitude'], isNull);
      expect(j['collector_id'], isNull);
      expect(j['scheduled_date'], isNull);
      expect(j['time_slot'], isNull);
      expect(j['feedback'], isNull);
    });

    test('isRecurring serialises as bool', () {
      final j = PickupModel.fromJson(fullJson()).toJson();
      expect(j['is_recurring'], isA<bool>());
      expect(j['is_recurring'], isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Round-trip: fromJson → toJson → fromJson
  // ─────────────────────────────────────────────────────────
  group('PickupModel round-trip', () {
    test('minimal object survives round-trip', () {
      final original = PickupModel.fromJson(minJson());
      final roundTripped = PickupModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('full object survives round-trip', () {
      final original = PickupModel.fromJson(fullJson());
      final roundTripped = PickupModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('all waste categories survive round-trip', () {
      for (final cat in WasteCategory.values) {
        final json = {...minJson(), 'category': cat.name};
        final original = PickupModel.fromJson(json);
        final roundTripped = PickupModel.fromJson(original.toJson());
        expect(roundTripped.category, cat);
      }
    });

    test('all pickup statuses survive round-trip', () {
      final statusStrings = {
        PickupStatus.pending: 'pending',
        PickupStatus.assigned: 'assigned',
        PickupStatus.accepted: 'accepted',
        PickupStatus.onTheWay: 'on_the_way',
        PickupStatus.arrived: 'arrived',
        PickupStatus.completed: 'completed',
        PickupStatus.cancelled: 'cancelled',
      };
      for (final entry in statusStrings.entries) {
        final json = {...minJson(), 'status': entry.value};
        final original = PickupModel.fromJson(json);
        final roundTripped = PickupModel.fromJson(original.toJson());
        expect(roundTripped.status, entry.key);
      }
    });

    test('all time slots survive round-trip', () {
      for (final slot in PickupTimeSlot.values) {
        final json = {...minJson(), 'time_slot': slot.apiValue};
        final original = PickupModel.fromJson(json);
        final roundTripped = PickupModel.fromJson(original.toJson());
        expect(roundTripped.timeSlot, slot);
      }
    });
  });

  // ─────────────────────────────────────────────────────────
  // is-a check
  // ─────────────────────────────────────────────────────────
  test('PickupModel is a PickupRequest', () {
    expect(PickupModel.fromJson(minJson()), isA<PickupRequest>());
  });
}
