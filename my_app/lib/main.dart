import 'package:flutter/material.dart';
import 'package:my_app/services/habit_local_repository.dart';
import 'package:provider/provider.dart';
import 'providers/auth_notifier.dart';
import 'providers/habit_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/water_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/sleep_screen.dart';
import 'shared/app_keys.dart';

import 'package:flutter/foundation.dart'; // kDebugMode, debugPrint
import 'services/app_db.dart';

Future<void> _devSmokeTest() async {
  final repo = HabitLocalRepository();
  final today = DateTime.now();

  // 1) Water: +1 แก้ว (250 ml)
  await repo.upsertWater(day: today, deltaCount: 1, deltaMl: 250);

  // 2) Sleep: ตั้ง 7 ชั่วโมง 30 นาที
  await repo.setSleepHM(day: today, hours: 7, minutes: 30);

  // 3) Exercise: วิ่ง +15 นาที
  await repo.addExerciseMinutes(day: today,  deltaMinutes: 2);

  // 4) อ่านสรุปวัน
  final sum = await repo.dailySummary(today);
  debugPrint('SMOKE daily summary => $sum');

  // 5) อ่านแยกรายตาราง (อยากดูละเอียด)
  final water = await repo.getWaterDaily(today);
  final sleep = await repo.getSleepDaily(today);
  final exs   = await repo.getExerciseDaily(today);
  debugPrint('WATER => $water');
  debugPrint('SLEEP => $sleep');
  debugPrint('EXERCISE => $exs');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เปิด DB (ครั้งแรกจะสร้างตารางใน onCreate)
  final db = await AppDb.instance.database;

  // เช็กตารางเฉพาะตอน debug
  if (kDebugMode) {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    );
    debugPrint('DB tables: ${rows.map((e) => e['name']).toList()}');
  }

  await _devSmokeTest();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => HabitNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth Starter',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/main': (_) => const MainNavigationScreen(),
          '/water': (_) => const WaterScreen(),
          '/exercise': (_) => const ExerciseScreen(),
          '/sleep': (_) => const SleepScreen(),
        },
        theme: ThemeData(useMaterial3: true),
      ),
    );
  }
}
