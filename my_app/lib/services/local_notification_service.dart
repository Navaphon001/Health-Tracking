// lib/services/local_notification_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// ====== Background tap callback (ให้แอปรับเหตุการณ์ตอนผู้ใช้แตะแจ้งเตือน) ======
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse r) {
  // ignore: avoid_print
  print('[LNS] (bg) onTap id=${r.id} action=${r.actionId} payload=${r.payload}');
}

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ใช้ channel id ใหม่กัน cache เก่า
  static const _chRemindersId = 'reminders_v3';
  static const _chRemindersName = 'Reminders';
  static const _chRemindersDesc = 'Health reminders and bedtime alerts';

  static const _idWater10 = 11010;
  static const _idWater14 = 11014;
  static const _idWater18 = 11018;
  static const _idExercise = 12000;
  static const _idBedtime = 13000;

  static const _prefBedtimeOn = 'pref:bedtime:on';
  static const _prefBedtimeHour = 'pref:bedtime:hour';
  static const _prefBedtimeMin = 'pref:bedtime:min';
  static const _prefWindDownMin = 'pref:bedtime:winddown';

  static const _defaultBedtimeHour = 22;
  static const _defaultBedtimeMin = 0;
  static const _defaultWindDownMin = 60;

  /// เรียกครั้งเดียวตอนสตาร์ตแอป
  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final init = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (r) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[LNS] onTap id=${r.id} action=${r.actionId} payload=${r.payload}');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android 13+: ขอ permission ถ้า lib รองรับ
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      try {
        await (android as dynamic).requestPermission();
      } catch (_) {
        // lib เวอร์ชันที่ไม่มีเมธอดนี้ (ไม่เป็นไร)
      }
    }
  }

  /// ขอสิทธิ์แจ้งเตือน + Exact Alarms (ถ้าจำเป็นเปิดหน้า Settings ให้)
  Future<void> ensureAllNotifPerms({bool autoOpenSettings = false}) async {
    if (!Platform.isAndroid) return;

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    try {
      // 1) POST_NOTIFICATIONS
      bool? notificationsAllowed;
      try {
        notificationsAllowed = await (android as dynamic).areNotificationsEnabled();
      } catch (_) {}
      if (notificationsAllowed == false) {
        try {
          await (android as dynamic).requestPermission();
        } catch (_) {}
      }

      // 2) Exact alarms
      bool? canExact;
      try {
        canExact = await (android as dynamic).canScheduleExactAlarms();
      } catch (_) {}
      if (canExact == false) {
        try {
          await (android as dynamic).requestExactAlarmsPermission();
        } catch (_) {}
        try {
          canExact = await (android as dynamic).canScheduleExactAlarms();
        } catch (_) {}
        if (autoOpenSettings && canExact == false) {
          try {
            await (android as dynamic).openScheduleExactAlarmSettings();
          } catch (_) {}
        }
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] ensureAllNotifPerms => notificationsAllowed=$notificationsAllowed canExact=$canExact');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] ensureAllNotifPerms error: $e');
      }
    }
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _chRemindersId,
      _chRemindersName,
      channelDescription: _chRemindersDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  // ===== Helpers =====
  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  tz.TZDateTime _nextBedtimeWindDown(int hour, int minute, int windDown) {
    final now = tz.TZDateTime.now(tz.local);
    var bedtime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!bedtime.isAfter(now)) bedtime = bedtime.add(const Duration(days: 1));
    var remindAt = bedtime.subtract(Duration(minutes: windDown));
    if (!remindAt.isAfter(now)) {
      bedtime = bedtime.add(const Duration(days: 1));
      remindAt = bedtime.subtract(Duration(minutes: windDown));
    }
    return remindAt;
  }

  Future<void> _zonedScheduleSafe({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    DateTimeComponents? match,
  }) async {
    try {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] try schedule id=$id now=${DateTime.now()} target=${when.toLocal()} (match=$match)');
      }
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details(),
        androidScheduleMode:
            kDebugMode ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: match,
      );
      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] ✅ scheduled id=$id at ${when.toLocal()} (mode=${kDebugMode ? 'alarmClock' : 'exact'})');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] Fallback→INEXACT id=$id err=$e');
      }
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: match,
      );
    }
  }

  // ===== Exact alarm settings =====
  Future<void> openExactAlarmSettingsIfAvailable() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      await (android as dynamic).openScheduleExactAlarmSettings();
    } catch (_) {}
  }

  // ===== Public APIs =====
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await ensureAllNotifPerms();
    final when = _nextTime(hour, minute);
    await _zonedScheduleSafe(
      id: id,
      title: title,
      body: body,
      when: when,
      match: DateTimeComponents.time,
    );
  }

  // Bedtime
  Future<void> setBedtime({
    required int hour,
    required int minute,
    int windDownMinutes = _defaultWindDownMin,
    bool enabled = true,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_prefBedtimeOn, enabled);
    await sp.setInt(_prefBedtimeHour, hour);
    await sp.setInt(_prefBedtimeMin, minute);
    await sp.setInt(_prefWindDownMin, windDownMinutes);
    await _scheduleBedtimeFromPrefs();
  }

  Future<({bool enabled, int hour, int minute, int windDown})?> getBedtime() async {
    final sp = await SharedPreferences.getInstance();
    final hasAny =
        sp.containsKey(_prefBedtimeOn) || sp.containsKey(_prefBedtimeHour) || sp.containsKey(_prefBedtimeMin);
    if (!hasAny) return null;
    return (
      enabled: sp.getBool(_prefBedtimeOn) ?? true,
      hour: sp.getInt(_prefBedtimeHour) ?? _defaultBedtimeHour,
      minute: sp.getInt(_prefBedtimeMin) ?? _defaultBedtimeMin,
      windDown: sp.getInt(_prefWindDownMin) ?? _defaultWindDownMin,
    );
  }

  Future<void> disableBedtimeReminder() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_prefBedtimeOn, false);
    await _plugin.cancel(_idBedtime);
  }

  Future<void> _scheduleBedtimeFromPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final on = sp.getBool(_prefBedtimeOn) ?? true;
    final hour = sp.getInt(_prefBedtimeHour) ?? _defaultBedtimeHour;
    final min = sp.getInt(_prefBedtimeMin) ?? _defaultBedtimeMin;
    final wd = sp.getInt(_prefWindDownMin) ?? _defaultWindDownMin;

    await _plugin.cancel(_idBedtime);
    if (!on) return;

    await ensureAllNotifPerms();

    final remindAt = _nextBedtimeWindDown(hour, min, wd);
    if (kDebugMode) {
      final target = tz.TZDateTime(tz.local, remindAt.year, remindAt.month, remindAt.day, hour, min);
      // ignore: avoid_print
      print('[LNS] bedtime target=${target.toLocal()} windDown=$wd → remindAt=${remindAt.toLocal()}');
    }
    await _zonedScheduleSafe(
      id: _idBedtime,
      title: 'เตรียมตัวเข้านอน 🌙',
      body: 'อีก $wd นาทีจะถึงเวลาเข้านอน',
      when: remindAt,
      match: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDefaults() async {
    await cancelDefaults();
    await ensureAllNotifPerms();
    await scheduleDaily(
      id: _idWater10,
      hour: 10,
      minute: 0,
      title: 'ถึงเวลาเติมน้ำ 💧',
      body: 'จิบน้ำสักแก้วดีไหม',
    );
    await scheduleDaily(
      id: _idWater14,
      hour: 14,
      minute: 0,
      title: 'พักสายตาแล้วดื่มน้ำ',
      body: 'เติมน้ำเพื่อความสดชื่น',
    );
    await scheduleDaily(
      id: _idWater18,
      hour: 18,
      minute: 0,
      title: 'เย็นนี้อย่าลืมน้ำ',
      body: 'อีกแก้วก่อนมื้อเย็น',
    );
    await scheduleDaily(
      id: _idExercise,
      hour: 19,
      minute: 0,
      title: 'ขยับร่างกายหน่อย 🏃',
      body: 'เดิน/ยืดเส้น 10–15 นาที',
    );
    await _scheduleBedtimeFromPrefs();
    if (kDebugMode) {
      // ignore: avoid_print
      print('[LNS] scheduled defaults');
    }
  }

  Future<void> cancelDefaults() async {
    await _plugin.cancel(_idWater10);
    await _plugin.cancel(_idWater14);
    await _plugin.cancel(_idWater18);
    await _plugin.cancel(_idExercise);
    await _plugin.cancel(_idBedtime);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ===== Debug & Test =====
  Future<void> debugPing() async {
    await _plugin.show(19999, '🔔 Test', 'ทดสอบแจ้งเตือนทันที', _details());
  }

  Future<void> scheduleTestIn10s() async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[LNS] schedule test at ${when.toLocal()}');
    }
    await _zonedScheduleSafe(
      id: 19998,
      title: '🔔 Test 10s',
      body: 'จะเด้งใน 10 วินาที',
      when: when,
    );
  }

  /// นัดแจ้งเตือนใน N วินาที + watchdog ตรวจหลังเลยเวลา (ดีเลย์เผื่อ emulator)
  Future<void> scheduleTestInWithWatch({int seconds = 30}) async {
    const id = 29997;

    // กันซ้อน: ยกเลิกนัดเดิมก่อน
    await _plugin.cancel(id);

    // ✅ ขอสิทธิ์ครบก่อน (เปิดหน้า Settings ให้อัตโนมัติถ้ายังไม่อนุญาต)
    await ensureAllNotifPerms(autoOpenSettings: true);

    final nowTz = tz.TZDateTime.now(tz.local);
    final when = nowTz.add(Duration(seconds: seconds));

    if (kDebugMode) {
      // ignore: avoid_print
      print('[LNS] WATCH scheduling id=$id now=${DateTime.now()} nowTz=$nowTz target=${when.toLocal()} (+$seconds s)');
    }

    await _zonedScheduleSafe(
      id: id,
      title: '🔔 Watchdog test',
      body: 'ควรยิงตอน ${when.toLocal()}',
      when: when,
    );

    // รอเกินเวลาจริงนานหน่อย (emulator บางตัวดีเลย์) แล้วค่อยตรวจ
    await Future.delayed(Duration(seconds: seconds + 75));

    final checkAt = DateTime.now();
    final pending = await _plugin.pendingNotificationRequests();
    final stillPending = pending.any((e) => e.id == id);

    // ignore: avoid_print
    print('[LNS] WATCH result @${checkAt.toLocal()} target=${when.toLocal()} stillPending=$stillPending '
        '(false=ยิงแล้ว, true=ยังค้าง)');

    // ⛑️ กู้ชีพ: ถ้าเลยเวลาแล้วยังค้าง → ยิง show() ทันที
    if (stillPending) {
      const rescueId = 39998;
      await _plugin.show(
        rescueId,
        '⛑️ Rescue notification',
        'ระบบยังไม่ยิงตามเวลา ${when.toLocal()} เลยยิงสำรองให้',
        _details(),
      );
      if (kDebugMode) {
        // ignore: avoid_print
        print('[LNS] ⛑️ fired rescue show() id=$rescueId at ${DateTime.now()}');
      }
    }
  }

  Future<void> debugCheckPendingId(int id) async {
    final pending = await _plugin.pendingNotificationRequests();
    // ignore: avoid_print
    print('[LNS] debugCheckPendingId($id) -> ${pending.any((e) => e.id == id)}');
  }

  Future<void> debugDoctor() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    bool? notificationsAllowed;
    try {
      notificationsAllowed = await (android as dynamic).areNotificationsEnabled();
    } catch (_) {}

    // ignore: avoid_print
    print('🔎 [NotifDoctor] notificationsAllowed=$notificationsAllowed');

    try {
      final channels = await android?.getNotificationChannels();
      // ignore: avoid_print
      print('🔎 [NotifDoctor] channels=${channels?.length ?? 0}');
      for (final c in (channels ?? [])) {
        // ignore: avoid_print
        print('   - id=${c.id} name=${c.name} importance=${c.importance}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('🔎 [NotifDoctor] getNotificationChannels() error: $e');
    }

    final pending = await _plugin.pendingNotificationRequests();
    // ignore: avoid_print
    print('🔎 [NotifDoctor] pending=${pending.length}');
    for (final p in pending) {
      // ignore: avoid_print
      print('   - id=${p.id} title=${p.title}');
    }
  }

  Future<void> debugExactAlarmPerm() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      final can = await (android as dynamic).canScheduleExactAlarms();
      // ignore: avoid_print
      print('[LNS] canScheduleExactAlarms=$can');
    } catch (e) {
      // ignore: avoid_print
      print('[LNS] canScheduleExactAlarms not available: $e');
    }
  }

  /// นัดแจ้งเตือนแบบ AlarmClock (มักเวิร์กดีบน emulator/Doze)
  Future<void> scheduleTestAlarmClockIn({int seconds = 30}) async {
    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    const id = 39997;

    if (kDebugMode) {
      // ignore: avoid_print
      print('[LNS] AlarmClock scheduling id=$id at ${when.toLocal()} (+$seconds s)');
    }

    await _plugin.zonedSchedule(
      id,
      '⏰ AlarmClock test',
      'ควรเด้งตอน ${when.toLocal()}',
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }
}
