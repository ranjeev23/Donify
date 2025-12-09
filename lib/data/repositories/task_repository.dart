import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/data/models/user_preferences.dart';
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
        [TaskSchema, UserPreferencesSchema],
        directory: dir.path,
        inspector: !isRelease, // Disable inspector in release mode
      );
    }
    return Future.value(Isar.getInstance());
  }

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

  // User Preferences methods
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
}
