import 'package:flutter/material.dart';

/// ใช้แสดง SnackBar ได้จากทุกที่ โดยไม่ผูกกับ context ของหน้าหนึ่งหน้าใด
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();