import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin _notif = FlutterLocalNotificationsPlugin();

/// Top-level alarm callback so it can be invoked from background isolate
@pragma('vm:entry-point')
Future<void> alarmCallback(int id) async {
  // debug log for verification
  print('ALARM callback called id=$id');
  // initialize local notifications in this isolate if necessary
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: ios);
  await _notif.initialize(initSettings);

  final androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarm',
    channelDescription: 'Alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  final details = NotificationDetails(android: androidDetails);
  await _notif.show(id, 'Alarm', 'Wake up!', details);
}

class AlarmService {
  static Future<void> init() async {
    // request notification permission (Android 13+, iOS)
    try {
      await Permission.notification.request();
    } catch (e) {
      // ignore if platform doesn't support
    }

    // initialize local notifications in main isolate
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _notif.initialize(initSettings);

    // initialize alarm manager (background isolates)
    await AndroidAlarmManager.initialize();
  }

  /// schedule a one-shot alarm after [seconds]
  static Future<void> scheduleAlarmInSeconds(int id, int seconds) async {
    final now = DateTime.now();
    final dt = now.add(Duration(seconds: seconds));
    print('Scheduling alarm id=$id at $dt (in ${seconds}s)');
    await AndroidAlarmManager.oneShotAt(dt, id, alarmCallback, exact: true, wakeup: true);
  }

  static Future<void> cancel(int id) async {
    print('Cancel alarm id=$id');
    await AndroidAlarmManager.cancel(id);
  }
}
