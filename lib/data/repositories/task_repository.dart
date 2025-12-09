import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/data/models/user_preferences.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/core/services/notification_service.dart';

class TaskRepository {
  late Future<Isar> db;

  TaskRepository() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      const isRelease = bool.fromEnvironment('dart.vm.product');
      return await Isar.open(
        [
          TaskSchema,
          UserPreferencesSchema,
          SubscriptionSchema,
          SubscriptionCategorySchema,
        ],
        directory: dir.path,
        inspector: !isRelease,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // ==================== TASK METHODS ====================

  Future<void> addTask(Task task) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    if (task.dueDate != null) {
      await NotificationService().scheduleNotification(
        id: task.id,
        title: task.title,
        body: 'Time to start: ${task.title}',
        scheduledDate: task.dueDate!,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    if (task.dueDate != null && !task.isCompleted) {
      await NotificationService().scheduleNotification(
        id: task.id,
        title: task.title,
        body: 'Time to start: ${task.title}',
        scheduledDate: task.dueDate!,
      );
    } else {
      await NotificationService().cancelNotification(task.id);
    }
  }

  Future<void> deleteTask(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
    await NotificationService().cancelNotification(id);
  }

  Future<List<Task>> getAllTasks() async {
    final isar = await db;
    return await isar.tasks.where().findAll();
  }

  Future<Task?> getTask(Id id) async {
    final isar = await db;
    return await isar.tasks.get(id);
  }

  Future<void> toggleTaskCompletion(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final task = await isar.tasks.get(id);
      if (task != null) {
        task.isCompleted = !task.isCompleted;
        await isar.tasks.put(task);

        if (task.isCompleted) {
          await NotificationService().cancelNotification(task.id);
        } else if (task.dueDate != null) {
          await NotificationService().scheduleNotification(
            id: task.id,
            title: task.title,
            body: 'Time to start: ${task.title}',
            scheduledDate: task.dueDate!,
          );
        }
      }
    });
  }

  // ==================== USER PREFERENCES METHODS ====================

