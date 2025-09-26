import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/notification_provider.dart';
import '../shared/custom_top_app_bar.dart';
import '../theme/app_colors.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.notifications,
        automaticallyImplyLeading: true,
        showProfileIcon: false,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.gradientLightEnd.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.notificationSettings,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.notificationSettingsDescription,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Health Reminders Section
              Text(
                t.healthReminders,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),

              // Water Reminder
              _buildNotificationTile(
                context: context,
                icon: Icons.water_drop,
                iconColor: AppColors.primary,
                iconBackgroundColor: AppColors.primary.withOpacity(0.1),
                title: t.waterReminder,
                subtitle: t.waterReminderDescription,
                value: notificationProvider.waterReminderEnabled,
                onChanged: (value) {
                  notificationProvider.toggleWaterReminder(value);
                },
              ),

              const SizedBox(height: 12),

              // Exercise Reminder
              _buildNotificationTile(
                context: context,
                icon: Icons.fitness_center,
                iconColor: Colors.orange,
                iconBackgroundColor: Colors.orange.withOpacity(0.1),
                title: t.exerciseReminder,
                subtitle: t.exerciseReminderDescription,
                value: notificationProvider.exerciseReminderEnabled,
                onChanged: (value) {
                  notificationProvider.toggleExerciseReminder(value);
                },
              ),

              const SizedBox(height: 12),

              // Sleep Reminder
              _buildNotificationTile(
                context: context,
                icon: Icons.bedtime,
                iconColor: Colors.purple,
                iconBackgroundColor: Colors.purple.withOpacity(0.1),
                title: t.sleepReminder,
                subtitle: t.sleepReminderDescription,
                value: notificationProvider.sleepReminderEnabled,
                onChanged: (value) {
                  notificationProvider.toggleSleepReminder(value);
                },
              ),

              const SizedBox(height: 12),

              // Meal Logging Reminder
              _buildNotificationTile(
                context: context,
                icon: Icons.restaurant,
                iconColor: Colors.green,
                iconBackgroundColor: Colors.green.withOpacity(0.1),
                title: t.mealLoggingReminder,
                subtitle: t.mealLoggingReminderDescription,
                value: notificationProvider.mealLoggingEnabled,
                onChanged: (value) {
                  notificationProvider.toggleMealLogging(value);
                },
              ),

              const SizedBox(height: 32),

              // Reset to Default Button (without header)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showResetConfirmationDialog(context, notificationProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(t.resetToDefault),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    NotificationProvider notificationProvider,
  ) {
    final t = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.refresh,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(t.resetToDefault),
            ],
          ),
          content: Text(t.resetNotificationConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                notificationProvider.resetToDefault();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.notificationSettingsReset),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(t.reset),
            ),
          ],
        );
      },
    );
  }
}