import 'package:flutter/material.dart';
import 'app_keys.dart'; // <-- ใช้ rootScaffoldMessengerKey ระดับแอป

typedef SnackFn = void Function(String message, {bool isError});

/// ใช้เรียกแสดง SnackBar ได้จากทุกที่ โดยไม่ต้องมี BuildContext
void showAppSnack(String message, {bool isError = false}) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}

/// (ทางเลือก) ถ้าอยากได้ Callback ตามรูปแบบ SnackFn
SnackFn makeAppSnack() => showAppSnack;