  Future<UserPreferences> getPreferences() async {
    final isar = await db;
    final prefs = await isar.userPreferences.get(0);
    if (prefs == null) {
      final defaultPrefs = UserPreferences();
      await isar.writeTxn(() async {
        await isar.userPreferences.put(defaultPrefs);
      });
      return defaultPrefs;
    }
    return prefs;
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userPreferences.put(prefs);
    });
  }

  Stream<UserPreferences?> watchPreferences() async* {
    final isar = await db;
    yield* isar.userPreferences.watchObject(0, fireImmediately: true);
  }

  // ==================== SUBSCRIPTION CATEGORY METHODS ====================

  Future<List<SubscriptionCategory>> getAllCategories() async {
    final isar = await db;
    return await isar.subscriptionCategorys.where().findAll();
  }

  Future<SubscriptionCategory?> getCategory(Id id) async {
    final isar = await db;
    return await isar.subscriptionCategorys.get(id);
  }

  Future<void> addCategory(SubscriptionCategory category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.subscriptionCategorys.put(category);
    });
  }

  Future<void> updateCategory(SubscriptionCategory category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.subscriptionCategorys.put(category);
    });
  }

  Future<void> deleteCategory(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.subscriptionCategorys.delete(id);
    });
  }

  Stream<List<SubscriptionCategory>> watchCategories() async* {
    final isar = await db;
    yield* isar.subscriptionCategorys.where().watch(fireImmediately: true);
  }

  // Initialize default categories if none exist
  Future<void> initDefaultCategories() async {
    final isar = await db;
    final count = await isar.subscriptionCategorys.count();
    if (count == 0) {
      await isar.writeTxn(() async {
        await isar.subscriptionCategorys.putAll([
          SubscriptionCategory()
            ..name = 'OTT'
            ..iconName = 'tv'
            ..colorValue = 0xFFE91E63, // Pink
          SubscriptionCategory()
            ..name = 'Documents'
            ..iconName = 'description'
            ..colorValue = 0xFF2196F3, // Blue
          SubscriptionCategory()
            ..name = 'Finance'
            ..iconName = 'credit_card'
            ..colorValue = 0xFF4CAF50, // Green
          SubscriptionCategory()
            ..name = 'Travel'
            ..iconName = 'flight'
            ..colorValue = 0xFFFF9800, // Orange
        ]);
      });
    }
  }

  // ==================== SUBSCRIPTION METHODS ====================

  Future<List<Subscription>> getAllSubscriptions() async {
    final isar = await db;
    return await isar.subscriptions.where().findAll();
  }

  Future<Subscription?> getSubscription(Id id) async {
    final isar = await db;
    return await isar.subscriptions.get(id);
  }

  Future<List<Subscription>> getSubscriptionsByCategory(int categoryId) async {
    final isar = await db;
    return await isar.subscriptions
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();
  }

  Stream<List<Subscription>> watchSubscriptions() async* {
    final isar = await db;
    yield* isar.subscriptions.where().watch(fireImmediately: true);
  }

  /// Add a subscription and create its reminder task
  Future<void> addSubscription(Subscription subscription) async {
    final isar = await db;

    // Save the subscription first
    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });

    // Create the reminder task
    await _createOrUpdateReminderTask(subscription);
  }

  /// Update a subscription and its reminder task
  Future<void> updateSubscription(Subscription subscription) async {
    final isar = await db;

    // Delete old reminder task if exists
    if (subscription.linkedTaskId != null) {
      await deleteTask(subscription.linkedTaskId!);
    }

    // Update the subscription
    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });

    // Create new reminder task if subscription is active
    if (subscription.isActive) {
      await _createOrUpdateReminderTask(subscription);
    }
  }

  /// Delete a subscription and its linked reminder task
  Future<void> deleteSubscription(Id id) async {
    final isar = await db;

    // Get the subscription to find linked task
    final subscription = await isar.subscriptions.get(id);
    if (subscription?.linkedTaskId != null) {
      await deleteTask(subscription!.linkedTaskId!);
    }

    await isar.writeTxn(() async {
      await isar.subscriptions.delete(id);
    });
  }

  /// Create or update the reminder task for a subscription
  Future<void> _createOrUpdateReminderTask(Subscription subscription) async {
    final isar = await db;

    // Get category for context
    final category = await getCategory(subscription.categoryId);
    final categoryName = category?.name ?? 'Reminder';

    // Calculate reminder date (1 day before expiry by default)
    final reminderDate = subscription.reminderDate;

    // Get user preferences for wake up time
    final prefs = await getPreferences();
    final wakeUpHour = prefs.wakeUpHour;
    final wakeUpMinute = prefs.wakeUpMinute;

    // Get all tasks for that day to find next available slot
    final allTasks = await getAllTasks();
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null || t.isDraft) return false;
      return t.dueDate!.year == reminderDate.year &&
          t.dueDate!.month == reminderDate.month &&
          t.dueDate!.day == reminderDate.day;
    }).toList();

    // Sort by start time
    dayTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Find next available time slot (start from wake up time)
    DateTime scheduledTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      wakeUpHour,
      wakeUpMinute,
    );

    // Find a gap or schedule after the last task
    for (final task in dayTasks) {
      final taskStart = task.dueDate!;
      final taskEnd = task.endTime!;

      if (scheduledTime.add(const Duration(minutes: 30)).isBefore(taskStart) ||
          scheduledTime
              .add(const Duration(minutes: 30))
              .isAtSameMomentAs(taskStart)) {
        // Found a gap before this task
        break;
      }

      // Move scheduled time to after this task
      if (taskEnd.isAfter(scheduledTime)) {
        scheduledTime = taskEnd;
      }
    }

    // Create the task
    final task = Task()
      ..title = '⚠️ $categoryName: ${subscription.name} expiring tomorrow'
      ..dueDate = scheduledTime
      ..durationMinutes = 30
      ..isSubscriptionReminder = true
      ..subscriptionId = subscription.id
      ..description = subscription.description
      ..category = 'subscription';

    await addTask(task);

    // Link the task back to the subscription
    subscription.linkedTaskId = task.id;
    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });
  }

  /// Mark subscription as completed/renewed
  Future<void> markSubscriptionCompleted(
    Id id, {
    DateTime? newExpiryDate,
  }) async {
    final subscription = await getSubscription(id);
    if (subscription == null) return;

    if (newExpiryDate != null) {
      // Renew with new expiry date
      subscription.expiryDate = newExpiryDate;
      await updateSubscription(subscription);
    } else {
      // Mark as inactive
      subscription.isActive = false;
      if (subscription.linkedTaskId != null) {
        await deleteTask(subscription.linkedTaskId!);
        subscription.linkedTaskId = null;
      }
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.subscriptions.put(subscription);
      });
    }
  }
}
