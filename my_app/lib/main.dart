import 'package:flutter/material.dart';
import 'package:my_app/services/habit_local_repository.dart';
import 'package:provider/provider.dart';
import 'providers/auth_notifier.dart';
import 'providers/habit_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/app_navigation.dart';
import 'screens/water_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/sleep_screen.dart';
import 'shared/app_keys.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/settings_page.dart';
import 'theme/app_themes.dart';
import 'screens/profile_setup_step1.dart';
import 'screens/profile_setup_step2.dart';
import 'screens/profile_setup_step3.dart';
import 'screens/onboarding_main.dart';
import 'providers/profile_setup_provider.dart';
import 'providers/physical_info_provider.dart';
import 'providers/date_provider.dart';
import 'providers/water_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/bmi_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/goals_achievements_screen.dart';

import 'package:flutter/foundation.dart'; // kDebugMode, debugPrint
import 'services/app_db.dart';

Future<void> _devSmokeTest() async {
  final db = await AppDb.instance.database;
  final repo = HabitLocalRepository(db);
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
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => HabitNotifier()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => PhysicalInfoProvider()..load()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => BmiProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final themeP = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppThemes.light(themeP.primary),
      darkTheme: AppThemes.dark(themeP.primary),
      themeMode: themeP.mode,
      locale: lang.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const AppNavigation(),
        '/water': (_) => const WaterScreen(),
        '/exercise': (_) => const ExerciseScreen(),
        '/sleep': (_) => const SleepScreen(),
        '/onboarding': (_) => const OnboardingMain(),
        '/dashboard': (_) => const DashboardPage(),
        '/settings': (_) => const SettingsPage(),
        '/profile-setup': (_) => const ProfileSetupStep1(),
        '/profile-setup-step2': (_) => const ProfileSetupStep2(),
        '/profile-setup-step3': (_) => const ProfileSetupStep3(),
        '/goals-achievements': (_) => const GoalsAchievementsScreen(),
      },
    );
  }
}
