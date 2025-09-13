import 'dart:async';
import 'package:flutter/foundation.dart';

typedef SnackFn = void Function(String message, {bool isError});

class AuthNotifier extends ChangeNotifier {
  String? usernameError;
  String? emailError;
  String? passwordError;
  bool isLoading = false;

  SnackFn? _snackFn;
  void setSnackBarCallback(SnackFn fn) => _snackFn = fn;

  // -------- Login (mock) --------
  Future<void> login(String email, String password) async {
    emailError = null; passwordError = null;

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
      return;
    }

    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading = false; notifyListeners();

    _snackFn?.call('เข้าสู่ระบบสำเร็จ');
  }

  // -------- Register (mock) --------
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    usernameError = null; emailError = null; passwordError = null;

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
      return;
    }

    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    isLoading = false; notifyListeners();

    _snackFn?.call('สมัครสมาชิกสำเร็จ');
  }
}
