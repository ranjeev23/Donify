import 'package:isar/isar.dart';

part 'user_preferences.g.dart';

@collection
class UserPreferences {
  Id id = 0; // Single record, always id = 0

  int wakeUpHour = 7;
  int wakeUpMinute = 0;

  int sleepHour = 23;
  int sleepMinute = 0;

  bool onboardingCompleted = false;

  DateTime get wakeUpTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, wakeUpHour, wakeUpMinute);
  }

  DateTime get sleepTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
  }

  DateTime wakeUpTimeForDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, wakeUpHour, wakeUpMinute);
  }

  DateTime sleepTimeForDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, sleepHour, sleepMinute);
  }
}
