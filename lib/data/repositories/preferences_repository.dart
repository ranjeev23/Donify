import 'package:isar/isar.dart';
import 'package:remindlyf/data/models/user_preferences.dart';

class PreferencesRepository {
  final Isar _isar;

  PreferencesRepository(this._isar);

  Future<UserPreferences> getPreferences() async {
    final prefs = await _isar.userPreferences.get(0);
    if (prefs == null) {
      // Create default preferences
      final defaultPrefs = UserPreferences();
      await _isar.writeTxn(() async {
        await _isar.userPreferences.put(defaultPrefs);
      });
      return defaultPrefs;
    }
    return prefs;
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await _isar.writeTxn(() async {
      await _isar.userPreferences.put(prefs);
    });
  }

  Future<void> setWakeUpTime(int hour, int minute) async {
    final prefs = await getPreferences();
    prefs.wakeUpHour = hour;
    prefs.wakeUpMinute = minute;
    await savePreferences(prefs);
  }

  Future<void> setSleepTime(int hour, int minute) async {
    final prefs = await getPreferences();
    prefs.sleepHour = hour;
    prefs.sleepMinute = minute;
    await savePreferences(prefs);
  }

  Future<void> completeOnboarding() async {
    final prefs = await getPreferences();
    prefs.onboardingCompleted = true;
    await savePreferences(prefs);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await getPreferences();
    return prefs.onboardingCompleted;
  }

  Stream<UserPreferences?> watchPreferences() {
    return _isar.userPreferences.watchObject(0);
  }
}
