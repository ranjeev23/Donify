import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;

  // Start time of the task
  DateTime? dueDate;

  // Duration in minutes
  int durationMinutes = 30;

  bool isCompleted = false;

  // Fixed tasks cannot be moved by the scheduler
  bool isFixed = false;

  // Draft tasks are ideas that don't go into the timeline
  bool isDraft = false;

  String? category;

  // Task description/notes
  String? description;

  // Subscription reminder fields
  bool isSubscriptionReminder =
      false; // True if auto-generated from subscription
  int? subscriptionId; // Link back to the source subscription

  // Completion details (optional)
  String? completionNote;
  String? completionPhotoPath;
  DateTime? completedAt;

  // Helper to get end time
  DateTime? get endTime {
    if (dueDate == null) return null;
    return dueDate!.add(Duration(minutes: durationMinutes));
  }

  // Create a copy of the task
  Task copyWith({
    Id? id,
    String? title,
    DateTime? dueDate,
    int? durationMinutes,
    bool? isCompleted,
    bool? isFixed,
    bool? isDraft,
    String? category,
    String? description,
    bool? isSubscriptionReminder,
    int? subscriptionId,
    String? completionNote,
    String? completionPhotoPath,
    DateTime? completedAt,
  }) {
    return Task()
      ..id = id ?? this.id
      ..title = title ?? this.title
      ..dueDate = dueDate ?? this.dueDate
      ..durationMinutes = durationMinutes ?? this.durationMinutes
      ..isCompleted = isCompleted ?? this.isCompleted
      ..isFixed = isFixed ?? this.isFixed
      ..isDraft = isDraft ?? this.isDraft
      ..category = category ?? this.category
      ..description = description ?? this.description
      ..isSubscriptionReminder =
          isSubscriptionReminder ?? this.isSubscriptionReminder
      ..subscriptionId = subscriptionId ?? this.subscriptionId
      ..completionNote = completionNote ?? this.completionNote
      ..completionPhotoPath = completionPhotoPath ?? this.completionPhotoPath
      ..completedAt = completedAt ?? this.completedAt;
  }
}
