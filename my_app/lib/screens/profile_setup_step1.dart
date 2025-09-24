import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';

class ProfileSetupStep1 extends StatelessWidget {
  const ProfileSetupStep1({super.key});

  Future<void> _pickDob(BuildContext context) async {
    final provider = context.read<ProfileSetupProvider>();
    final current = provider.birthDate;
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: current ?? initial,
    );
    if (picked != null) provider.setBirthDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    const ivory = AppColors.darkIvory; // use centralized dark ivory
    const btnTextColor = Colors.white;
    const gradientStart = AppColors.primaryLight;
    const gradientEnd = AppColors.gradientLightEnd;

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? ivory : const Color(0xFF000000),
    );

    // Avoid full-page rebuilds; use selectors for granular updates.
    final name = context.select<ProfileSetupProvider, String?>((p) => p.fullName);
    final dob = context.select<ProfileSetupProvider, DateTime?>((p) => p.birthDate);
    final gender = context.select<ProfileSetupProvider, String?>((p) => p.gender);
    final nameCtrl = TextEditingController(text: name ?? '');

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
                Text(t.profile, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(t.stepOf(1, 3), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: 1 / 3,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              color: theme.brightness == Brightness.light ? gradientStart : primary,
              minHeight: 8,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 24),

            // Name
            _RoundedTextField(
              controller: nameCtrl,
              label: t.name,
              hint: t.nameHint,
              onChanged: context.read<ProfileSetupProvider>().setFullName,
              textStyle: textStyle,
              isDark: isDark,
              ivory: ivory,
            ),
            const SizedBox(height: 20),

            // DOB
            _RoundedTextField(
              readOnly: true,
              controller: TextEditingController(
                text: dob == null
                    ? ''
                    : '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}',
              ),
              label: t.dob,
              hint: t.dobHint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDob(context),
              ),
              textStyle: textStyle,
              isDark: isDark,
              ivory: ivory,
            ),
            const SizedBox(height: 12),

            // Gender section
            Text(t.gender, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    label: t.male,
                    icon: Icons.male,
                    selected: gender == 'male',
                    isDark: isDark,
                    ivory: ivory,
                    primary: primary,
                    onTap: () => context.read<ProfileSetupProvider>().setGender('male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderCard(
                    label: t.female,
                    icon: Icons.female,
                    selected: gender == 'female',
                    isDark: isDark,
                    ivory: ivory,
                    primary: primary,
                    onTap: () => context.read<ProfileSetupProvider>().setGender('female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    label: t.other,
                    icon: Icons.transgender,
                    selected: gender == 'other',
                    isDark: isDark,
                    ivory: ivory,
                    primary: primary,
                    onTap: () => context.read<ProfileSetupProvider>().setGender('other'),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
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
                    final p = context.read<ProfileSetupProvider>();
                    final fullName = (p.fullName ?? '').trim();
                    final birth = p.birthDate;
                    final gen = p.gender;

                    if (fullName.isEmpty || birth == null || gen == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบก่อน')),
                      );
                      return;
                    }

                    // ถ้ายังไม่มี nickname ให้ตั้งเท่ากับชื่อไว้ก่อน
                    if ((p.nickname ?? '').trim().isEmpty) {
                      p.setNickname(fullName);
                    }

                    const userId = 'local'; // ใช้ชั่วคราวระหว่างยัง mock login
                    await p.saveStep1(userId);

                    if (context.mounted) {
                      Navigator.of(context).pushNamed('/profile-setup-step2');
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
  final bool readOnly;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final bool? isDark;
  final Color? ivory;
  const _RoundedTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.readOnly = false,
    this.suffixIcon,
    this.onChanged,
    this.textStyle,
    this.isDark,
    this.ivory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = isDark ?? theme.brightness == Brightness.dark;
    final ivoryColor = ivory ?? const Color(0xFFFFFDF6);
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withOpacity(0.9) : null),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withOpacity(0.7) : theme.hintColor),
        suffixIconColor: dark ? ivoryColor : null,
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
        suffixIcon: suffixIcon,
      ),
      style: textStyle,
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool? isDark;
  final Color? ivory;
  final Color? primary;
  const _GenderCard({
    required this.label,
    required this.icon,
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
        height: 110,
        decoration: BoxDecoration(
          color: selected ? selectedFill : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? selectedBorder : baseBorder,
          ),
          boxShadow: selected && !dark
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: dark ? ivoryColor : (selected ? primaryColor : null),
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                icon,
                size: 28,
                color: dark ? ivoryColor : (selected ? primaryColor : theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
