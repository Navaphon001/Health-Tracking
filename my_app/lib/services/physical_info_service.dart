import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../shared/snack_fn.dart';

class PhysicalInfoService {
  // For Android Emulator, use 10.0.2.2 instead of 127.0.0.1
  // For physical device, use your computer's IP address (e.g., 192.168.1.xxx)
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const _storage = FlutterSecureStorage();

  // Get token from secure storage
  static Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // Create physical info
  static Future<Map<String, dynamic>?> createPhysicalInfo({
    required String id,
    double? weight,
    double? height,
    String? activityLevel,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final body = {
        'id': id,
        'weight': weight,
        'height': height,
        'activity_level': activityLevel,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      print('Sending request to: $baseUrl/physical_info');
      print('Request body: ${jsonEncode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/physical_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        snackFn?.call('บันทึกข้อมูลสุขภาพเรียบร้อยแล้ว');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'เกิดข้อผิดพลาดในการบันทึกข้อมูล';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            final detail = errorData['detail'];
            if (detail is String) {
              errorMessage = detail;
            } else if (detail is List) {
              // Handle pydantic validation errors
              List<String> errors = [];
              for (var error in detail) {
                if (error is Map<String, dynamic> && error.containsKey('msg')) {
                  errors.add(error['msg'].toString());
                }
              }
              errorMessage = errors.isNotEmpty ? errors.join(', ') : 'Validation error';
            }
          }
        } else if (errorData is String) {
          errorMessage = errorData;
        }
        
        snackFn?.call('ข้อผิดพลาด: $errorMessage', isError: true);
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        snackFn?.call('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
      } else {
        snackFn?.call('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      }
      return null;
    }
  }

  // Update physical info
  static Future<Map<String, dynamic>?> updatePhysicalInfo({
    required String infoId,
    double? weight,
    double? height,
    String? activityLevel,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final body = {
        'id': infoId,
        'weight': weight,
        'height': height,
        'activity_level': activityLevel,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      final response = await http.put(
        Uri.parse('$baseUrl/physical_info/$infoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        snackFn?.call('อัปเดตข้อมูลสุขภาพเรียบร้อยแล้ว');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'เกิดข้อผิดพลาดในการอัปเดตข้อมูล';
        
        if (errorData is Map<String, dynamic> && errorData.containsKey('detail')) {
          final detail = errorData['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            List<String> errors = [];
            for (var error in detail) {
              if (error is Map<String, dynamic> && error.containsKey('msg')) {
                errors.add(error['msg'].toString());
              }
            }
            errorMessage = errors.isNotEmpty ? errors.join(', ') : 'Validation error';
          }
        }
        
        snackFn?.call('ข้อผิดพลาด: $errorMessage', isError: true);
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        snackFn?.call('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
      } else {
        snackFn?.call('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      }
      return null;
    }
  }

  // Get physical info for current user
  static Future<List<Map<String, dynamic>>?> getPhysicalInfos({
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/physical_info'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'เกิดข้อผิดพลาดในการดึงข้อมูล';
        
        if (errorData is Map<String, dynamic> && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        }
        
        snackFn?.call(errorMessage, isError: true);
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        snackFn?.call('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
      } else {
        snackFn?.call('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      }
      return null;
    }
  }

  // Get specific physical info by ID
  static Future<Map<String, dynamic>?> getPhysicalInfo({
    required String infoId,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/physical_info/$infoId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'เกิดข้อผิดพลาดในการดึงข้อมูล';
        
        if (errorData is Map<String, dynamic> && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        }
        
        snackFn?.call(errorMessage, isError: true);
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        snackFn?.call('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
      } else {
        snackFn?.call('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      }
      return null;
    }
  }

  // Delete physical info
  static Future<bool> deletePhysicalInfo({
    required String infoId,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/physical_info/$infoId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        snackFn?.call('ลบข้อมูลสุขภาพเรียบร้อยแล้ว');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'เกิดข้อผิดพลาดในการลบข้อมูล';
        
        if (errorData is Map<String, dynamic> && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        }
        
        snackFn?.call(errorMessage, isError: true);
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        snackFn?.call('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
      } else {
        snackFn?.call('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
      }
      return false;
    }
  }
}