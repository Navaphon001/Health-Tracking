import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth Starter',
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/main': (_) => const MainNavigationScreen(),
        },
        theme: ThemeData(useMaterial3: true),
      ),
    );
  }
}
