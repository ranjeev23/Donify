import 'package:isar/isar.dart';

part 'subscription.g.dart';

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  late String name; // "Netflix", "Passport", etc.

  late int categoryId; // Link to SubscriptionCategory

  late DateTime expiryDate; // Expiry/renewal date

  String? description; // Optional notes (hidden by default in UI)

  int reminderDays = 1; // Days before expiry to create reminder task

  int? linkedTaskId; // Task ID for the auto-generated reminder task

  bool isActive = true; // Track if subscription is still being tracked

  // Helper to get the reminder date (day before expiry by default)
  DateTime get reminderDate {
    return expiryDate.subtract(Duration(days: reminderDays));
  }

  // Check if expiry is today
  bool get isExpiringToday {
    final now = DateTime.now();
    return expiryDate.year == now.year &&
        expiryDate.month == now.month &&
        expiryDate.day == now.day;
  }

  // Check if already expired
  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.isBefore(today);
  }

  // Days remaining until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // Create a copy with optional modifications
  Subscription copyWith({
    Id? id,
    String? name,
    int? categoryId,
    DateTime? expiryDate,
    String? description,
    int? reminderDays,
    int? linkedTaskId,
    bool? isActive,
  }) {
    return Subscription()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..categoryId = categoryId ?? this.categoryId
      ..expiryDate = expiryDate ?? this.expiryDate
      ..description = description ?? this.description
      ..reminderDays = reminderDays ?? this.reminderDays
      ..linkedTaskId = linkedTaskId ?? this.linkedTaskId
      ..isActive = isActive ?? this.isActive;
  }
}
