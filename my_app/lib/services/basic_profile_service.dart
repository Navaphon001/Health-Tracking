import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../shared/snack_fn.dart';

class BasicProfileService {
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

  // Create basic profile
  static Future<Map<String, dynamic>?> createBasicProfile({
    required String id,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
    String? phoneNumber,
    String? address,
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
        'full_name': fullName,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0], // Send as YYYY-MM-DD
        'gender': gender,
        'profile_image_url': profileImageUrl,
        'phone_number': phoneNumber,
        'address': address,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      print('Sending request to: $baseUrl/basic_profile');
      print('Request body: ${jsonEncode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/basic_profile'),
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
        snackFn?.call('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว');
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

  // Update basic profile
  static Future<Map<String, dynamic>?> updateBasicProfile({
    required String profileId,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
    String? phoneNumber,
    String? address,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final body = {
        'id': profileId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'gender': gender,
        'profile_image_url': profileImageUrl,
        'phone_number': phoneNumber,
        'address': address,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      final response = await http.put(
        Uri.parse('$baseUrl/basic_profile/$profileId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        snackFn?.call('อัปเดตข้อมูลโปรไฟล์เรียบร้อยแล้ว');
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

  // Get basic profiles for current user
  static Future<List<Map<String, dynamic>>?> getBasicProfiles({
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/basic_profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['detail'] ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล';
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

  // Get specific basic profile by ID
  static Future<Map<String, dynamic>?> getBasicProfile({
    required String profileId,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/basic_profile/$profileId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['detail'] ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล';
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

  // Delete basic profile
  static Future<bool> deleteBasicProfile({
    required String profileId,
    SnackFn? snackFn,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        snackFn?.call('กรุณาเข้าสู่ระบบก่อน', isError: true);
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/basic_profile/$profileId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        snackFn?.call('ลบข้อมูลโปรไฟล์เรียบร้อยแล้ว');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['detail'] ?? 'เกิดข้อผิดพลาดในการลบข้อมูล';
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