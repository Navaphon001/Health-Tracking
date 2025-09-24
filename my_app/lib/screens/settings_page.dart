// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/bedtime_setting_tile.dart'; // ← เพิ่ม
import '../widgets/notification_debug_panel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.account, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          // Account tile
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              // ใช้ข้อความตรงเพื่อเลี่ยง error ถ้ายังไม่มี key ใน .arb
              title: const Text('Uranus Code'),
              subtitle: const Text('YouTube Channel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),

          // Goals & Achievements
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E8),
                child: Icon(Icons.emoji_events, color: Color(0xFF4CAF50)),
              ),
              title: Text(t.goalAndAchievement),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/goals-achievements');
              },
            ),
          ),

          const SizedBox(height: 24),
          Text(t.settings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          // Language
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFE4B5),
                child: Icon(Icons.language, color: Colors.orange),
              ),
              title: Text(t.language),
              trailing: Selector<LanguageProvider, Locale>(
                selector: (_, p) => p.locale,
                builder: (context, locale, __) {
                  return DropdownButton<Locale>(
                    value: locale,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LanguageProvider>().setLocale(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(t.english),
                      ),
                      DropdownMenuItem(
                        value: const Locale('th'),
                        child: Text(t.thai),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notifications (มี BedtimeSettingTile)
          Card(
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.notifications, color: Color(0xFF2196F3)),
              ),
              title: Text(t.notifications),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                BedtimeSettingTile(), // ตั้งเวลาเข้านอน + เปิด/ปิด + นาทีเตือนล่วงหน้า
              ],
            ),
          ),
          const SizedBox(height: 12),
          const NotificationDebugPanel(),
          const SizedBox(height: 12),

          // Dark Mode Switch
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3E5F5),
                child: Icon(Icons.dark_mode, color: Color(0xFF9C27B0)),
              ),
              title: Text(t.darkMode),
              trailing: Selector<ThemeProvider, ThemeMode>(
                selector: (_, p) => p.mode,
                builder: (context, mode, __) {
                  final isDark = mode == ThemeMode.dark;
                  return Switch(
                    value: isDark,
                    onChanged: (v) {
                      context
                          .read<ThemeProvider>()
                          .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sign Out tile (placeholder)
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.logout, color: Color(0xFFF44336)),
              ),
              title: Text(t.signOut),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
