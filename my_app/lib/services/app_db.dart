import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:flutter/foundation.dart'; // debugPrint path ถ้าต้องการ

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();

  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'habit_daily.db');

    return openDatabase(
      dbPath,
  version: 8, // ⬅️ บัมป์เป็น 8: เพิ่ม exercise_logs table
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async {
        // 1) Sleep
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sleep_daily (
            date_key   TEXT PRIMARY KEY,
            hours      INTEGER NOT NULL DEFAULT 0 CHECK(hours BETWEEN 0 AND 24),
            minutes    INTEGER NOT NULL DEFAULT 0 CHECK(minutes BETWEEN 0 AND 59),
            quality    INTEGER,
            note       TEXT,
            is_synced  INTEGER NOT NULL DEFAULT 0, -- 0=ยังไม่ซิงก์
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sleep_is_synced ON sleep_daily(is_synced);');

        // 2) Water
        await db.execute('''
          CREATE TABLE IF NOT EXISTS water_intake_logs (
            date_key   TEXT PRIMARY KEY,
            count      INTEGER NOT NULL DEFAULT 0,
            ml         INTEGER NOT NULL DEFAULT 0,
            goal_count INTEGER,
            goal_ml    INTEGER,
            is_synced  INTEGER NOT NULL DEFAULT 0, -- 0=ยังไม่ซิงก์
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_water_is_synced ON water_intake_logs(is_synced);');

        // 3) Exercise (แยกชนิด/Type)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercise_daily (
            date_key        TEXT NOT NULL,          -- yyyy-MM-dd
            type            TEXT NOT NULL DEFAULT 'general',
            duration_min    INTEGER NOT NULL DEFAULT 0,
            calories_burned REAL,
            notes           TEXT,
            is_synced       INTEGER NOT NULL DEFAULT 0, -- 0=ยังไม่ซิงก์
            created_at      INTEGER NOT NULL,
            updated_at      INTEGER NOT NULL,
            PRIMARY KEY(date_key, type)
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_exercise_daily_date ON exercise_daily(date_key);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_exercise_is_synced ON exercise_daily(is_synced);');
        await db.execute('''
          CREATE UNIQUE INDEX IF NOT EXISTS uniq_exercise_daily_date_general
          ON exercise_daily(date_key)
          WHERE type = 'general';
        ''');
        await db.execute('''
          CREATE VIEW IF NOT EXISTS exercise_daily_sum AS
          SELECT
            date_key,
            SUM(duration_min)    AS duration_min,
            SUM(calories_burned) AS calories_burned,
            MIN(created_at)      AS created_at,
            MAX(updated_at)      AS updated_at
          FROM exercise_daily
          GROUP BY date_key;
        ''');

        // 4) Basic Profile
        await db.execute('''
          CREATE TABLE IF NOT EXISTS basic_profile (
            id                TEXT PRIMARY KEY,     -- แนะนำให้ = user_id (1:1)
            user_id           TEXT NOT NULL UNIQUE,
            full_name         TEXT,
            date_of_birth     TEXT,                 -- ISO8601 yyyy-MM-dd
            gender            TEXT,
            profile_image_url TEXT,
            is_synced         INTEGER NOT NULL DEFAULT 0, -- 0=ยังไม่ซิงก์
            created_at        INTEGER NOT NULL,
            updated_at        INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_basic_profile_user ON basic_profile(user_id);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_basic_profile_is_synced ON basic_profile(is_synced);');

        // 5) Physical Info
        await db.execute('''
          CREATE TABLE IF NOT EXISTS physical_info (
            id             TEXT PRIMARY KEY,        -- แนะนำให้ = user_id (1:1)
            user_id        TEXT NOT NULL UNIQUE,
            weight         REAL,
            height         REAL,
            activity_level TEXT,
            is_synced      INTEGER NOT NULL DEFAULT 0, -- 0=ยังไม่ซิงก์
            created_at     INTEGER NOT NULL,
            updated_at     INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_physical_info_user ON physical_info(user_id);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_physical_info_is_synced ON physical_info(is_synced);');

        // 6) User Profile (สำหรับ profile setup flow)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_profile (
            user_id               TEXT PRIMARY KEY,
            step1_completed       INTEGER NOT NULL DEFAULT 0,
            step2_completed       INTEGER NOT NULL DEFAULT 0,
            step3_completed       INTEGER NOT NULL DEFAULT 0,
            profile_completed     INTEGER NOT NULL DEFAULT 0,
            full_name             TEXT,
            nickname              TEXT,
            birth_date            TEXT,
            gender                TEXT,
            profile_image_url     TEXT,
            height                REAL,
            weight                REAL,
            activity_level        TEXT,
            health_goal           TEXT,
            health_rating         TEXT,
            occupation            TEXT,
            lifestyle             TEXT,
            sleep_hours           REAL,
            wake_up_time          TEXT,
            interests             TEXT,
            goals                 TEXT,
            is_synced             INTEGER NOT NULL DEFAULT 0,
            created_at            INTEGER NOT NULL,
            updated_at            INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profile_is_synced ON user_profile(is_synced);');

        // 7) Notification Settings
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_settings (
            id                        TEXT PRIMARY KEY,
            user_id                   TEXT,
            water_reminder_enabled    INTEGER NOT NULL DEFAULT 1,
            exercise_reminder_enabled INTEGER NOT NULL DEFAULT 1,
            meal_logging_enabled      INTEGER NOT NULL DEFAULT 1,
            sleep_reminder_enabled    INTEGER NOT NULL DEFAULT 1,
            updated_at                TEXT NOT NULL,
            is_synced                 INTEGER NOT NULL DEFAULT 0
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notification_settings_user ON notification_settings(user_id);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notification_settings_is_synced ON notification_settings(is_synced);');

        // 8) Exercise logs (per-activity raw logs) - supports backend sync
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercise_logs (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            date TEXT NOT NULL,
            activity_type TEXT NOT NULL,
            duration INTEGER NOT NULL,
            calories_burned REAL,
            notes TEXT,
            created_at INTEGER,
            updated_at INTEGER,
            is_synced INTEGER NOT NULL DEFAULT 0
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_exercise_logs_user_date ON exercise_logs(user_id, date);');
      },
      onUpgrade: (db, oldV, newV) async {
        // v1 -> v2 : เดิม (exercise_daily แบบรวม)
        if (oldV < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS exercise_daily (
              date_key        TEXT PRIMARY KEY,
              duration_min    INTEGER NOT NULL DEFAULT 0,
              calories_burned REAL,
              notes           TEXT,
              created_at      INTEGER NOT NULL,
              updated_at      INTEGER NOT NULL
            );
          ''');

          final exists = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='exercise_logs_daily'"
          );
          if (exists.isNotEmpty) {
            await db.execute('''
              INSERT INTO exercise_daily(date_key, duration_min, created_at, updated_at)
              SELECT date_key,
                     SUM(duration_min) AS duration_min,
                     MIN(created_at)   AS created_at,
                     MAX(updated_at)   AS updated_at
              FROM exercise_logs_daily
              GROUP BY date_key;
            ''');
            await db.execute('DROP TABLE IF EXISTS exercise_logs_daily');
          }
        }

        // v2 -> v4 : เดิม (อัปเกรด exercise_daily ให้มี type + view/index)
        if (oldV < 4) {
          final hasOld = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='exercise_daily'"
          );
          if (hasOld.isNotEmpty) {
            final pragma = await db.rawQuery('PRAGMA table_info(exercise_daily);');
            final hasType = pragma.any((c) => (c['name'] as String) == 'type');

            if (!hasType) {
              await db.execute('''
                CREATE TABLE exercise_daily_new (
                  date_key        TEXT NOT NULL,
                  type            TEXT NOT NULL DEFAULT 'general',
                  duration_min    INTEGER NOT NULL DEFAULT 0,
                  calories_burned REAL,
                  notes           TEXT,
                  created_at      INTEGER NOT NULL,
                  updated_at      INTEGER NOT NULL,
                  PRIMARY KEY(date_key, type)
                );
              ''');

              await db.execute('''
                INSERT INTO exercise_daily_new(date_key, type, duration_min, calories_burned, notes, created_at, updated_at)
                SELECT date_key, 'general', duration_min, calories_burned, notes, created_at, updated_at
                FROM exercise_daily;
              ''');

              await db.execute('DROP TABLE exercise_daily;');
              await db.execute('ALTER TABLE exercise_daily_new RENAME TO exercise_daily;');
            }
          } else {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS exercise_daily (
                date_key        TEXT NOT NULL,
                type            TEXT NOT NULL DEFAULT 'general',
                duration_min    INTEGER NOT NULL DEFAULT 0,
                calories_burned REAL,
                notes           TEXT,
                created_at      INTEGER NOT NULL,
                updated_at      INTEGER NOT NULL,
                PRIMARY KEY(date_key, type)
              );
            ''');
          }

          await db.execute('CREATE INDEX IF NOT EXISTS idx_exercise_daily_date ON exercise_daily(date_key);');
          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS uniq_exercise_daily_date_general
            ON exercise_daily(date_key) WHERE type = 'general';
          ''');
          await db.execute('''
            CREATE VIEW IF NOT EXISTS exercise_daily_sum AS
            SELECT
              date_key,
              SUM(duration_min)    AS duration_min,
              SUM(calories_burned) AS calories_burned,
              MIN(created_at)      AS created_at,
              MAX(updated_at)      AS updated_at
            FROM exercise_daily
            GROUP BY date_key;
          ''');
        }

        // v4 -> v5 : แยก user_profile -> basic_profile & physical_info
        if (oldV < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS basic_profile (
              id                TEXT PRIMARY KEY,
              user_id           TEXT NOT NULL UNIQUE,
              full_name         TEXT,
              date_of_birth     TEXT,
              gender            TEXT,
              profile_image_url TEXT,
              is_synced         INTEGER NOT NULL DEFAULT 0,
              created_at        INTEGER NOT NULL,
              updated_at        INTEGER NOT NULL
            );
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_basic_profile_user ON basic_profile(user_id);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_basic_profile_is_synced ON basic_profile(is_synced);');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS physical_info (
              id             TEXT PRIMARY KEY,
              user_id        TEXT NOT NULL UNIQUE,
              weight         REAL,
              height         REAL,
              activity_level TEXT,
              is_synced      INTEGER NOT NULL DEFAULT 0,
              created_at     INTEGER NOT NULL,
              updated_at     INTEGER NOT NULL
            );
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_physical_info_user ON physical_info(user_id);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_physical_info_is_synced ON physical_info(is_synced);');

          final hasUserProfile = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='user_profile'"
          );
          if (hasUserProfile.isNotEmpty) {
            await db.execute('''
              INSERT OR IGNORE INTO basic_profile
                (id, user_id, full_name, date_of_birth, gender, profile_image_url, is_synced, created_at, updated_at)
              SELECT
                user_id AS id,
                user_id,
                full_name,
                birth_date,
                gender,
                NULL as profile_image_url,
                0 as is_synced,
                created_at,
                updated_at
              FROM user_profile
              WHERE full_name IS NOT NULL OR birth_date IS NOT NULL OR gender IS NOT NULL;
            ''');

            await db.execute('''
              INSERT OR IGNORE INTO physical_info
                (id, user_id, weight, height, activity_level, is_synced, created_at, updated_at)
              SELECT
                user_id AS id,
                user_id,
                weight,
                height,
                activity_level,
                0 as is_synced,
                created_at,
                updated_at
              FROM user_profile
              WHERE weight IS NOT NULL OR height IS NOT NULL OR activity_level IS NOT NULL;
            ''');
          }
        }

        // v5 -> v6 : เพิ่มคอลัมน์ is_synced ให้ทุกตารางที่ยังไม่มี
        if (oldV < 6) {
          Future<void> ensureIsSynced(String table) async {
            final cols = await db.rawQuery('PRAGMA table_info($table);');
            final has = cols.any((c) => (c['name'] as String) == 'is_synced');
            if (!has) {
              await db.execute('ALTER TABLE $table ADD COLUMN is_synced INTEGER NOT NULL DEFAULT 0;');
            }
          }

          await ensureIsSynced('sleep_daily');
          await ensureIsSynced('water_intake_logs');
          await ensureIsSynced('exercise_daily');
          await ensureIsSynced('basic_profile');
          await ensureIsSynced('physical_info');

          // (เผื่อยังมีตารางเก่าอยู่) เพิ่มให้ user_profile ด้วย
          final hasUserProfile = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='user_profile'"
          );
          if (hasUserProfile.isNotEmpty) {
            final cols = await db.rawQuery('PRAGMA table_info(user_profile);');
            final has = cols.any((c) => (c['name'] as String) == 'is_synced');
            if (!has) {
              await db.execute('ALTER TABLE user_profile ADD COLUMN is_synced INTEGER NOT NULL DEFAULT 0;');
            }
          }

          // สร้าง index is_synced ให้ตารางที่ยังไม่มี
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sleep_is_synced ON sleep_daily(is_synced);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_water_is_synced ON water_intake_logs(is_synced);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_exercise_is_synced ON exercise_daily(is_synced);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_basic_profile_is_synced ON basic_profile(is_synced);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_physical_info_is_synced ON physical_info(is_synced);');
        }

        // v6 -> v7 : เพิ่ม notification_settings table
        if (oldV < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notification_settings (
              id                        TEXT PRIMARY KEY,
              user_id                   TEXT,
              water_reminder_enabled    INTEGER NOT NULL DEFAULT 1,
              exercise_reminder_enabled INTEGER NOT NULL DEFAULT 1,
              meal_logging_enabled      INTEGER NOT NULL DEFAULT 1,
              sleep_reminder_enabled    INTEGER NOT NULL DEFAULT 1,
              updated_at                TEXT NOT NULL,
              is_synced                 INTEGER NOT NULL DEFAULT 0
            );
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notification_settings_user ON notification_settings(user_id);');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notification_settings_is_synced ON notification_settings(is_synced);');
        }
      },
    );
  }
}
