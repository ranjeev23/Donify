import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsMacOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions and create channel for Android
    if (Platform.isAndroid) {
      await _setupAndroid();
    }
  }

  Future<void> _setupAndroid() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Create notification channel explicitly
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'remindly_channel',
        'Reminders',
        description: 'Task reminders and notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(channel);

      // Request notification permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();

      // Check if exact alarms are permitted
      final canScheduleExact = await androidPlugin
          .canScheduleExactNotifications();
      print('Can schedule exact notifications: $canScheduleExact');

      if (canScheduleExact != true) {
        // Request exact alarm permission (Android 12+)
        // This opens the system settings for Alarms & Reminders
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  // Check if exact alarms are permitted (call this before scheduling)
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final result = await androidPlugin.canScheduleExactNotifications();
      return result ?? false;
    }
    return false;
  }

  // Open alarm permission settings
  Future<void> openAlarmPermissionSettings() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // Show notification immediately (for testing and immediate tasks)
  Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'remindly_channel',
            'Reminders',
            channelDescription: 'Task reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
      );
      print('Notification shown immediately: $title');
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print(
      'Scheduling notification for: $scheduledDate (now: ${DateTime.now()})',
    );

    // If scheduled time is in the past or within 5 seconds, show immediately
    if (scheduledDate.isBefore(
      DateTime.now().add(const Duration(seconds: 5)),
    )) {
      print('Scheduled time is very soon or past, showing immediately');
      await showNotificationNow(id: id, title: title, body: body);
      return;
    }

    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      print('Scheduling notification at TZ time: $tzScheduledDate');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'remindly_channel',
            'Reminders',
            channelDescription: 'Task reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification scheduled successfully for $scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to inexact if exact is not permitted
      if (e.toString().contains('exact_alarms_not_permitted')) {
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'remindly_channel',
                'Reminders',
                channelDescription: 'Task reminders',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
              iOS: DarwinNotificationDetails(),
              macOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          print('Inexact notification scheduled for $scheduledDate');
        } catch (e2) {
          print('Error scheduling inexact notification: $e2');
        }
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
