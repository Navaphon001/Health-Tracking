import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../shared/custom_top_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Avoid top-level watches to minimize rebuilds of the whole page.

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.settings,
        automaticallyImplyLeading: true,
        showProfileIcon: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.account, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(AppLocalizations.of(context).uranusCode),
              subtitle: const Text('Youtube Channel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD), 
                child: Icon(Icons.bar_chart, color: Color(0xFF2196F3))
              ),
              title: Text(t.statistics),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/statistics');
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E8), 
                child: Icon(Icons.emoji_events, color: Color(0xFF4CAF50))
              ),
              title: Text(t.goalAndAchievement),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/goals-achievements',
                  arguments: {'fromSettings': true},
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(t.settings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          // Language
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFE4B5), child: Icon(Icons.language, color: Colors.orange)),
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
                      DropdownMenuItem(value: const Locale('en'), child: Text(t.english)),
                      DropdownMenuItem(value: const Locale('th'), child: Text(t.thai)),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Notifications
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.notifications, color: Color(0xFF2196F3))),
              title: Text(t.notifications),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/notification-settings');
              },
            ),
          ),
          const SizedBox(height: 12),
          // Dark Mode Switch
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF3E5F5), child: Icon(Icons.dark_mode, color: Color(0xFF9C27B0))),
              title: Text(t.darkMode),
              trailing: Selector<ThemeProvider, ThemeMode>(
                selector: (_, p) => p.mode,
                builder: (context, mode, __) {
                  final isDark = mode == ThemeMode.dark;
                  return Switch(
                    value: isDark,
                    onChanged: (v) {
                      context.read<ThemeProvider>().setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sign Out tile (placeholder only)
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.logout, color: Color(0xFFF44336))),
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
