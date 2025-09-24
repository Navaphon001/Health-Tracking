// lib/services/user_profile_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'app_db.dart';

class UserProfileService {
  static final UserProfileService instance = UserProfileService._();
  UserProfileService._();

  // ===== SharedPreferences keys (ต่อ user) =====
  String _kStep1(String uid) => 'profile:$uid:step1';
  String _kStep2(String uid) => 'profile:$uid:step2';
  String _kStep3(String uid) => 'profile:$uid:step3';
  String _kCompleted(String uid) => 'profile:$uid:completed';

  String _kNick(String uid) => 'profile:$uid:nickname';
  String _kHealthGoal(String uid) => 'profile:$uid:health_goal';
  String _kHealthRating(String uid) => 'profile:$uid:health_rating';
  String _kOccupation(String uid) => 'profile:$uid:occupation';
  String _kLifestyle(String uid) => 'profile:$uid:lifestyle';
  String _kSleepHours(String uid) => 'profile:$uid:sleep_hours';
  String _kWakeUp(String uid) => 'profile:$uid:wake_up_time';
  String _kInterests(String uid) => 'profile:$uid:interests_csv';
  String _kGoals(String uid) => 'profile:$uid:goals_csv';

  int _now() => DateTime.now().millisecondsSinceEpoch;
  String? _csv(List<String>? xs) => (xs == null || xs.isEmpty) ? null : xs.join(',');

  // ------------------------------------------------------------------
  // เดิม: ensureRowExists → เปลี่ยนเป็นสร้างแถวใน basic_profile/physical_info ถ้ายังไม่มี
  // ------------------------------------------------------------------
  Future<void> ensureRowExists(String userId) async {
    final db = await AppDb.instance.database;
    final now = _now();
    // basic_profile
    await db.rawInsert('''
      INSERT OR IGNORE INTO basic_profile (id, user_id, created_at, updated_at)
      VALUES (?, ?, ?, ?)
    ''', [userId, userId, now, now]);

    // physical_info
    await db.rawInsert('''
      INSERT OR IGNORE INTO physical_info (id, user_id, created_at, updated_at)
      VALUES (?, ?, ?, ?)
    ''', [userId, userId, now, now]);
  }

