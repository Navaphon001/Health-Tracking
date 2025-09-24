import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/physical_info_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';

class ProfileSetupStep2 extends StatelessWidget {
  const ProfileSetupStep2({super.key});

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
    final weight = context.select<PhysicalInfoProvider, String?>((p) => p.weight);
    final height = context.select<PhysicalInfoProvider, String?>((p) => p.height);
    final activityLevel = context.select<ProfileSetupProvider, String?>((p) => p.activityLevel);

    final weightCtrl = TextEditingController(text: weight ?? '');
    final heightCtrl = TextEditingController(text: height ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            // Top row: title and step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.physicalInfo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(t.stepOf(2, 3), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: 2 / 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              color: theme.brightness == Brightness.light ? gradientStart : primary,
              minHeight: 8,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 24),

            // Weight and Height inputs
            Row(
              children: [
                Expanded(
                  child: _RoundedTextField(
                    controller: weightCtrl,
                    label: t.weight,
                    hint: 'กก.',
                    onChanged: context.read<PhysicalInfoProvider>().setWeight,
                    textStyle: textStyle,
                    isDark: isDark,
                    ivory: ivory,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoundedTextField(
                    controller: heightCtrl,
                    label: t.height,
                    hint: 'ซม.',
                    onChanged: context.read<PhysicalInfoProvider>().setHeight,
                    textStyle: textStyle,
                    isDark: isDark,
                    ivory: ivory,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Activity Level section
            Text(t.activityLevel, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 12),

            _ActivityLevelCard(
              label: t.sedentary,
              description: 'Little to no exercise',
              value: 'sedentary',
              selected: activityLevel == 'sedentary',
              isDark: isDark,
              ivory: ivory,
              primary: primary,
              onTap: () => context.read<ProfileSetupProvider>().setActivityLevel('sedentary'),
            ),
            const SizedBox(height: 8),

            _ActivityLevelCard(
              label: t.lightlyActive,
              description: 'Light exercise 1-3 days/week',
              value: 'lightly_active',
              selected: activityLevel == 'lightly_active',
              isDark: isDark,
              ivory: ivory,
              primary: primary,
              onTap: () => context.read<ProfileSetupProvider>().setActivityLevel('lightly_active'),
            ),
            const SizedBox(height: 8),

            _ActivityLevelCard(
              label: t.moderatelyActive,
              description: 'Moderate exercise 3-5 days/week',
              value: 'moderately_active',
              selected: activityLevel == 'moderately_active',
              isDark: isDark,
              ivory: ivory,
              primary: primary,
              onTap: () => context.read<ProfileSetupProvider>().setActivityLevel('moderately_active'),
            ),
            const SizedBox(height: 8),

            _ActivityLevelCard(
              label: t.veryActive,
              description: 'Hard exercise 6-7 days/week',
              value: 'very_active',
              selected: activityLevel == 'very_active',
              isDark: isDark,
              ivory: ivory,
              primary: primary,
              onTap: () => context.read<ProfileSetupProvider>().setActivityLevel('very_active'),
            ),

            const SizedBox(height: 32),

            // Next button with gradient
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

                    final isValidWH = phys.isAllValid; // มีใน PhysicalInfoProvider
                    final hasAct = (prof.activityLevel ?? '').isNotEmpty;

                    if (!isValidWH || !hasAct) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกน้ำหนัก/ส่วนสูง และเลือกระดับกิจกรรม')),
                      );
                      return;
                    }

                    // แปลงค่าเป็น double และสะท้อนเข้า ProfileSetupProvider
                    final w = double.tryParse(phys.weight!.trim());
                    final h = double.tryParse(phys.height!.trim());
                    if (w == null || h == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('รูปแบบตัวเลขไม่ถูกต้อง')),
                      );
                      return;
                    }

                    prof.setWeight(w);
                    prof.setHeight(h);

                    // ตั้ง healthGoal ชั่วคราวถ้ายังไม่ได้เลือก (เพราะ saveStep2 ต้องการ)
                    if ((prof.healthGoal ?? '').isEmpty) {
                      prof.setHealthGoal('general'); // default placeholder
                    }

                    const userId = 'local'; // ยังเป็น mock login
                    await prof.saveStep2(userId);

                    if (context.mounted) {
                      Navigator.of(context).pushNamed('/profile-setup-step3');
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

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final bool? isDark;
  final Color? ivory;
  final TextInputType? keyboardType;

  const _RoundedTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.onChanged,
    this.textStyle,
    this.isDark,
    this.ivory,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = isDark ?? theme.brightness == Brightness.dark;
    final ivoryColor = ivory ?? const Color(0xFFFFFDF6);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withOpacity(0.9) : null),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withOpacity(0.7) : theme.hintColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? ivoryColor.withOpacity(0.4) : theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? ivoryColor.withOpacity(0.3) : theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? ivoryColor : theme.colorScheme.primary, width: 1.6),
        ),
      ),
      style: textStyle,
    );
  }
}

class _ActivityLevelCard extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final bool? isDark;
  final Color? ivory;
  final Color? primary;

  const _ActivityLevelCard({
    required this.label,
    required this.description,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: dark ? ivoryColor : (selected ? primaryColor : null),
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: dark
                      ? ivoryColor.withOpacity(0.7)
                      : (selected ? primaryColor.withOpacity(0.8) : theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
