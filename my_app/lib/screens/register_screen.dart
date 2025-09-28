import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

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
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.passwordMismatch),
          backgroundColor: Colors.red.shade700),
      );
      return;
    }

    final auth = context.read<AuthNotifier>();
    final success = await auth.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  Widget _field({
    required TextEditingController c,
    required String hint,
    String? errorText,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: type,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF0ABAB5), width: 2)),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Colors.red, width: 2)),
        errorText: errorText,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthNotifier>();

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
                    colors: [Color(0xFF56DFCF), Color(0xFF0ABAB5)],
                  ),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2, blurRadius: 10, offset: const Offset(0,5),
                  )],
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 40),
              Text(t.createYourAccount,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 40),

              _field(
                c: _username, hint: t.username,
                errorText: auth.usernameError,
                validator: (v) => (v == null || v.isEmpty) ? t.pleaseEnterUsername : null,
              ),
              const SizedBox(height: 20),

              _field(
                c: _email, hint: t.email, type: TextInputType.emailAddress,
                errorText: auth.emailError,
                validator: (v) {
                  if (v == null || v.isEmpty) return t.pleaseEnterAnEmail;
                  final r = RegExp(r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!r.hasMatch(v)) return t.invalidEmailFormat;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _field(
                c: _password, hint: t.password, obscure: true,
                errorText: auth.passwordError,
                validator: (v) => (v == null || v.length < 6)
                    ? t.passwordMinimum6Chars : null,
              ),
              const SizedBox(height: 20),

              _field(
                c: _confirm, hint: t.confirmPassword, obscure: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return t.pleaseConfirmPassword;
                  if (v != _password.text) return t.passwordsDoNotMatch;
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // ปุ่ม Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0ABAB5), Color(0xFF56DFCF)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF0ABAB5).withOpacity(0.4),
                    spreadRadius: 2, blurRadius: 8, offset: const Offset(0,4),
                  )],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: auth.isLoading ? null : _doRegister,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: auth.isLoading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(t.createAccount,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(t.haveAnAccount, style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
                  child: Text(t.signIn,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
