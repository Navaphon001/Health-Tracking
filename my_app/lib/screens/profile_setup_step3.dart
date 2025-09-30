import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../providers/physical_info_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';
import '../shared/custom_top_app_bar.dart';
import '../services/about_yourself_service.dart';

class ProfileSetupStep3 extends StatefulWidget {
  const ProfileSetupStep3({super.key});

  @override
  State<ProfileSetupStep3> createState() => _ProfileSetupStep3State();
}

class _ProfileSetupStep3State extends State<ProfileSetupStep3> {
  bool _isLoading = false;

  // SnackBar callback
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Save about yourself data to API
  Future<bool> _saveAboutYourself() async {
    setState(() => _isLoading = true);
    
    try {
      final phys = context.read<PhysicalInfoProvider>();
      final profile = context.read<ProfileSetupProvider>();
      
      // Generate a unique ID for the about yourself info
      const uuid = Uuid();
      final aboutId = uuid.v4();
      
      // Create health description from health rating and goals
      String? healthDescription;
      if (phys.healthRating != null) {
        healthDescription = 'Health rating: ${phys.healthRating}';
      }
      
      String? healthGoal;
      if (profile.goals.isNotEmpty) {
        healthGoal = profile.goals.join(', ');
      }
      
      final result = await AboutYourselfService.createAboutYourself(
        id: aboutId,
        healthDescription: healthDescription,
        healthGoal: healthGoal,
        snackFn: _showSnackBar,
      );
      
      return result != null;
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    final healthRating = context.select<PhysicalInfoProvider, String?>((p) => p.healthRating);
    final goals = context.select<ProfileSetupProvider, List<String>>((p) => p.goals);

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.profileSetup,
        automaticallyImplyLeading: true,
        showProfileIcon: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            // Top row: title and step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.aboutYourself, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(t.stepOf(3, 3), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: 3 / 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              color: theme.brightness == Brightness.light ? gradientStart : primary,
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
                  onTap: () {
                    final provider = context.read<PhysicalInfoProvider>();
                    if (provider.healthRating == 'poor') {
                      provider.setHealthRating(null);
                    } else {
                      provider.setHealthRating('poor');
                    }
                  },
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😐',
                  label: t.healthFair,
                  value: 'fair',
                  selected: healthRating == 'fair',
                  onTap: () {
                    final provider = context.read<PhysicalInfoProvider>();
                    if (provider.healthRating == 'fair') {
                      provider.setHealthRating(null);
                    } else {
                      provider.setHealthRating('fair');
                    }
                  },
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😊',
                  label: t.healthGood,
                  value: 'good',
                  selected: healthRating == 'good',
                  onTap: () {
                    final provider = context.read<PhysicalInfoProvider>();
                    if (provider.healthRating == 'good') {
                      provider.setHealthRating(null);
                    } else {
                      provider.setHealthRating('good');
                    }
                  },
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '😃',
                  label: t.healthGreat,
                  value: 'great',
                  selected: healthRating == 'great',
                  onTap: () {
                    final provider = context.read<PhysicalInfoProvider>();
                    if (provider.healthRating == 'great') {
                      provider.setHealthRating(null);
                    } else {
                      provider.setHealthRating('great');
                    }
                  },
                  textStyle: textStyle,
                  isDark: isDark,
                  primary: primary,
                ),
                _HealthRatingItem(
                  emoji: '🤩',
                  label: t.healthExcellent,
                  value: 'excellent',
                  selected: healthRating == 'excellent',
                  onTap: () {
                    final provider = context.read<PhysicalInfoProvider>();
                    if (provider.healthRating == 'excellent') {
                      provider.setHealthRating(null);
                    } else {
                      provider.setHealthRating('excellent');
                    }
                  },
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
                  onPressed: _isLoading ? null : () async {
                    final phys = context.read<PhysicalInfoProvider>();
                    final profile = context.read<ProfileSetupProvider>();
                    final health = (phys.healthRating ?? '').trim();
                    final goalsList = profile.goals;

                    if (health.isEmpty && (goalsList.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a health rating or at least one goal')));
                      return;
                    }

                    // Save data to API first
                    final success = await _saveAboutYourself();
                    
                    if (success) {
                      // Show completion message and navigate to dashboard
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).profileSetupCompleted)),
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
                      }
                    }
                  },
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(t.finish),
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
              color: selected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
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
    final selectedFill = dark ? Colors.white.withValues(alpha: 0.06) : primaryColor.withValues(alpha: 0.12);
    final selectedBorder = dark ? ivoryColor.withValues(alpha: 0.8) : primaryColor;
    
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
                    color: primaryColor.withValues(alpha: 0.18),
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
                    : (dark ? ivoryColor.withValues(alpha: 0.7) : theme.iconTheme.color),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: dark
                      ? ivoryColor
                      : (selected ? primaryColor : null),
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