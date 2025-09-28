import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/physical_info_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';
import '../shared/custom_top_app_bar.dart';

class ProfileSetupStep2 extends StatefulWidget {
  const ProfileSetupStep2({super.key});

  @override
  State<ProfileSetupStep2> createState() => _ProfileSetupStep2State();
}

class _ProfileSetupStep2State extends State<ProfileSetupStep2> {
  String? _weightError;
  String? _heightError;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;

  @override
  void initState() {
    super.initState();
    final phys = context.read<PhysicalInfoProvider>();
    _weightCtrl = TextEditingController(text: phys.weight ?? '');
    _heightCtrl = TextEditingController(text: phys.height ?? '');

    _weightCtrl.addListener(() {
      final raw = _weightCtrl.text;
      final normalized = _normalizeNumber(raw);
      if (normalized != raw) {
        _weightCtrl.value = TextEditingValue(
          text: normalized,
          selection: TextSelection.collapsed(offset: normalized.length),
        );
      }
      context.read<PhysicalInfoProvider>().setWeight(normalized);
    });

    _heightCtrl.addListener(() {
      final raw = _heightCtrl.text;
      final normalized = _normalizeNumber(raw);
      if (normalized != raw) {
        _heightCtrl.value = TextEditingValue(
          text: normalized,
          selection: TextSelection.collapsed(offset: normalized.length),
        );
      }
      context.read<PhysicalInfoProvider>().setHeight(normalized);
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String _normalizeNumber(String input) {
    // allow digits and a single decimal point (dot). Replace comma with dot.
    var s = input.replaceAll(',', '.');
    // remove all chars except digits and dot
    s = s.replaceAll(RegExp('[^0-9.]'), '');
    final firstDot = s.indexOf('.');
    if (firstDot >= 0) {
      final before = s.substring(0, firstDot);
      final after = s.substring(firstDot + 1).replaceAll('.', '');
      s = '$before.${after}';
    }
    return s;
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
  final activityLevel = context.select<ProfileSetupProvider, String?>((p) => p.activityLevel);
    
  // use persistent controllers created in state
  final weightCtrl = _weightCtrl;
  final heightCtrl = _heightCtrl;

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
                Text(t.physicalInfo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(t.stepOf(2, 3), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: 2 / 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                    onChanged: (_) {
                      if (_weightError != null) setState(() => _weightError = null);
                    },
                    textStyle: textStyle,
                    isDark: isDark,
                    ivory: ivory,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
                    borderColor: _weightError != null ? Colors.red : null,
                    errorText: _weightError,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoundedTextField(
                    controller: heightCtrl,
                    label: t.height,
                    hint: 'ซม.',
                    onChanged: (_) {
                      if (_heightError != null) setState(() => _heightError = null);
                    },
                    textStyle: textStyle,
                    isDark: isDark,
                    ivory: ivory,
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    borderColor: _heightError != null ? Colors.red : null,
                    errorText: _heightError,
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
              onTap: () {
                final provider = context.read<ProfileSetupProvider>();
                if (provider.activityLevel == 'sedentary') {
                  provider.setActivityLevel(null);
                } else {
                  provider.setActivityLevel('sedentary');
                }
              },
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
              onTap: () {
                final provider = context.read<ProfileSetupProvider>();
                if (provider.activityLevel == 'lightly_active') {
                  provider.setActivityLevel(null);
                } else {
                  provider.setActivityLevel('lightly_active');
                }
              },
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
              onTap: () {
                final provider = context.read<ProfileSetupProvider>();
                if (provider.activityLevel == 'moderately_active') {
                  provider.setActivityLevel(null);
                } else {
                  provider.setActivityLevel('moderately_active');
                }
              },
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
              onTap: () {
                final provider = context.read<ProfileSetupProvider>();
                if (provider.activityLevel == 'very_active') {
                  provider.setActivityLevel(null);
                } else {
                  provider.setActivityLevel('very_active');
                }
              },
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
                  onPressed: () {
                    final phys = context.read<PhysicalInfoProvider>();
                    final profile = context.read<ProfileSetupProvider>();
                    final weightVal = (phys.weight ?? '').trim();
                    final heightVal = (phys.height ?? '').trim();
                    final activity = (profile.activityLevel ?? '').trim();

                    bool hasError = false;
                    setState(() {
                      _weightError = null;
                      _heightError = null;
                    });

                    if (weightVal.isEmpty || double.tryParse(weightVal) == null) {
                      setState(() => _weightError = 'Please enter a valid weight');
                      hasError = true;
                    }
                    if (heightVal.isEmpty || double.tryParse(heightVal) == null) {
                      setState(() => _heightError = 'Please enter a valid height');
                      hasError = true;
                    }
                    if (activity.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select activity level')));
                      hasError = true;
                    }

                    if (hasError) return;

                    Navigator.of(context).pushNamed('/profile-setup-step3');
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
  final String? errorText;
  final Color? borderColor;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final bool? isDark;
  final Color? ivory;
  final TextInputType? keyboardType;
  
  const _RoundedTextField({
    required this.controller,
    required this.label,
    this.hint,
  this.onChanged,
  this.inputFormatters,
    this.errorText,
    this.borderColor,
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
    final hasError = errorText != null && errorText!.isNotEmpty;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withValues(alpha: 0.9) : null),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: dark ? ivoryColor.withValues(alpha: 0.7) : theme.hintColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? (dark ? ivoryColor.withValues(alpha: 0.4) : theme.colorScheme.outline)))
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? (dark ? ivoryColor.withValues(alpha: 0.3) : theme.colorScheme.outline)))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? (dark ? ivoryColor : theme.colorScheme.primary)), width: 1.6)
        ),
        errorText: errorText,
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
    final selectedFill = dark ? Colors.white.withValues(alpha: 0.06) : primaryColor.withValues(alpha: 0.12);
    final selectedBorder = dark ? ivoryColor.withValues(alpha: 0.8) : primaryColor;
    
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
                    color: primaryColor.withValues(alpha: 0.18),
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
                  color: dark
                      ? ivoryColor
                      : (selected ? primaryColor : null),
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: dark
                      ? ivoryColor.withValues(alpha: 0.7)
                      : (selected ? primaryColor.withValues(alpha: 0.8) : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}