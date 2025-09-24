import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/physical_info_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';

class ProfileSetupStep3 extends StatelessWidget {
  const ProfileSetupStep3({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    const ivory = AppColors.darkIvory;
    const btnTextColor = Colors.white;
    const gradientStart = AppColors.primaryLight;
    const gradientEnd = AppColors.gradientLightEnd;

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? ivory : const Color(0xFF000000),
    );

    // Use selectors for granular updates
    final healthRating =
        context.select<PhysicalInfoProvider, String?>((p) => p.healthRating);
    final goals =
        context.select<ProfileSetupProvider, List<String>>((p) => p.goals);

    void _setHealth(BuildContext ctx, String value) {
      // อัปเดตทั้ง PhysicalInfoProvider และ ProfileSetupProvider ให้ตรงกัน
      ctx.read<PhysicalInfoProvider>().setHealthRating(value);
      ctx.read<ProfileSetupProvider>().setHealthRating(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutYourself),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            // Top row: title and step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.aboutYourself,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(t.stepOf(3, 3), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: 3 / 3,
              backgroundColor:
                  theme.colorScheme.surfaceVariant.withOpacity(0.4),
              color: theme.brightness == Brightness.light
                  ? gradientStart
                  : primary,
              minHeight: 8,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 24),

            // Health Rating Question
            Text(
              t.healthRatingQuestion,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Health Rating Emojis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HealthRatingItem(
                  emoji: '😷',
                  label: t.healthPoor,
                  value: 'poor',
                  selected: healthRating == 'poor',
                  onTap: () => _setHealth(context, 'poor'),
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😐',
                  label: t.healthFair,
                  value: 'fair',
                  selected: healthRating == 'fair',
                  onTap: () => _setHealth(context, 'fair'),
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😊',
                  label: t.healthGood,
                  value: 'good',
                  selected: healthRating == 'good',
                  onTap: () => _setHealth(context, 'good'),
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😃',
                  label: t.healthGreat,
                  value: 'great',
                  selected: healthRating == 'great',
                  onTap: () => _setHealth(context, 'great'),
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '🤩',
                  label: t.healthExcellent,
                  value: 'excellent',
                  selected: healthRating == 'excellent',
                  onTap: () => _setHealth(context, 'excellent'),
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Goals Section
            Text(
              t.yourGoals,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Goals List
            _GoalCard(
              icon: Icons.trending_down,
              label: t.goalLoseWeight,
              value: 'lose_weight',
              selected: goals.contains('lose_weight'),
              onTap: () => context.read<ProfileSetupProvider>().toggleGoal('lose_weight'),
              isDark: isDark,
              ivory: ivory,
              primary: primary,
            ),
            const SizedBox(height: 8),
            _GoalCard(
              icon: Icons.fitness_center,
              label: t.goalBuildMuscle,
              value: 'build_muscle',
              selected: goals.contains('build_muscle'),
              onTap: () => context.read<ProfileSetupProvider>().toggleGoal('build_muscle'),
              isDark: isDark,
              ivory: ivory,
              primary: primary,
            ),
            const SizedBox(height: 8),
            _GoalCard(
              icon: Icons.directions_run,
              label: t.goalImproveFitness,
              value: 'improve_fitness',
              selected: goals.contains('improve_fitness'),
              onTap: () => context.read<ProfileSetupProvider>().toggleGoal('improve_fitness'),
              isDark: isDark,
              ivory: ivory,
              primary: primary,
            ),
            const SizedBox(height: 8),
            _GoalCard(
              icon: Icons.bedtime,
              label: t.goalBetterSleep,
              value: 'better_sleep',
              selected: goals.contains('better_sleep'),
              onTap: () => context.read<ProfileSetupProvider>().toggleGoal('better_sleep'),
              isDark: isDark,
              ivory: ivory,
              primary: primary,
            ),
            const SizedBox(height: 8),
            _GoalCard(
              icon: Icons.restaurant,
              label: t.goalEatHealthier,
              value: 'eat_healthier',
              selected: goals.contains('eat_healthier'),
              onTap: () => context.read<ProfileSetupProvider>().toggleGoal('eat_healthier'),
              isDark: isDark,
              ivory: ivory,
              primary: primary,
            ),

            const SizedBox(height: 32),

            // Complete button with gradient
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: btnTextColor,
                  ),
                  onPressed: () async {
                    final phys = context.read<PhysicalInfoProvider>();
                    final prof = context.read<ProfileSetupProvider>();

                    // ensure health rating is synced to ProfileSetupProvider
                    if ((prof.healthRating ?? '').isEmpty && (phys.healthRating ?? '').isNotEmpty) {
                      prof.setHealthRating(phys.healthRating);
                    }

                    if ((prof.healthRating ?? '').isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเลือกความพึงพอใจสุขภาพก่อน')),
                      );
                      return;
                    }

                    const userId = 'local'; // ใช้ชั่วคราวช่วง mock login
                    await prof.saveStep3(userId); // ภายในมี markProfileCompleted แล้ว

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile setup completed!')),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                    }
                  },
                  child: Text(t.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthRatingItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final bool? isDark;
  final Color? primary;

  const _HealthRatingItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.textStyle,
    this.isDark,
    this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = primary ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: selected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: selected ? primaryColor : textStyle?.color,
              fontWeight: selected ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final bool? isDark;
  final Color? ivory;
  final Color? primary;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.isDark,
    this.ivory,
    this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = isDark ?? theme.brightness == Brightness.dark;
    final ivoryColor = ivory ?? const Color(0xFFFFFDF6);
    final primaryColor = primary ?? theme.colorScheme.primary;
    final baseBorder = theme.colorScheme.outline;
    final selectedFill = dark ? Colors.white.withOpacity(0.06) : primaryColor.withOpacity(0.12);
    final selectedBorder = dark ? ivoryColor.withOpacity(0.8) : primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 60,
        decoration: BoxDecoration(
          color: selected ? selectedFill : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? selectedBorder : baseBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected && !dark
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? (dark ? ivoryColor : primaryColor)
                    : (dark ? ivoryColor.withOpacity(0.7) : theme.iconTheme.color),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: dark ? ivoryColor : (selected ? primaryColor : null),
                  fontWeight: selected ? FontWeight.w500 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
