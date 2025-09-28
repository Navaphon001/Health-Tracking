import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthNotifier>().setSnackBarCallback((msg, {isError = false}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green),
      );
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final auth = context.read<AuthNotifier>();
    if (!_formKey.currentState!.validate()) return;

    final success = await auth.login(_email.text.trim(), _password.text.trim());
    if (success) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/profile-setup', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 60),
              // โลโก้วงกลมไล่เฉด
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.gradientLightEnd, AppColors.primary],
                  ),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2, blurRadius: 10, offset: const Offset(0,5),
                  )],
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 40),
              Text(t.welcomeBack,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 40),

              // Email
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: t.email,
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: auth.emailError,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return t.pleaseEnterEmail;
                  final r = RegExp(r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!r.hasMatch(v)) return t.invalidEmailFormat;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: t.password,
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: auth.passwordError,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return t.pleaseEnterPassword;
                  if (v.length < 6) return t.passwordMinLength;
                  return null;
                },
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {/* TODO: forgot password */},
                  child: Text(t.forgotPassword),
                ),
              ),
              const SizedBox(height: 20),

              // ปุ่ม Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.gradientLightEnd],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    spreadRadius: 2, blurRadius: 8, offset: const Offset(0,4),
                  )],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: auth.isLoading ? null : _doLogin,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: auth.isLoading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(t.signIn,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(t.dontHaveAccount, style: TextStyle(color: Colors.grey[600])),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: Text(t.register,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}
