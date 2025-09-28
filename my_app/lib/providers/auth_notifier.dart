import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/token_storage.dart';
import '../shared/snack_fn.dart';
import '../syncronize/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  String? usernameError;
  String? emailError;
  String? passwordError;
  bool isLoading = false;

  SnackFn? _snackFn;
  void setSnackBarCallback(SnackFn fn) => _snackFn = fn;

  // -------- Login (mock) --------
  Future<bool> login(String email, String password) async {
    emailError = null; 
    passwordError = null;

    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (email.isEmpty) {
      emailError = 'กรุณากรอกอีเมล';
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    if (password.isEmpty) {
      passwordError = 'กรุณากรอกรหัสผ่าน';
    } else if (password.length < 6) {
      passwordError = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    if (emailError != null || passwordError != null) {
      notifyListeners();
      _snackFn?.call('กรุณาตรวจสอบข้อมูลให้ครบถ้วน', isError: true);
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final tokenResp = await authService.login(email, password);

      // Persist token (secure storage preferred, fallback to prefs)
      await _persistToken(tokenResp.accessToken, tokenResp.tokenType);

      _snackFn?.call('เข้าสู่ระบบสำเร็จ');
      return true;
    } catch (e) {
      final err = e.toString();
      // If server returned 401 Unauthorized, treat as invalid credentials and stay on page
      if (err.contains('401')) {
        _snackFn?.call('อีเมลหรือรหัสผ่านไม่ถูกต้อง', isError: true);
        return false;
      }
      // Other errors (network, server) show general message
      _snackFn?.call('Login failed: ${err}', isError: true);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistToken(String? accessToken, String? tokenType) async {
    try {
      final secure = const FlutterSecureStorage();
      await secure.write(key: 'access_token', value: accessToken);
      await secure.write(key: 'token_type', value: tokenType);
      return;
    } catch (_) {
      // Any other error -> fallback
      final storage = await TokenStorage.getInstance();
      await storage.write('access_token', accessToken);
      await storage.write('token_type', tokenType);
      return;
    }
  }

  // -------- Register (mock) --------
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    usernameError = null; 
    emailError = null; 
    passwordError = null;

    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (username.isEmpty) {
      usernameError = 'กรุณากรอกชื่อผู้ใช้';
    } else if (username.length < 3) {
      usernameError = 'ชื่อผู้ใช้ต้องยาวอย่างน้อย 3 ตัวอักษร';
    }
    if (email.isEmpty) {
      emailError = 'กรุณากรอกอีเมล';
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    if (password.isEmpty) {
      passwordError = 'กรุณากรอกรหัสผ่าน';
    } else if (password.length < 6) {
      passwordError = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    if (usernameError != null || emailError != null || passwordError != null) {
      notifyListeners();
      _snackFn?.call('กรุณาตรวจสอบข้อมูลให้ครบถ้วน', isError: true);
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
    // AuthService.register throws on non-200 and returns TokenResponse on success
    final tokenResp = await authService.register(username, email, password);

    // Persist token if returned (store securely when possible)
    await _persistToken(tokenResp.accessToken, tokenResp.tokenType);

    // Registration succeeded.
    _snackFn?.call('สมัครสมาชิกสำเร็จ');
    return true;
    } catch (e) {
      final err = e.toString();

      // Try to extract JSON body if the exception includes it (AuthService throws 'Register failed: <status> <body>')
      String messageToShow = 'สมัครสมาชิกไม่สำเร็จ';
      try {
        final idx = err.indexOf('{');
        if (idx != -1) {
          final body = err.substring(idx);
          final parsed = body.isNotEmpty ? Uri.decodeFull(body) : body;
          // attempt to parse JSON
          final m = parsed.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(parsed)) : null;
          if (m != null) {
            // If server returned field errors, assign them to field error vars
            if (m.containsKey('username')) {
              final v = m['username'];
              usernameError = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
            }
            if (m.containsKey('email')) {
              final v = m['email'];
              emailError = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
            }
            if (m.containsKey('password')) {
              final v = m['password'];
              passwordError = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
            }
            // common message fields
            if (m.containsKey('detail')) messageToShow = m['detail'].toString();
            else if (m.containsKey('message')) messageToShow = m['message'].toString();
            else if (usernameError != null || emailError != null || passwordError != null) {
              // prefer field error as message if available
              messageToShow = usernameError ?? emailError ?? passwordError!;
            } else {
              messageToShow = m.toString();
            }
          } else {
            messageToShow = err;
          }
        } else {
          messageToShow = err;
        }
      } catch (_) {
        // fallback
        messageToShow = err;
      }

      notifyListeners();
      _snackFn?.call(messageToShow, isError: true);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
