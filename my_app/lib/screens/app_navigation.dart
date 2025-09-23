import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'dashboard.dart';
import 'meal_logging_screen.dart';
import 'water_screen.dart';
import 'exercise_screen.dart';
import 'sleep_screen.dart';
import 'goals_achievements_screen.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
    DashboardPage(onTabChange: _onTabChange),
    const MealLoggingScreen(),
    const WaterScreen(),
    const ExerciseScreen(),
    const SleepScreen(),
    const GoalsAchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: t.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_outlined),
              activeIcon: const Icon(Icons.restaurant),
              label: t.meal,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.water_drop_outlined),
              activeIcon: const Icon(Icons.water_drop),
              label: t.water,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center_outlined),
              activeIcon: const Icon(Icons.fitness_center),
              label: t.exercise,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bedtime_outlined),
              activeIcon: const Icon(Icons.bedtime),
              label: t.sleep,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.flag_outlined),
              activeIcon: const Icon(Icons.flag),
              label: t.goal,
            ),
          ],
        ),
      ),
    );
  }
}
