// screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import '../providers/habit_notifier.dart';
import '../shared/snack_fn.dart'; // ใช้ showAppSnack (ผูกกับ global key แล้ว)

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    // bind snackbar ให้ทั้งสอง notifier ด้วยฟังก์ชันกลาง (ไม่ใช้ ScaffoldMessenger.of(context))
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthNotifier>().setSnackBarCallback(showAppSnack);
      context.read<HabitNotifier>().setSnackBarCallback(showAppSnack);
    });
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('ต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ยืนยัน')),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                children: const [
                  _NavCard(icon: Icons.local_drink, label: 'Water', routeName: '/water'),
                  _NavCard(icon: Icons.directions_run, label: 'Exercise', routeName: '/exercise'),
                  _NavCard(icon: Icons.bedtime, label: 'Sleep', routeName: '/sleep'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon; final String label; final String routeName;
  const _NavCard({super.key, required this.icon, required this.label, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // กัน ripple ล้น
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 36), const SizedBox(height: 8), Text(label),
          ]),
        ),
      ),
    );
  }
}
