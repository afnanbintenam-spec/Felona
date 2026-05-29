/// Core enumerations used throughout the FeloNa application.
///
/// This file contains all enum definitions for user roles, waste categories,
/// pickup statuses, and other domain-specific types.

/// User role enumeration defining the three types of users in the system.
///
/// - [normalUser]: Regular users who can sell items and request pickups
/// - [buyer]: Users who browse and purchase items/scrap
/// - [collector]: Users who accept and complete pickup jobs
enum UserRole {
  normalUser,
  buyer,
  collector;

  /// Returns a human-readable display name for the role
  String get displayName {
    switch (this) {
      case UserRole.normalUser:
        return 'Normal User';
      case UserRole.buyer:
        return 'Buyer / Recycler';
      case UserRole.collector:
        return 'Collector';
    }
  }

  /// Returns a description of what the role can do
  String get description {
    switch (this) {
      case UserRole.normalUser:
        return 'Sell items & request pickups';
      case UserRole.buyer:
        return 'Browse & purchase items';
      case UserRole.collector:
        return 'Accept pickup jobs & earn';
    }
  }

  /// Returns the icon name for the role
  String get iconName {
    switch (this) {
      case UserRole.normalUser:
        return 'leaf';
      case UserRole.buyer:
        return 'shopping_bag';
      case UserRole.collector:
        return 'local_shipping';
    }
  }
}

/// Waste category enumeration for recyclable materials.
enum WasteCategory {
  plastic,
  metal,
  paper,
  glass,
  electronics,
  other;

  /// Returns a human-readable display name
  String get displayName {
    switch (this) {
      case WasteCategory.plastic:
        return 'Plastic';
      case WasteCategory.metal:
        return 'Metal';
      case WasteCategory.paper:
        return 'Paper';
      case WasteCategory.glass:
        return 'Glass';
      case WasteCategory.electronics:
        return 'Electronics';
      case WasteCategory.other:
        return 'Other';
    }
  }

  /// Returns the icon name for the category
  String get iconName {
    switch (this) {
      case WasteCategory.plastic:
        return 'water_drop';
      case WasteCategory.metal:
        return 'hardware';
      case WasteCategory.paper:
        return 'description';
      case WasteCategory.glass:
        return 'local_bar';
      case WasteCategory.electronics:
        return 'devices';
      case WasteCategory.other:
        return 'inventory_2';
    }
  }

  /// Returns the color associated with the category
  String get colorHex {
    switch (this) {
      case WasteCategory.plastic:
        return '#03A9F4'; // Blue
      case WasteCategory.metal:
        return '#9E9E9E'; // Gray
      case WasteCategory.paper:
        return '#8D6E63'; // Brown
      case WasteCategory.glass:
        return '#2ECC71'; // Green
      case WasteCategory.electronics:
        return '#616161'; // Dark Gray
      case WasteCategory.other:
        return '#9E9E9E'; // Gray
    }
  }
}

/// Listing category for marketplace items.
enum ListingCategory {
  furniture,
  electronics,
  books,
  appliances,
  office,
  reusable,
  scrap;

  String get displayName {
    switch (this) {
      case ListingCategory.furniture:
        return 'Furniture';
      case ListingCategory.electronics:
        return 'Electronics';
      case ListingCategory.books:
        return 'Books';
      case ListingCategory.appliances:
        return 'Appliances';
      case ListingCategory.office:
        return 'Office Items';
      case ListingCategory.reusable:
        return 'Reusable Products';
      case ListingCategory.scrap:
        return 'Scrap Materials';
    }
  }
}

/// Pickup request status enumeration.
enum PickupStatus {
  pending,
  assigned,
  accepted,
  onTheWay,
  arrived,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case PickupStatus.pending:
        return 'Pending';
      case PickupStatus.assigned:
        return 'Assigned';
      case PickupStatus.accepted:
        return 'Accepted';
      case PickupStatus.onTheWay:
        return 'On The Way';
      case PickupStatus.arrived:
        return 'Arrived';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Returns the color for the status
  String get colorHex {
    switch (this) {
      case PickupStatus.pending:
        return '#F39C12'; // Warning/Orange
      case PickupStatus.assigned:
        return '#9B59B6'; // Purple
      case PickupStatus.accepted:
        return '#03A9F4'; // Info/Blue
      case PickupStatus.onTheWay:
        return '#03A9F4'; // Info/Blue
      case PickupStatus.arrived:
        return '#2ECC71'; // Green
      case PickupStatus.completed:
        return '#27AE60'; // Success/Green
      case PickupStatus.cancelled:
        return '#E74C3C'; // Error/Red
    }
  }
}

/// Time slot for pickup scheduling (2-hour windows).
enum PickupTimeSlot {
  morning1, // 08:00 - 10:00
  morning2, // 10:00 - 12:00
  afternoon1, // 12:00 - 14:00
  afternoon2, // 14:00 - 16:00
  evening1, // 16:00 - 18:00
  evening2; // 18:00 - 20:00

  String get displayName {
    switch (this) {
      case PickupTimeSlot.morning1:
        return '08:00 - 10:00';
      case PickupTimeSlot.morning2:
        return '10:00 - 12:00';
      case PickupTimeSlot.afternoon1:
        return '12:00 - 14:00';
      case PickupTimeSlot.afternoon2:
        return '14:00 - 16:00';
      case PickupTimeSlot.evening1:
        return '16:00 - 18:00';
      case PickupTimeSlot.evening2:
        return '18:00 - 20:00';
    }
  }

