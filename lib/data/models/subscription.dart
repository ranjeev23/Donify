import 'package:isar/isar.dart';

part 'subscription.g.dart';

// Recurrence type enum stored as int
enum RecurrenceType {
  once, // 0 - One-time reminder
  monthly, // 1 - Every month on the same day
  yearly, // 2 - Every year on the same day
  custom, // 3 - Custom interval in days
}

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  late String name; // "Netflix", "Passport", etc.

  late int categoryId; // Link to SubscriptionCategory

  // Expiry date is now optional - can be null for document-only items
  DateTime? expiryDate;

  String? description; // Optional notes (hidden by default in UI)

  int reminderDays = 1; // Days before expiry to create reminder task

  int?
  linkedTaskId; // Task ID for the auto-generated reminder task (deprecated, use linkedTaskIds)

  // Recurrence fields
  @enumerated
  RecurrenceType recurrenceType = RecurrenceType.once;

  int customIntervalDays = 30; // For custom recurrence

  // List of all linked task IDs for recurring reminders
  List<int> linkedTaskIds = [];

  // Parent subscription ID (for identifying recurring instances)
  int? parentSubscriptionId;

  // Parent folder ID for subfolder hierarchy (null = root level item)
  int? parentFolderId;

  // Is this a folder (subfolder) rather than an item?
  bool isFolder = false;

  bool isActive = true; // Track if subscription is still being tracked

  // Document photos - stored as file paths (persisted)
  List<String> documentPhotos = [];

  // PDF documents - stored as file paths (persisted)
  List<String> pdfDocuments = [];

  // Other documents (Excel, Word, etc.) - stored as file paths (persisted)
  List<String> otherDocuments = [];

  // Helper: Check if this is a document-only item (no expiry tracking)
  bool get isDocumentOnly => expiryDate == null;

  // Helper: Check if has documents
  bool get hasDocuments =>
      documentPhotos.isNotEmpty ||
      pdfDocuments.isNotEmpty ||
      otherDocuments.isNotEmpty;

  // Helper: Get all file count
  int get totalFileCount =>
      documentPhotos.length + pdfDocuments.length + otherDocuments.length;

  // Helper to get recurrence label
  String get recurrenceLabel {
    if (expiryDate == null) return 'Document';
    switch (recurrenceType) {
      case RecurrenceType.once:
        return 'One-time';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Every $customIntervalDays days';
    }
  }

  // Helper to get the reminder date (day before expiry by default)
  DateTime? get reminderDate {
    if (expiryDate == null) return null;
    return expiryDate!.subtract(Duration(days: reminderDays));
  }

  // Check if expiry is today
  bool get isExpiringToday {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    return expiryDate!.year == now.year &&
        expiryDate!.month == now.month &&
        expiryDate!.day == now.day;
  }

  // Check if already expired
  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    return expiry.isBefore(today);
  }

  // Days remaining until expiry
  int get daysUntilExpiry {
    if (expiryDate == null) return 999; // Large number for document-only
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    return expiry.difference(today).inDays;
  }

  // Create a copy with optional modifications
  Subscription copyWith({
    Id? id,
    String? name,
    int? categoryId,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    String? description,
    int? reminderDays,
    int? linkedTaskId,
    RecurrenceType? recurrenceType,
    int? customIntervalDays,
    List<int>? linkedTaskIds,
    int? parentSubscriptionId,
    int? parentFolderId,
    bool clearParentFolderId = false,
    bool? isFolder,
    bool? isActive,
    List<String>? documentPhotos,
    List<String>? pdfDocuments,
    List<String>? otherDocuments,
  }) {
    return Subscription()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..categoryId = categoryId ?? this.categoryId
      ..expiryDate = clearExpiryDate ? null : (expiryDate ?? this.expiryDate)
      ..description = description ?? this.description
      ..reminderDays = reminderDays ?? this.reminderDays
      ..linkedTaskId = linkedTaskId ?? this.linkedTaskId
      ..recurrenceType = recurrenceType ?? this.recurrenceType
      ..customIntervalDays = customIntervalDays ?? this.customIntervalDays
      ..linkedTaskIds = linkedTaskIds ?? List.from(this.linkedTaskIds)
      ..parentSubscriptionId = parentSubscriptionId ?? this.parentSubscriptionId
      ..parentFolderId = clearParentFolderId
          ? null
          : (parentFolderId ?? this.parentFolderId)
      ..isFolder = isFolder ?? this.isFolder
      ..isActive = isActive ?? this.isActive
      ..documentPhotos = documentPhotos ?? List.from(this.documentPhotos)
      ..pdfDocuments = pdfDocuments ?? List.from(this.pdfDocuments)
      ..otherDocuments = otherDocuments ?? List.from(this.otherDocuments);
  }
}
