import 'app_db.dart';

class UserProfileService {
  static final UserProfileService instance = UserProfileService._();
  UserProfileService._();

  /// เช็คว่าผู้ใช้ทำ Profile Setup เสร็จหรือยัง
  Future<bool> isProfileCompleted(String userId) async {
    final db = await AppDb.instance.database;
    final result = await db.query(
      'user_profile',
      where: 'user_id = ? AND profile_completed = 1',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// ดึงข้อมูล Profile ของผู้ใช้
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final db = await AppDb.instance.database;
    final result = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// เช็คว่า Step ไหนเสร็จแล้วบ้าง
  Future<Map<String, bool>> getStepStatus(String userId) async {
    final db = await AppDb.instance.database;
    final result = await db.query(
      'user_profile',
      columns: ['step1_completed', 'step2_completed', 'step3_completed', 'profile_completed'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (result.isEmpty) {
      return {
        'step1': false,
        'step2': false,
        'step3': false,
        'completed': false,
      };
    }
    
    final row = result.first;
    return {
      'step1': (row['step1_completed'] as int) == 1,
      'step2': (row['step2_completed'] as int) == 1,
      'step3': (row['step3_completed'] as int) == 1,
      'completed': (row['profile_completed'] as int) == 1,
    };
  }

  /// บันทึกข้อมูล Step 1: Basic Info
  Future<void> saveStep1({
    required String userId,
    required String fullName,
    required String nickname,
    required DateTime birthDate,
    required String gender,
    String? profileImageUrl,
  }) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.execute('''
      INSERT OR REPLACE INTO user_profile (
        user_id, step1_completed, full_name, nickname, birth_date, gender, profile_image_url,
        created_at, updated_at
      ) VALUES (?, 1, ?, ?, ?, ?, ?, 
        COALESCE((SELECT created_at FROM user_profile WHERE user_id = ?), ?), 
        ?
      )
    ''', [
      userId, fullName, nickname, birthDate.toIso8601String(), gender, profileImageUrl,
      userId, now, now
    ]);
  }

  /// บันทึกข้อมูล Step 2: Physical Info
  Future<void> saveStep2({
    required String userId,
    required double height,
    required double weight,
    required String activityLevel,
    required String healthGoal,
  }) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.execute('''
      INSERT OR REPLACE INTO user_profile (
        user_id, step2_completed, height, weight, activity_level, health_goal,
        step1_completed, full_name, nickname, birth_date, gender,
        created_at, updated_at
      ) VALUES (?, 1, ?, ?, ?, ?,
        COALESCE((SELECT step1_completed FROM user_profile WHERE user_id = ?), 0),
        COALESCE((SELECT full_name FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT nickname FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT birth_date FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT gender FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT created_at FROM user_profile WHERE user_id = ?), ?), 
        ?
      )
    ''', [
      userId, height, weight, activityLevel, healthGoal,
      userId, userId, userId, userId, userId, userId, now, now
    ]);
  }

  /// บันทึกข้อมูล Step 3: About Yourself
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
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final interestsJson = interests?.join(',') ?? ''; // Simple comma-separated format
    final goalsJson = goals?.join(',') ?? '';
    
    await db.execute('''
      INSERT OR REPLACE INTO user_profile (
        user_id, step3_completed, health_rating, occupation, lifestyle, sleep_hours, wake_up_time, interests, goals,
        step1_completed, step2_completed, full_name, nickname, birth_date, gender,
        height, weight, activity_level, health_goal,
        created_at, updated_at
      ) VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?,
        COALESCE((SELECT step1_completed FROM user_profile WHERE user_id = ?), 0),
        COALESCE((SELECT step2_completed FROM user_profile WHERE user_id = ?), 0),
        COALESCE((SELECT full_name FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT nickname FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT birth_date FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT gender FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT height FROM user_profile WHERE user_id = ?), 0),
        COALESCE((SELECT weight FROM user_profile WHERE user_id = ?), 0),
        COALESCE((SELECT activity_level FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT health_goal FROM user_profile WHERE user_id = ?), ''),
        COALESCE((SELECT created_at FROM user_profile WHERE user_id = ?), ?), 
        ?
      )
    ''', [
      userId, healthRating, occupation, lifestyle, sleepHours, wakeUpTime, interestsJson, goalsJson,
      userId, userId, userId, userId, userId, userId, userId, userId, userId, userId, userId, now, now
    ]);
  }

  /// ทำเครื่องหมายว่า Profile Setup เสร็จสมบูรณ์
  Future<void> markProfileCompleted(String userId) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.execute('''
      UPDATE user_profile 
      SET profile_completed = 1, updated_at = ?
      WHERE user_id = ?
    ''', [now, userId]);
  }

  /// ลบข้อมูล Profile (สำหรับ reset หรือ logout)
  Future<void> deleteProfile(String userId) async {
    final db = await AppDb.instance.database;
    await db.delete('user_profile', where: 'user_id = ?', whereArgs: [userId]);
  }

  /// อัปเดตเฉพาะ Step ที่ต้องการ
  Future<void> updateStep1({
    required String userId,
    String? fullName,
    String? nickname,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
  }) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final updates = <String, dynamic>{'updated_at': now};
    if (fullName != null) updates['full_name'] = fullName;
    if (nickname != null) updates['nickname'] = nickname;
    if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String();
    if (gender != null) updates['gender'] = gender;
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;
    
    if (updates.length > 1) { // มีการเปลี่ยนแปลงนอกจาก updated_at
      await db.update('user_profile', updates, where: 'user_id = ?', whereArgs: [userId]);
    }
  }

  Future<void> updateStep2({
    required String userId,
    double? height,
    double? weight,
    String? activityLevel,
    String? healthGoal,
  }) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final updates = <String, dynamic>{'updated_at': now};
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;
    if (activityLevel != null) updates['activity_level'] = activityLevel;
    if (healthGoal != null) updates['health_goal'] = healthGoal;
    
    if (updates.length > 1) {
      await db.update('user_profile', updates, where: 'user_id = ?', whereArgs: [userId]);
    }
  }

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
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final updates = <String, dynamic>{'updated_at': now};
    if (healthRating != null) updates['health_rating'] = healthRating;
    if (occupation != null) updates['occupation'] = occupation;
    if (lifestyle != null) updates['lifestyle'] = lifestyle;
    if (sleepHours != null) updates['sleep_hours'] = sleepHours;
    if (wakeUpTime != null) updates['wake_up_time'] = wakeUpTime;
    if (interests != null) updates['interests'] = interests.join(',');
    if (goals != null) updates['goals'] = goals.join(',');
    
    if (updates.length > 1) {
      await db.update('user_profile', updates, where: 'user_id = ?', whereArgs: [userId]);
    }
  }
}