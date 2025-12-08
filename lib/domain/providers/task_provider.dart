import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/data/models/user_preferences.dart';
import 'package:remindlyf/data/repositories/task_repository.dart';

part 'task_provider.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) => TaskRepository();

@riverpod
Stream<List<Task>> tasks(TasksRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final isar = await repository.db;

  yield* isar.tasks.where().sortByIsCompleted().thenByDueDate().watch(
    fireImmediately: true,
  );
}

// Provider to track currently selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Provider to get tasks for a specific date
@riverpod
Stream<List<Task>> tasksByDate(TasksByDateRef ref, DateTime date) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final isar = await repository.db;

  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  yield* isar.tasks
      .where()
      .filter()
      .dueDateBetween(startOfDay, endOfDay, includeUpper: false)
      .or()
      .dueDateIsNull()
      .sortByIsCompleted()
      .thenByDueDate()
      .watch(fireImmediately: true);
}

// Provider to get tasks grouped by date
@riverpod
Stream<Map<DateTime, List<Task>>> tasksGroupedByDate(
  TasksGroupedByDateRef ref,
) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final isar = await repository.db;

  yield* isar.tasks.where().sortByDueDate().watch(fireImmediately: true).map((
    tasks,
  ) {
    final Map<DateTime, List<Task>> grouped = {};

    for (final task in tasks) {
      final date = task.dueDate != null
          ? DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
          : DateTime(2099, 12, 31); // No date tasks go to the end

      grouped.putIfAbsent(date, () => []).add(task);
    }

    return grouped;
  });
}

// User Preferences Provider
@riverpod
Stream<UserPreferences?> userPreferences(UserPreferencesRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchPreferences();
}

// Sync provider to get current preferences
@riverpod
Future<UserPreferences> currentPreferences(CurrentPreferencesRef ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getPreferences();
}