  // ------------------------------------------------------------------
  // เดิม: isProfileCompleted → อ่านจาก SP
  // ------------------------------------------------------------------
  Future<bool> isProfileCompleted(String userId) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kCompleted(userId)) ?? false;
  }

  // ------------------------------------------------------------------
  // เดิม: getUserProfile → รวมข้อมูลจากสองตาราง + SP ให้คีย์เดิมครบ
  // ------------------------------------------------------------------
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();

    final b = await db.query('basic_profile', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    final p = await db.query('physical_info', where: 'user_id = ?', whereArgs: [userId], limit: 1);

    if (b.isEmpty && p.isEmpty) {
      // ไม่มีแถวเลย → ลอง ensure แล้วคืน null
      await ensureRowExists(userId);
    }

    final map = <String, dynamic>{};

    if (b.isNotEmpty) {
      final row = b.first;
      map['full_name']   = row['full_name'];
      map['birth_date']  = row['date_of_birth'];
      map['gender']      = row['gender'];
    }
    if (p.isNotEmpty) {
      final row = p.first;
      map['height']         = row['height'];
      map['weight']         = row['weight'];
      map['activity_level'] = row['activity_level'];
    }

    // เติมจาก SP ให้ตรงกับที่ ProfileSetupProvider ต้องการ
    map['nickname']      = sp.getString(_kNick(userId));
    map['health_goal']   = sp.getString(_kHealthGoal(userId));
    map['health_rating'] = sp.getString(_kHealthRating(userId));
    map['occupation']    = sp.getString(_kOccupation(userId));
    map['lifestyle']     = sp.getString(_kLifestyle(userId));
    map['sleep_hours']   = sp.getDouble(_kSleepHours(userId));
    map['wake_up_time']  = sp.getString(_kWakeUp(userId));
    map['interests']     = sp.getString(_kInterests(userId)); // Provider จะ split(',') เอง
    map['goals']         = sp.getString(_kGoals(userId));

    if (map.isEmpty) return null;
    return map;
  }

  // ------------------------------------------------------------------
  // เดิม: getStepStatus → ดึงจาก SP
  // ------------------------------------------------------------------
  Future<Map<String, bool>> getStepStatus(String userId) async {
    final sp = await SharedPreferences.getInstance();
    return {
      'step1': sp.getBool(_kStep1(userId)) ?? false,
      'step2': sp.getBool(_kStep2(userId)) ?? false,
      'step3': sp.getBool(_kStep3(userId)) ?? false,
      'completed': sp.getBool(_kCompleted(userId)) ?? false,
    };
  }

  // ------------------------------------------------------------------
  // เดิม: saveStep1 → basic_profile + SP(nickname) + flag step1
  // ------------------------------------------------------------------
  Future<void> saveStep1({
    required String userId,
    required String fullName,
    required String nickname,
    required DateTime birthDate,
    required String gender,
  }) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();
    final now = _now();

    await ensureRowExists(userId);

    await db.rawInsert('''
      INSERT INTO basic_profile
        (id, user_id, full_name, date_of_birth, gender, is_synced, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, 0, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        full_name     = excluded.full_name,
        date_of_birth = excluded.date_of_birth,
        gender        = excluded.gender,
        updated_at    = excluded.updated_at
    ''', [
      userId,
      userId,
      fullName,
      birthDate.toIso8601String().substring(0, 10), // yyyy-MM-dd
      gender,
      now,
      now
    ]);

    await sp.setString(_kNick(userId), nickname);
    await sp.setBool(_kStep1(userId), true);
  }

  // ------------------------------------------------------------------
  // เดิม: saveStep2 → physical_info + SP(health_goal) + flag step2
  // ------------------------------------------------------------------
  Future<void> saveStep2({
    required String userId,
    required double height,
    required double weight,
    required String activityLevel,
    required String healthGoal,
  }) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();
    final now = _now();

    await ensureRowExists(userId);

    await db.rawInsert('''
      INSERT INTO physical_info
        (id, user_id, weight, height, activity_level, is_synced, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, 0, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        weight         = excluded.weight,
        height         = excluded.height,
        activity_level = excluded.activity_level,
        updated_at     = excluded.updated_at
    ''', [userId, userId, weight, height, activityLevel, now, now]);

    await sp.setString(_kHealthGoal(userId), healthGoal);
    await sp.setBool(_kStep2(userId), true);
  }

  // ------------------------------------------------------------------
  // เดิม: saveStep3 → เก็บใน SP + flag step3
  // ------------------------------------------------------------------
  Future<void> saveStep3({
    required String userId,
    String? healthRating,
    String? occupation,
    String? lifestyle,
    double? sleepHours,
    String? wakeUpTime,
    List<String>? interests,
    List<String>? goals,
  }) async {
    final sp = await SharedPreferences.getInstance();
    if (healthRating != null) await sp.setString(_kHealthRating(userId), healthRating);
    if (occupation != null) await sp.setString(_kOccupation(userId), occupation);
    if (lifestyle != null) await sp.setString(_kLifestyle(userId), lifestyle);
    if (sleepHours != null) await sp.setDouble(_kSleepHours(userId), sleepHours);
    if (wakeUpTime != null) await sp.setString(_kWakeUp(userId), wakeUpTime);
    final iCsv = _csv(interests);
    if (iCsv != null) await sp.setString(_kInterests(userId), iCsv);
    final gCsv = _csv(goals);
    if (gCsv != null) await sp.setString(_kGoals(userId), gCsv);

    await sp.setBool(_kStep3(userId), true);
  }

  // ------------------------------------------------------------------
  // เดิม: markProfileCompleted → SP
  // ------------------------------------------------------------------
  Future<void> markProfileCompleted(String userId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kCompleted(userId), true);
  }

  // ------------------------------------------------------------------
  // เดิม: deleteProfile → ลบทั้ง DB แถวของ user และคีย์ใน SP
  // ------------------------------------------------------------------
  Future<void> deleteProfile(String userId) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();

    await db.delete('basic_profile', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('physical_info', where: 'user_id = ?', whereArgs: [userId]);

    await sp.remove(_kStep1(userId));
    await sp.remove(_kStep2(userId));
    await sp.remove(_kStep3(userId));
    await sp.remove(_kCompleted(userId));

    await sp.remove(_kNick(userId));
    await sp.remove(_kHealthGoal(userId));
    await sp.remove(_kHealthRating(userId));
    await sp.remove(_kOccupation(userId));
    await sp.remove(_kLifestyle(userId));
    await sp.remove(_kSleepHours(userId));
    await sp.remove(_kWakeUp(userId));
    await sp.remove(_kInterests(userId));
    await sp.remove(_kGoals(userId));
  }

  // ------------------------------------------------------------------
  // เดิม: updateStep1 → อัปเดตเฉพาะฟิลด์ที่ส่งมา (DB + SP)
  // ------------------------------------------------------------------
  Future<void> updateStep1({
    required String userId,
    String? fullName,
    String? nickname,
    DateTime? birthDate,
    String? gender,
  }) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();
    final now = _now();

    await ensureRowExists(userId);

    // DB: basic_profile
    final updates = <String, Object?>{'updated_at': now};
    if (fullName != null) updates['full_name'] = fullName;
    if (birthDate != null) updates['date_of_birth'] = birthDate.toIso8601String().substring(0, 10);
    if (gender != null) updates['gender'] = gender;
    if (updates.length > 1) {
      await db.update('basic_profile', updates, where: 'user_id = ?', whereArgs: [userId]);
    }

    // SP: nickname
    if (nickname != null) await sp.setString(_kNick(userId), nickname);
  }

  // ------------------------------------------------------------------
  // เดิม: updateStep2 → physical_info + SP(health_goal)
  // ------------------------------------------------------------------
  Future<void> updateStep2({
    required String userId,
    double? height,
    double? weight,
    String? activityLevel,
    String? healthGoal,
  }) async {
    final db = await AppDb.instance.database;
    final sp = await SharedPreferences.getInstance();
    final now = _now();

    await ensureRowExists(userId);

    final updates = <String, Object?>{'updated_at': now};
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;
    if (activityLevel != null) updates['activity_level'] = activityLevel;
    if (updates.length > 1) {
      await db.update('physical_info', updates, where: 'user_id = ?', whereArgs: [userId]);
    }

    if (healthGoal != null) await sp.setString(_kHealthGoal(userId), healthGoal);
  }

  // ------------------------------------------------------------------
  // เดิม: updateStep3 → SP เท่านั้น
  // ------------------------------------------------------------------
  Future<void> updateStep3({
    required String userId,
    String? healthRating,
    String? occupation,
    String? lifestyle,
    double? sleepHours,
    String? wakeUpTime,
    List<String>? interests,
    List<String>? goals,
  }) async {
    final sp = await SharedPreferences.getInstance();
    if (healthRating != null) await sp.setString(_kHealthRating(userId), healthRating);
    if (occupation != null) await sp.setString(_kOccupation(userId), occupation);
    if (lifestyle != null) await sp.setString(_kLifestyle(userId), lifestyle);
    if (sleepHours != null) await sp.setDouble(_kSleepHours(userId), sleepHours);
    if (wakeUpTime != null) await sp.setString(_kWakeUp(userId), wakeUpTime);
    if (interests != null) await sp.setString(_kInterests(userId), _csv(interests) ?? '');
    if (goals != null) await sp.setString(_kGoals(userId), _csv(goals) ?? '');
  }
}
