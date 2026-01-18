import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/data/models/user_preferences.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/data/models/expense.dart';
import 'package:remindlyf/data/models/expense_category.dart';
import 'package:remindlyf/data/models/income.dart';
import 'package:remindlyf/core/services/notification_service.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();
  late Future<Isar> db;

  factory TaskRepository() {
    return _instance;
  }

  TaskRepository._internal() {
    db = openDB();
    _initWatchers();
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
          ExpenseSchema,
          ExpenseCategorySchema,
          IncomeSchema,
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
    _triggerAutoBackup();
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
    _triggerAutoBackup();
  }

  Future<void> deleteTask(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
    await NotificationService().cancelNotification(id);
    _triggerAutoBackup();
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
    _triggerAutoBackup();
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
    _triggerAutoBackup();
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
    _triggerAutoBackup();
  }

  Future<void> updateCategory(SubscriptionCategory category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.subscriptionCategorys.put(category);
    });
    _triggerAutoBackup();
  }

  Future<void> deleteCategory(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.subscriptionCategorys.delete(id);
    });
    _triggerAutoBackup();
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
    _triggerAutoBackup();
  }

  /// Update a subscription and its reminder task(s)
  Future<void> updateSubscription(Subscription subscription) async {
    final isar = await db;

    // Delete all old reminder tasks if they exist
    for (final taskId in subscription.linkedTaskIds) {
      await deleteTask(taskId);
    }
    // Also check the deprecated linkedTaskId for backwards compatibility
    if (subscription.linkedTaskId != null &&
        !subscription.linkedTaskIds.contains(subscription.linkedTaskId)) {
      await deleteTask(subscription.linkedTaskId!);
    }

    // Clear the task IDs
    subscription.linkedTaskIds = [];
    subscription.linkedTaskId = null;

    // Update the subscription
    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });

    // Create new reminder task(s) if subscription is active
    if (subscription.isActive) {
      await _createOrUpdateReminderTask(subscription);
    }
    _triggerAutoBackup();
  }

  /// Delete a subscription and ALL its linked reminder tasks (cascade delete)
  Future<void> deleteSubscription(Id id) async {
    final isar = await db;

    // Get the subscription to find all linked tasks
    final subscription = await isar.subscriptions.get(id);
    if (subscription != null) {
      // Delete all linked tasks (cascade delete)
      for (final taskId in subscription.linkedTaskIds) {
        await deleteTask(taskId);
      }
      // Also check backwards compatible linkedTaskId
      if (subscription.linkedTaskId != null &&
          !subscription.linkedTaskIds.contains(subscription.linkedTaskId)) {
        await deleteTask(subscription.linkedTaskId!);
      }
    }

    await isar.writeTxn(() async {
      await isar.subscriptions.delete(id);
    });
    _triggerAutoBackup();
  }

  /// Create or update the reminder task(s) for a subscription
  /// For recurring subscriptions, creates multiple tasks for all occurrences
  /// Creates separate tasks for 1 year, 1 month, and 1 day before expiry
  Future<void> _createOrUpdateReminderTask(Subscription subscription) async {
    final isar = await db;

    // Get category for context
    final category = await getCategory(subscription.categoryId);
    final categoryName = category?.name ?? 'Reminder';

    // Get user preferences for wake up time
    final prefs = await getPreferences();
    final wakeUpHour = prefs.wakeUpHour;
    final wakeUpMinute = prefs.wakeUpMinute;

    // Calculate all reminder dates with labels based on recurrence type
    final reminders = _calculateReminderDatesWithLabels(subscription);
    final List<int> createdTaskIds = [];

    for (final reminder in reminders) {
      final reminderDate = reminder['date'] as DateTime;
      final label = reminder['label'] as String;
      final expiryDate = reminder['expiryDate'] as DateTime;

      // Skip past dates
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final reminderDay = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
      );
      if (reminderDay.isBefore(today)) continue;

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

        if (scheduledTime
                .add(const Duration(minutes: 30))
                .isBefore(taskStart) ||
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

      // Create contextual title based on when the reminder is scheduled
      String taskTitle;
      String taskDescription;

      if (label == 'tomorrow') {
        taskTitle = '🔴 $categoryName: ${subscription.name} expires tomorrow!';
        taskDescription =
            'URGENT: ${subscription.name} expires on ${_formatDate(expiryDate)}. Take action now!';
      } else if (label == '1 month before') {
        taskTitle = '🟠 $categoryName: ${subscription.name} expires in 1 month';
        taskDescription =
            '${subscription.name} will expire on ${_formatDate(expiryDate)}. Plan ahead!';
      } else {
        taskTitle = '🟡 $categoryName: ${subscription.name} expires in 1 year';
        taskDescription =
            '${subscription.name} will expire on ${_formatDate(expiryDate)}. Mark your calendar.';
      }

      // Create the task
      final task = Task()
        ..title = taskTitle
        ..dueDate = scheduledTime
        ..durationMinutes = 30
        ..isSubscriptionReminder = true
        ..subscriptionId = subscription.id
        ..description = subscription.description ?? taskDescription
        ..category = 'subscription';

      await addTask(task);
      createdTaskIds.add(task.id);
    }

    // Link all tasks back to the subscription
    subscription.linkedTaskIds = createdTaskIds;
    if (createdTaskIds.isNotEmpty) {
      subscription.linkedTaskId =
          createdTaskIds.first; // Keep backwards compatibility
    }
    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });
  }

  /// Helper to format dates nicely
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Calculate all reminder dates based on recurrence type
  /// Now creates reminders at: 1 year, 1 month, and 1 day before expiry
  List<Map<String, dynamic>> _calculateReminderDatesWithLabels(
    Subscription subscription,
  ) {
    final List<Map<String, dynamic>> reminders = [];
    final baseExpiryDate = subscription.expiryDate;

    // No reminders for document-only items (no expiry date)
    if (baseExpiryDate == null) {
      return reminders;
    }

    // Helper to add multi-level reminders for a single expiry date
    void addRemindersForExpiry(DateTime expiryDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 1 year before expiry (if applicable)
      final oneYearBefore = DateTime(
        expiryDate.year - 1,
        expiryDate.month,
        expiryDate.day,
      );
      if (!oneYearBefore.isBefore(today)) {
        reminders.add({
          'date': oneYearBefore,
          'label': '1 year before',
          'expiryDate': expiryDate,
        });
      }

      // 1 month before expiry
      final oneMonthBefore = DateTime(
        expiryDate.year,
        expiryDate.month - 1,
        expiryDate.day,
      );
      if (!oneMonthBefore.isBefore(today)) {
        reminders.add({
          'date': oneMonthBefore,
          'label': '1 month before',
          'expiryDate': expiryDate,
        });
      }

      // 1 day before expiry
      final oneDayBefore = expiryDate.subtract(const Duration(days: 1));
      if (!oneDayBefore.isBefore(today)) {
        reminders.add({
          'date': oneDayBefore,
          'label': 'tomorrow',
          'expiryDate': expiryDate,
        });
      }
    }

    switch (subscription.recurrenceType) {
      case RecurrenceType.once:
        // Single set of reminders for the expiry date
        addRemindersForExpiry(baseExpiryDate);
        break;

      case RecurrenceType.monthly:
        // Create reminders for the next 12 month cycles
        for (int i = 0; i < 12; i++) {
          final expiryDate = DateTime(
            baseExpiryDate.year,
            baseExpiryDate.month + i,
            baseExpiryDate.day,
            baseExpiryDate.hour,
            baseExpiryDate.minute,
          );
          addRemindersForExpiry(expiryDate);
        }
        break;

      case RecurrenceType.yearly:
        // Create reminders for this year and next year
        addRemindersForExpiry(baseExpiryDate);
        final nextYearExpiry = DateTime(
          baseExpiryDate.year + 1,
          baseExpiryDate.month,
          baseExpiryDate.day,
          baseExpiryDate.hour,
          baseExpiryDate.minute,
        );
        addRemindersForExpiry(nextYearExpiry);
        break;

      case RecurrenceType.custom:
        // Create reminders based on custom interval for up to 1 year
        final intervalDays = subscription.customIntervalDays;
        DateTime currentExpiry = baseExpiryDate;
        final oneYearFromNow = DateTime.now().add(const Duration(days: 365));

        while (currentExpiry.isBefore(oneYearFromNow)) {
          addRemindersForExpiry(currentExpiry);
          currentExpiry = currentExpiry.add(Duration(days: intervalDays));
        }
        break;
    }

    // Sort by date (earliest first) and remove duplicates
    reminders.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    return reminders;
  }

  /// Legacy method for backwards compatibility - calculates just dates
  List<DateTime> _calculateReminderDates(Subscription subscription) {
    final remindersWithLabels = _calculateReminderDatesWithLabels(subscription);
    return remindersWithLabels.map((r) => r['date'] as DateTime).toList();
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

  // ==================== EXPENSE CATEGORY METHODS ====================

  Future<List<ExpenseCategory>> getAllExpenseCategories() async {
    final isar = await db;
    return await isar.expenseCategorys.where().findAll();
  }

  Future<List<ExpenseCategory>> getExpenseCategoriesByType(
    ExpenseType type,
  ) async {
    final isar = await db;
    return await isar.expenseCategorys
        .where()
        .filter()
        .typeEqualTo(type)
        .and()
        .isActiveEqualTo(true)
        .findAll();
  }

  Future<ExpenseCategory?> getExpenseCategory(Id id) async {
    final isar = await db;
    return await isar.expenseCategorys.get(id);
  }

  Future<void> addExpenseCategory(ExpenseCategory category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenseCategorys.put(category);
    });
    _triggerAutoBackup();
  }

  Future<void> updateExpenseCategory(ExpenseCategory category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenseCategorys.put(category);
    });
    _triggerAutoBackup();
  }

  Future<void> deleteExpenseCategory(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenseCategorys.delete(id);
    });
    _triggerAutoBackup();
  }

  Stream<List<ExpenseCategory>> watchExpenseCategories() async* {
    final isar = await db;
    yield* isar.expenseCategorys.where().watch(fireImmediately: true);
  }

  // ==================== EXPENSE METHODS ====================

  Future<List<Expense>> getAllExpenses() async {
    final isar = await db;
    return await isar.expenses.where().sortByExpenseDateDesc().findAll();
  }

  Future<Expense?> getExpense(Id id) async {
    final isar = await db;
    return await isar.expenses.get(id);
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    final isar = await db;
    return await isar.expenses
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .sortByExpenseDateDesc()
        .findAll();
  }

  Future<List<Expense>> getExpensesByTask(int taskId) async {
    final isar = await db;
    return await isar.expenses.where().filter().taskIdEqualTo(taskId).findAll();
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final isar = await db;
    return await isar.expenses
        .where()
        .filter()
        .expenseDateBetween(start, end)
        .sortByExpenseDateDesc()
        .findAll();
  }

  Future<void> addExpense(Expense expense) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });
    _triggerAutoBackup();
  }

  Future<void> updateExpense(Expense expense) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });
    _triggerAutoBackup();
  }

  Future<void> deleteExpense(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.expenses.delete(id);
    });
    _triggerAutoBackup();
  }

  Stream<List<Expense>> watchExpenses() async* {
    final isar = await db;
    yield* isar.expenses.where().sortByExpenseDateDesc().watch(
      fireImmediately: true,
    );
  }

  // Get total expenses for a specific month
  Future<double> getMonthlyTotal(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    final expenses = await getExpensesByDateRange(startOfMonth, endOfMonth);
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  // Get expenses grouped by type for a date range
  Future<Map<ExpenseType, double>> getExpensesByType(
    DateTime start,
    DateTime end,
  ) async {
    final expenses = await getExpensesByDateRange(start, end);
    final categories = await getAllExpenseCategories();

    final Map<ExpenseType, double> result = {
      ExpenseType.needs: 0,
      ExpenseType.wants: 0,
      ExpenseType.savings: 0,
    };

    for (final expense in expenses) {
      if (expense.categoryId != null) {
        final category = categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => ExpenseCategory()..type = ExpenseType.needs,
        );
        result[category.type] = result[category.type]! + expense.amount;
      }
    }

    return result;
  }

  // ==================== INCOME METHODS ====================

  Future<List<Income>> getAllIncomes() async {
    final isar = await db;
    return await isar.incomes.where().sortByIncomeDateDesc().findAll();
  }

  Future<void> addIncome(Income income) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.incomes.put(income);
    });
    _triggerAutoBackup();
  }

  Future<void> updateIncome(Income income) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.incomes.put(income);
    });
    _triggerAutoBackup();
  }

  Future<void> deleteIncome(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.incomes.delete(id);
    });
    _triggerAutoBackup();
  }

  Stream<List<Income>> watchIncomes() async* {
    final isar = await db;
    yield* isar.incomes.where().sortByIncomeDateDesc().watch(
      fireImmediately: true,
    );
  }

  Future<List<Income>> getIncomesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final isar = await db;
    return await isar.incomes
        .where()
        .filter()
        .incomeDateBetween(start, end)
        .sortByIncomeDateDesc()
        .findAll();
  }

  Future<double> getMonthlyIncomeTotal(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    final incomes = await getIncomesByDateRange(startOfMonth, endOfMonth);
    return incomes.fold<double>(0.0, (sum, i) => sum + i.amount);
  }
  // ==================== BACKUP METHODS ====================

  Future<void> createBackup(String path) async {
    final isar = await db;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await isar.copyToFile(path);
    print('Backup created successfully at: $path');
  }

  Future<void> restoreBackup(File backupFile) async {
    final isar = await db;
    await isar.close(); // Close the current instance

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/default.isar';
    final dbFile = File(dbPath);

    // Overwrite the current DB with the backup
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await backupFile.copy(dbPath);

    // Re-open the DB
    db = openDB();
    _initWatchers(); // Re-init watchers after restore
  }

  // ==================== AUTO-BACKUP LOGIC ====================

  Timer? _backupTimer;
  final ValueNotifier<DateTime?> lastBackupTime = ValueNotifier(null);

  void _initWatchers() async {
    final isar = await db;

    // Listen to all collections
    isar.tasks.watchLazy().listen((_) => _triggerAutoBackup());
    isar.userPreferences.watchLazy().listen((_) => _triggerAutoBackup());
    isar.subscriptions.watchLazy().listen((_) => _triggerAutoBackup());
    isar.subscriptionCategorys.watchLazy().listen((_) => _triggerAutoBackup());
    isar.expenses.watchLazy().listen((_) => _triggerAutoBackup());
    isar.expenseCategorys.watchLazy().listen((_) => _triggerAutoBackup());
    isar.incomes.watchLazy().listen((_) => _triggerAutoBackup());
  }

  Future<void> _performBackup() async {
    try {
      print('Starting backup process...');
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/Backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final backupPath = '${backupDir.path}/latest_backup.isar';
      await createBackup(backupPath);

      // Attempt to copy to public Downloads folder on Android for persistence
      if (Platform.isAndroid) {
        try {
          final externalDir = Directory(
            '/storage/emulated/0/Download/RemindlyBackups',
          );
          if (!await externalDir.exists()) {
            await externalDir.create(recursive: true);
          }
          final externalPath = '${externalDir.path}/latest_backup.isar';
          final externalFile = File(externalPath);
          if (await externalFile.exists()) {
            await externalFile.delete();
          }
          await File(backupPath).copy(externalPath);
          print('External backup created at: $externalPath');
        } catch (e) {
          print('External backup failed (permission issue?): $e');
        }
      }

      final now = DateTime.now();
      lastBackupTime.value = now;
      print('Backup completed successfully: $backupPath at $now');
    } catch (e) {
      print('Backup failed: $e');
      rethrow;
    }
  }

  Future<void> forceBackupNow() async {
    print('Forcing manual backup...');
    _backupTimer?.cancel();
    await _performBackup();
  }

  void _triggerAutoBackup() {
    print('Auto-backup triggered (debouncing...)');
    // Debounce: Cancel previous timer and start a new one
    _backupTimer?.cancel();
    _backupTimer = Timer(const Duration(seconds: 1), () async {
      await _performBackup();
    });
  }

  Future<Map<String, List<dynamic>>> inspectBackup(File backupFile) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final inspectDir = Directory('${dir.path}/inspector_$timestamp');
    await inspectDir.create(recursive: true);

    try {
      final instanceName = 'inspector_$timestamp';
      final dbPath = '${inspectDir.path}/$instanceName.isar';
      await backupFile.copy(dbPath);

      final isar = await Isar.open(
        [
          TaskSchema,
          UserPreferencesSchema,
          SubscriptionSchema,
          SubscriptionCategorySchema,
          ExpenseSchema,
          ExpenseCategorySchema,
          IncomeSchema,
        ],
        directory: inspectDir.path,
        name: instanceName,
      );

      final tasks = await isar.tasks.where().findAll();
      final expenses = await isar.expenses.where().findAll();
      final subscriptions = await isar.subscriptions.where().findAll();
      final incomes = await isar.incomes.where().findAll();

      await isar.close();

      return {
        'Tasks': tasks,
        'Expenses': expenses,
        'Subscriptions': subscriptions,
        'Incomes': incomes,
      };
    } finally {
      if (await inspectDir.exists()) {
        await inspectDir.delete(recursive: true);
      }
    }
  }
}
