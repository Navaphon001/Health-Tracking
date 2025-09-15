import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_notifier.dart';
import 'providers/habit_notifier.dart';    
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/water_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/sleep_screen.dart';

void main() {
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
