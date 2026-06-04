import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // UserRole
  // ─────────────────────────────────────────────────────────
  group('UserRole', () {
    test('values count is 3', () {
      expect(UserRole.values.length, 3);
    });

    group('displayName', () {
      test('normalUser returns "Normal User"', () {
        expect(UserRole.normalUser.displayName, 'Normal User');
      });
      test('buyer returns "Buyer / Recycler"', () {
        expect(UserRole.buyer.displayName, 'Buyer / Recycler');
      });
      test('collector returns "Collector"', () {
        expect(UserRole.collector.displayName, 'Collector');
      });
      test('all values have non-empty displayName', () {
        for (final r in UserRole.values) {
          expect(r.displayName.isNotEmpty, isTrue, reason: '$r');
        }
      });
    });

    group('description', () {
      test('normalUser description', () {
        expect(UserRole.normalUser.description, 'Sell items & request pickups');
      });
      test('buyer description', () {
        expect(UserRole.buyer.description, 'Browse & purchase items');
      });
      test('collector description', () {
        expect(UserRole.collector.description, 'Accept pickup jobs & earn');
      });
    });

    group('iconName', () {
      test('normalUser iconName is "leaf"', () {
        expect(UserRole.normalUser.iconName, 'leaf');
      });
      test('buyer iconName is "shopping_bag"', () {
        expect(UserRole.buyer.iconName, 'shopping_bag');
      });
      test('collector iconName is "local_shipping"', () {
        expect(UserRole.collector.iconName, 'local_shipping');
      });
    });

    test('enum identity equality', () {
      expect(UserRole.normalUser == UserRole.normalUser, isTrue);
      expect(UserRole.buyer == UserRole.collector, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WasteCategory
  // ─────────────────────────────────────────────────────────
  group('WasteCategory', () {
    test('values count is 6', () {
      expect(WasteCategory.values.length, 6);
    });

    group('displayName', () {
      const expected = {
        WasteCategory.plastic: 'Plastic',
        WasteCategory.metal: 'Metal',
        WasteCategory.paper: 'Paper',
        WasteCategory.glass: 'Glass',
        WasteCategory.electronics: 'Electronics',
        WasteCategory.other: 'Other',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });

    group('iconName', () {
      const expected = {
        WasteCategory.plastic: 'water_drop',
        WasteCategory.metal: 'hardware',
        WasteCategory.paper: 'description',
        WasteCategory.glass: 'local_bar',
        WasteCategory.electronics: 'devices',
        WasteCategory.other: 'inventory_2',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.iconName, entry.value);
        });
      }
    });

    group('colorHex', () {
      test('plastic hex', () => expect(WasteCategory.plastic.colorHex, '#03A9F4'));
      test('metal hex', () => expect(WasteCategory.metal.colorHex, '#9E9E9E'));
      test('paper hex', () => expect(WasteCategory.paper.colorHex, '#8D6E63'));
      test('glass hex', () => expect(WasteCategory.glass.colorHex, '#2ECC71'));
      test('electronics hex', () => expect(WasteCategory.electronics.colorHex, '#616161'));
      test('other hex', () => expect(WasteCategory.other.colorHex, '#9E9E9E'));

      test('all colorHex values start with #', () {
        for (final c in WasteCategory.values) {
          expect(c.colorHex.startsWith('#'), isTrue, reason: '$c');
        }
      });
    });
  });

  // ─────────────────────────────────────────────────────────
  // ListingCategory
  // ─────────────────────────────────────────────────────────
  group('ListingCategory', () {
    test('values count is 7', () {
      expect(ListingCategory.values.length, 7);
    });

    group('displayName', () {
      const expected = {
        ListingCategory.furniture: 'Furniture',
        ListingCategory.electronics: 'Electronics',
        ListingCategory.books: 'Books',
        ListingCategory.appliances: 'Appliances',
        ListingCategory.office: 'Office Items',
        ListingCategory.reusable: 'Reusable Products',
        ListingCategory.scrap: 'Scrap Materials',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });
  });

  // ─────────────────────────────────────────────────────────
  // PickupStatus
  // ─────────────────────────────────────────────────────────
  group('PickupStatus', () {
    test('values count is 7', () {
      expect(PickupStatus.values.length, 7);
    });

    group('displayName', () {
      const expected = {
        PickupStatus.pending: 'Pending',
        PickupStatus.assigned: 'Assigned',
        PickupStatus.accepted: 'Accepted',
        PickupStatus.onTheWay: 'On The Way',
        PickupStatus.arrived: 'Arrived',
        PickupStatus.completed: 'Completed',
        PickupStatus.cancelled: 'Cancelled',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });

    group('colorHex', () {
      test('pending color', () => expect(PickupStatus.pending.colorHex, '#F39C12'));
      test('assigned color', () => expect(PickupStatus.assigned.colorHex, '#9B59B6'));
      test('accepted color', () => expect(PickupStatus.accepted.colorHex, '#03A9F4'));
      test('onTheWay color', () => expect(PickupStatus.onTheWay.colorHex, '#03A9F4'));
      test('arrived color', () => expect(PickupStatus.arrived.colorHex, '#2ECC71'));
      test('completed color', () => expect(PickupStatus.completed.colorHex, '#27AE60'));
      test('cancelled color', () => expect(PickupStatus.cancelled.colorHex, '#E74C3C'));

      test('all colorHex values start with #', () {
        for (final s in PickupStatus.values) {
          expect(s.colorHex.startsWith('#'), isTrue, reason: '$s');
        }
      });
    });
  });

  // ─────────────────────────────────────────────────────────
  // PickupTimeSlot
  // ─────────────────────────────────────────────────────────
  group('PickupTimeSlot', () {
    test('values count is 6', () {
      expect(PickupTimeSlot.values.length, 6);
    });

    group('displayName', () {
      const expected = {
        PickupTimeSlot.morning1: '08:00 - 10:00',
        PickupTimeSlot.morning2: '10:00 - 12:00',
        PickupTimeSlot.afternoon1: '12:00 - 14:00',
        PickupTimeSlot.afternoon2: '14:00 - 16:00',
        PickupTimeSlot.evening1: '16:00 - 18:00',
        PickupTimeSlot.evening2: '18:00 - 20:00',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });

    group('label', () {
      const expected = {
        PickupTimeSlot.morning1: 'Early Morning',
        PickupTimeSlot.morning2: 'Late Morning',
        PickupTimeSlot.afternoon1: 'Early Afternoon',
        PickupTimeSlot.afternoon2: 'Late Afternoon',
        PickupTimeSlot.evening1: 'Early Evening',
        PickupTimeSlot.evening2: 'Late Evening',
      };
      for (final entry in expected.entries) {
        test('${entry.key} label → ${entry.value}', () {
          expect(entry.key.label, entry.value);
        });
      }
    });

    group('apiValue', () {
      const expected = {
        PickupTimeSlot.morning1: '08:00-10:00',
        PickupTimeSlot.morning2: '10:00-12:00',
        PickupTimeSlot.afternoon1: '12:00-14:00',
        PickupTimeSlot.afternoon2: '14:00-16:00',
        PickupTimeSlot.evening1: '16:00-18:00',
        PickupTimeSlot.evening2: '18:00-20:00',
      };
      for (final entry in expected.entries) {
        test('${entry.key} apiValue → ${entry.value}', () {
          expect(entry.key.apiValue, entry.value);
        });
      }
    });

    group('fromApiValue round-trip', () {
      test('every slot survives apiValue → fromApiValue', () {
        for (final slot in PickupTimeSlot.values) {
          expect(PickupTimeSlot.fromApiValue(slot.apiValue), slot);
        }
      });

      test('unknown value falls back to morning1', () {
        expect(PickupTimeSlot.fromApiValue('99:00-23:00'), PickupTimeSlot.morning1);
      });

      test('empty string falls back to morning1', () {
        expect(PickupTimeSlot.fromApiValue(''), PickupTimeSlot.morning1);
      });
    });
  });

  // ─────────────────────────────────────────────────────────
  // RecurrenceFrequency
  // ─────────────────────────────────────────────────────────
  group('RecurrenceFrequency', () {
    test('values count is 2', () {
      expect(RecurrenceFrequency.values.length, 2);
    });

    test('weekly displayName', () {
      expect(RecurrenceFrequency.weekly.displayName, 'Every Week');
    });

    test('biweekly displayName', () {
      expect(RecurrenceFrequency.biweekly.displayName, 'Every 2 Weeks');
    });
  });

  // ─────────────────────────────────────────────────────────
  // OfferStatus
  // ─────────────────────────────────────────────────────────
  group('OfferStatus', () {
    test('values count is 4', () {
      expect(OfferStatus.values.length, 4);
    });

    const expected = {
      OfferStatus.pending: 'Pending',
      OfferStatus.accepted: 'Accepted',
      OfferStatus.rejected: 'Rejected',
      OfferStatus.expired: 'Expired',
    };
    for (final entry in expected.entries) {
      test('${entry.key} displayName → ${entry.value}', () {
        expect(entry.key.displayName, entry.value);
      });
    }
  });

  // ─────────────────────────────────────────────────────────
  // ListingStatus
  // ─────────────────────────────────────────────────────────
  group('ListingStatus', () {
    test('values count is 3', () {
      expect(ListingStatus.values.length, 3);
    });

    const expected = {
      ListingStatus.active: 'Active',
      ListingStatus.sold: 'Sold',
      ListingStatus.inactive: 'Inactive',
    };
    for (final entry in expected.entries) {
      test('${entry.key} displayName → ${entry.value}', () {
        expect(entry.key.displayName, entry.value);
      });
    }
  });

  // ─────────────────────────────────────────────────────────
  // NotificationType
  // ─────────────────────────────────────────────────────────
  group('NotificationType', () {
    test('values count is 9', () {
      expect(NotificationType.values.length, 9);
    });

    group('displayName', () {
      const expected = {
        NotificationType.newOffer: 'New Offer',
        NotificationType.offerAccepted: 'Offer Accepted',
        NotificationType.offerRejected: 'Offer Rejected',
        NotificationType.pickupAccepted: 'Pickup Accepted',
        NotificationType.pickupStatusUpdate: 'Pickup Status Update',
        NotificationType.pickupCompleted: 'Pickup Completed',
        NotificationType.newMessage: 'New Message',
        NotificationType.ecoMilestone: 'Eco Milestone',
        NotificationType.general: 'Notification',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });

    group('iconName', () {
      const expected = {
        NotificationType.newOffer: 'local_offer',
        NotificationType.offerAccepted: 'check_circle',
        NotificationType.offerRejected: 'cancel',
        NotificationType.pickupAccepted: 'local_shipping',
        NotificationType.pickupStatusUpdate: 'location_on',
        NotificationType.pickupCompleted: 'check_circle',
        NotificationType.newMessage: 'message',
        NotificationType.ecoMilestone: 'eco',
        NotificationType.general: 'notifications',
      };
      for (final entry in expected.entries) {
        test('${entry.key} iconName → ${entry.value}', () {
          expect(entry.key.iconName, entry.value);
        });
      }
    });
  });

  // ─────────────────────────────────────────────────────────
  // EcoBadgeType
  // ─────────────────────────────────────────────────────────
  group('EcoBadgeType', () {
    test('values count is 6', () {
      expect(EcoBadgeType.values.length, 6);
    });

    group('displayName', () {
      const expected = {
        EcoBadgeType.beginner: 'Beginner',
        EcoBadgeType.bronze: 'Bronze',
        EcoBadgeType.silver: 'Silver',
        EcoBadgeType.gold: 'Gold',
        EcoBadgeType.platinum: 'Platinum',
        EcoBadgeType.champion: 'Champion',
      };
      for (final entry in expected.entries) {
        test('${entry.key} → ${entry.value}', () {
          expect(entry.key.displayName, entry.value);
        });
      }
    });

    group('requiredPoints', () {
      test('beginner requires 0 points', () {
        expect(EcoBadgeType.beginner.requiredPoints, 0);
      });
      test('bronze requires 100 points', () {
        expect(EcoBadgeType.bronze.requiredPoints, 100);
      });
      test('silver requires 500 points', () {
        expect(EcoBadgeType.silver.requiredPoints, 500);
      });
      test('gold requires 1000 points', () {
        expect(EcoBadgeType.gold.requiredPoints, 1000);
      });
      test('platinum requires 5000 points', () {
        expect(EcoBadgeType.platinum.requiredPoints, 5000);
      });
      test('champion requires 10000 points', () {
        expect(EcoBadgeType.champion.requiredPoints, 10000);
      });
      test('required points are strictly ascending', () {
        final points = EcoBadgeType.values.map((b) => b.requiredPoints).toList();
        for (int i = 1; i < points.length; i++) {
          expect(points[i] > points[i - 1], isTrue,
              reason: '${EcoBadgeType.values[i]} should require more than ${EcoBadgeType.values[i - 1]}');
        }
      });
    });
  });

  // ─────────────────────────────────────────────────────────
  // MessageStatus
  // ─────────────────────────────────────────────────────────
  group('MessageStatus', () {
    test('values count is 3', () {
      expect(MessageStatus.values.length, 3);
    });

    const expected = {
      MessageStatus.sent: 'Sent',
      MessageStatus.delivered: 'Delivered',
      MessageStatus.read: 'Read',
    };
    for (final entry in expected.entries) {
      test('${entry.key} displayName → ${entry.value}', () {
        expect(entry.key.displayName, entry.value);
      });
    }
  });
}
