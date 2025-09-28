import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/profile_setup_provider.dart';
import '../theme/app_colors.dart';
import '../shared/profile_image_picker.dart';
import '../shared/custom_top_app_bar.dart';

class ProfileSetupStep1 extends StatefulWidget {
  const ProfileSetupStep1({super.key});

  @override
  State<ProfileSetupStep1> createState() => _ProfileSetupStep1State();
}

class _ProfileSetupStep1State extends State<ProfileSetupStep1> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _nameError;
  String? _dobError;
  String? _genderError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
    if (picked != null) {
      provider.setBirthDate(picked);
      if (_dobError != null) setState(() => _dobError = null);
    }
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
  
  // Update controller text only when provider value changes
  if (_nameController.text != (name ?? '')) {
    _nameController.text = name ?? '';
  }

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

            const SizedBox(height: 16),

            // Profile image
            const ProfileImagePicker(),
            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(children: [
                // Name
                _RoundedTextField(
                  controller: _nameController,
                  label: t.name,
                  hint: t.nameHint,
                  onChanged: (v) {
                    context.read<ProfileSetupProvider>().setFullName(v);
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  textStyle: textStyle,
                  isDark: isDark,
                  ivory: ivory,
                  borderColor: _nameError != null ? Colors.red : Colors.grey.shade300,
                  errorText: _nameError,
                ),
                const SizedBox(height: 12),

                // DOB
                _RoundedTextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: dob == null ? '' : '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}',
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
                  borderColor: _dobError != null ? Colors.red : Colors.grey.shade300,
                  errorText: _dobError,
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.gender, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                ),
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
                        onTap: () {
                              final provider = context.read<ProfileSetupProvider>();
                              // toggle: if already selected, clear selection
                              if (provider.gender == 'male') {
                                provider.setGender(null);
                              } else {
                                provider.setGender('male');
                              }
                              if (_genderError != null) setState(() => _genderError = null);
                            },
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
                        onTap: () {
                          final provider = context.read<ProfileSetupProvider>();
                          if (provider.gender == 'female') {
                            provider.setGender(null);
                          } else {
                            provider.setGender('female');
                          }
                          if (_genderError != null) setState(() => _genderError = null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _GenderCard(
                  label: t.other,
                  icon: Icons.transgender,
                  selected: gender == 'other',
                  isDark: isDark,
                  ivory: ivory,
                  primary: primary,
                  onTap: () {
                    final provider = context.read<ProfileSetupProvider>();
                    if (provider.gender == 'other') {
                      provider.setGender(null);
                    } else {
                      provider.setGender('other');
                    }
                    if (_genderError != null) setState(() => _genderError = null);
                  },
                ),
                // show gender error below buttons
                if (_genderError != null) ...[
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text(_genderError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                ],
              ]),
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
                    // Validate form: require name, dob, gender. Avatar is optional.
                    final provider = context.read<ProfileSetupProvider>();
                    final nameValid = _nameController.text.trim().isNotEmpty;
                    final dobValid = provider.birthDate != null;
                    final genderValid = (provider.gender ?? '').isNotEmpty;

                    // Validate and set inline errors (avatar optional)
                    setState(() {
                      _nameError = nameValid ? null : 'Please enter your name';
                      _dobError = dobValid ? null : 'Please pick your date of birth';
                      _genderError = genderValid ? null : 'Please select gender';
                    });

                    if (_nameError == null && _dobError == null && _genderError == null) {
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
  final String? errorText;
  final TextStyle? textStyle;
  final bool? isDark;
  final Color? ivory;
  final Color? borderColor;
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
    this.borderColor,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = isDark ?? theme.brightness == Brightness.dark;
    final ivoryColor = ivory ?? const Color(0xFFFFFDF6);
    final hasError = errorText != null && errorText!.isNotEmpty;
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
        decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: dark ? ivoryColor.withOpacity(0.9) : Colors.black,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: dark ? ivoryColor.withOpacity(0.7) : theme.hintColor,
        ),
        suffixIconColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 4.0,
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? Colors.black), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 4.0,
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? Colors.black), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 4.0,
          borderSide: BorderSide(color: hasError ? Colors.red : (borderColor ?? Colors.black), width: 2),
        ),
        errorText: errorText,
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
    final primaryColor = primary ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.gradientLightEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: selected
              ? null
              : (theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
      border: selected
        ? null
        : Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
