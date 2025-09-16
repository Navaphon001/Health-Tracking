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
      version: 2, // ⬅️ บัมป์เป็น 2
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
      },
    );
  }
}
