import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_page.dart';
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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => PhysicalInfoProvider()..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
     final themeP = context.watch<ThemeProvider>();
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppThemes.light(themeP.primary),
      darkTheme: AppThemes.dark(themeP.primary),
      themeMode: themeP.mode,
      locale: lang.locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingMain(),
        '/dashboard': (_) => const DashboardPage(),
        '/settings': (_) => const SettingsPage(),
        '/profile-setup': (_) => const ProfileSetupStep1(),
        '/profile-setup-step2': (_) => const ProfileSetupStep2(),
        '/profile-setup-step3': (_) => const ProfileSetupStep3(),
      },
    );
  }
}

// Dashboard is a separate screen now; see screens/dashboard_page.dart