  String get label {
    switch (this) {
      case PickupTimeSlot.morning1:
        return 'Early Morning';
      case PickupTimeSlot.morning2:
        return 'Late Morning';
      case PickupTimeSlot.afternoon1:
        return 'Early Afternoon';
      case PickupTimeSlot.afternoon2:
        return 'Late Afternoon';
      case PickupTimeSlot.evening1:
        return 'Early Evening';
      case PickupTimeSlot.evening2:
        return 'Late Evening';
    }
  }

  String get apiValue {
    switch (this) {
      case PickupTimeSlot.morning1:
        return '08:00-10:00';
      case PickupTimeSlot.morning2:
        return '10:00-12:00';
      case PickupTimeSlot.afternoon1:
        return '12:00-14:00';
      case PickupTimeSlot.afternoon2:
        return '14:00-16:00';
      case PickupTimeSlot.evening1:
        return '16:00-18:00';
      case PickupTimeSlot.evening2:
        return '18:00-20:00';
    }
  }

  static PickupTimeSlot fromApiValue(String value) {
    switch (value) {
      case '08:00-10:00':
        return PickupTimeSlot.morning1;
      case '10:00-12:00':
        return PickupTimeSlot.morning2;
      case '12:00-14:00':
        return PickupTimeSlot.afternoon1;
      case '14:00-16:00':
        return PickupTimeSlot.afternoon2;
      case '16:00-18:00':
        return PickupTimeSlot.evening1;
      case '18:00-20:00':
        return PickupTimeSlot.evening2;
      default:
        return PickupTimeSlot.morning1;
    }
  }
}

/// Recurrence frequency for recurring pickups.
enum RecurrenceFrequency {
  weekly,
  biweekly;

  String get displayName {
    switch (this) {
      case RecurrenceFrequency.weekly:
        return 'Every Week';
      case RecurrenceFrequency.biweekly:
        return 'Every 2 Weeks';
    }
  }
}

/// Offer status enumeration.
enum OfferStatus {
  pending,
  accepted,
  rejected,
  expired;

  String get displayName {
    switch (this) {
      case OfferStatus.pending:
        return 'Pending';
      case OfferStatus.accepted:
        return 'Accepted';
      case OfferStatus.rejected:
        return 'Rejected';
      case OfferStatus.expired:
        return 'Expired';
    }
  }
}

/// Listing status enumeration.
enum ListingStatus {
  active,
  sold,
  inactive;

  String get displayName {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.sold:
        return 'Sold';
      case ListingStatus.inactive:
        return 'Inactive';
    }
  }
}

/// Notification type enumeration.
enum NotificationType {
  newOffer,
  offerAccepted,
  offerRejected,
  pickupAccepted,
  pickupStatusUpdate,
  pickupCompleted,
  newMessage,
  ecoMilestone,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.newOffer:
        return 'New Offer';
      case NotificationType.offerAccepted:
        return 'Offer Accepted';
      case NotificationType.offerRejected:
        return 'Offer Rejected';
      case NotificationType.pickupAccepted:
        return 'Pickup Accepted';
      case NotificationType.pickupStatusUpdate:
        return 'Pickup Status Update';
      case NotificationType.pickupCompleted:
        return 'Pickup Completed';
      case NotificationType.newMessage:
        return 'New Message';
      case NotificationType.ecoMilestone:
        return 'Eco Milestone';
      case NotificationType.general:
        return 'Notification';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.newOffer:
        return 'local_offer';
      case NotificationType.offerAccepted:
        return 'check_circle';
      case NotificationType.offerRejected:
        return 'cancel';
      case NotificationType.pickupAccepted:
        return 'local_shipping';
      case NotificationType.pickupStatusUpdate:
        return 'location_on';
      case NotificationType.pickupCompleted:
        return 'check_circle';
      case NotificationType.newMessage:
        return 'message';
      case NotificationType.ecoMilestone:
        return 'eco';
      case NotificationType.general:
        return 'notifications';
    }
  }
}

/// Eco badge type enumeration.
enum EcoBadgeType {
  beginner,
  bronze,
  silver,
  gold,
  platinum,
  champion;

  String get displayName {
    switch (this) {
      case EcoBadgeType.beginner:
        return 'Beginner';
      case EcoBadgeType.bronze:
        return 'Bronze';
      case EcoBadgeType.silver:
        return 'Silver';
      case EcoBadgeType.gold:
        return 'Gold';
      case EcoBadgeType.platinum:
        return 'Platinum';
      case EcoBadgeType.champion:
        return 'Champion';
    }
  }

  int get requiredPoints {
    switch (this) {
      case EcoBadgeType.beginner:
        return 0;
      case EcoBadgeType.bronze:
        return 100;
      case EcoBadgeType.silver:
        return 500;
      case EcoBadgeType.gold:
        return 1000;
      case EcoBadgeType.platinum:
        return 5000;
      case EcoBadgeType.champion:
        return 10000;
    }
  }
}

/// Message status enumeration.
enum MessageStatus {
  sent,
  delivered,
  read;

  String get displayName {
    switch (this) {
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
    }
  }
}
