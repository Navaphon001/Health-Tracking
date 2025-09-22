import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:flutter/foundation.dart'; // ถ้าจะ debugPrint path

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();

  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'habit_daily.db');
    // debugPrint('DB PATH => $dbPath');

    return openDatabase(
      dbPath,
      version: 4, // ⬅️ บัมป์เป็น 4
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
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');

        // 2) Water
        await db.execute('''
          CREATE TABLE IF NOT EXISTS water_intake_logs (
            date_key   TEXT PRIMARY KEY,
            count      INTEGER NOT NULL DEFAULT 0,
            ml         INTEGER NOT NULL DEFAULT 0,
            goal_count INTEGER,
            goal_ml    INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');

        // 3) Exercise (รวมรายวัน, ไม่แยกชนิด)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercise_daily (
            date_key        TEXT PRIMARY KEY,      -- yyyy-MM-dd
            duration_min    INTEGER NOT NULL DEFAULT 0,
            calories_burned REAL,
            notes           TEXT,
            created_at      INTEGER NOT NULL,
            updated_at      INTEGER NOT NULL
          );
        ''');

        // 4) User Profile (สำหรับ Profile Setup)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_profile (
            user_id         TEXT PRIMARY KEY,      -- username หรือ user identifier
            step1_completed INTEGER NOT NULL DEFAULT 0,  -- 0 = false, 1 = true
            step2_completed INTEGER NOT NULL DEFAULT 0,
            step3_completed INTEGER NOT NULL DEFAULT 0,
            profile_completed INTEGER NOT NULL DEFAULT 0,
            -- Step 1: Basic Info
            full_name       TEXT,
            nickname        TEXT,
            birth_date      TEXT,              -- วันเกิด (ISO format)
            gender          TEXT,              -- เพศ
            -- Step 2: Physical Info  
            height          REAL,              -- ส่วนสูง (cm)
            weight          REAL,              -- น้ำหนัก (kg)
            activity_level  TEXT,              -- ระดับการออกกำลังกาย
            health_goal     TEXT,              -- เป้าหมายสุขภาพ
            -- Step 3: About Yourself
            occupation      TEXT,              -- อาชีพ
            lifestyle       TEXT,              -- รูปแบบชีวิต
            sleep_hours     REAL,              -- ชั่วโมงนอนเฉลี่ย
            wake_up_time    TEXT,              -- เวลาตื่น
            interests       TEXT,              -- ความสนใจ (JSON array)
            health_rating   TEXT,              -- การประเมินสุขภาพ
            goals           TEXT,              -- เป้าหมาย (JSON array)
            -- Timestamps
            created_at      INTEGER NOT NULL,
            updated_at      INTEGER NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // สร้างตารางใหม่ (ถ้ายังไม่มี)
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

          // ถ้ามีตารางเก่า exercise_logs_daily ให้รวมยอดย้ายมา
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
            // เลือกได้: จะเก็บตารางเก่าไว้หรือทิ้ง
            await db.execute('DROP TABLE IF EXISTS exercise_logs_daily');
          }
        }
        
        if (oldV < 3) {
          // เพิ่มตาราง user_profile สำหรับ Profile Setup
          await db.execute('''
            CREATE TABLE IF NOT EXISTS user_profile (
              user_id         TEXT PRIMARY KEY,
              step1_completed INTEGER NOT NULL DEFAULT 0,
              step2_completed INTEGER NOT NULL DEFAULT 0,
              step3_completed INTEGER NOT NULL DEFAULT 0,
              profile_completed INTEGER NOT NULL DEFAULT 0,
              full_name       TEXT,
              nickname        TEXT,
              birth_date      TEXT,
              gender          TEXT,
              height          REAL,
              weight          REAL,
              activity_level  TEXT,
              health_goal     TEXT,
              occupation      TEXT,
              lifestyle       TEXT,
              sleep_hours     REAL,
              wake_up_time    TEXT,
              interests       TEXT,
              created_at      INTEGER NOT NULL,
              updated_at      INTEGER NOT NULL
            );
          ''');
        }
        
        if (oldV < 4) {
          // เพิ่ม health_rating และ goals columns
          await db.execute('ALTER TABLE user_profile ADD COLUMN health_rating TEXT');
          await db.execute('ALTER TABLE user_profile ADD COLUMN goals TEXT');
        }
      },
    );
  }
}
