import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../shared/custom_top_app_bar.dart';
import '../theme/app_colors.dart';

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
              onTap: () {
                Navigator.pushNamed(context, '/profile-settings');
              },
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
          // Sign Out tile
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.logout, color: Color(0xFFF44336))),
              title: Text(t.signOut),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    final theme = Theme.of(ctx);
                    final primary = theme.colorScheme.primary;
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.logout, color: primary),
                                const SizedBox(width: 12),
                                Expanded(child: Text(t.signOut, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('ต้องการออกจากระบบใช่หรือไม่?', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text(AppLocalizations.of(ctx).cancel),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.gradientLightEnd]),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text('ตกลง', style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );

                if (confirmed == true) {
                  // Navigate to login and clear history
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
