import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://number.kureone.com/';
  static const storage = FlutterSecureStorage();

  // 🔹 Common request handler
  static Future<Map<String, dynamic>> _postRequest(
      String endpoint, Map<String, String> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(uri, body: data);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'API call failed with status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 🔹 Save system_user_id securely
  static Future<void> _saveSystemUserId(String? id) async {
    if (id != null && id.isNotEmpty) {
      await storage.write(key: 'system_user_id', value: id);
      print("✅ Saved system_user_id: $id");
    }
  }

  // 🔹 Read system_user_id
  static Future<String?> getStoredSystemUserId() async {
    final id = await storage.read(key: 'system_user_id');
    print("📌 Retrieved system_user_id: $id");
    return id;
  }

  // 🔹 Login API
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await _postRequest('LoginApi.htm', {
      'username': username,
      'password': password,
    });

    if (response.containsKey('data') &&
        response['data'] is List &&
        response['data'].isNotEmpty) {
      final user = response['data'][0];
      final systemUserId = user['system_user_id']?.toString();
      await _saveSystemUserId(systemUserId);
    }

    return response;
  }

  // 🔹 Change Password API
  static Future<Map<String, dynamic>> changePassword(
      String systemUserId, String oldPassword, String newPassword) async {
    return _postRequest('ChangePasswordApi.htm', {
      'system_user_id': systemUserId,
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  // 🔹 Forgot Password API
  static Future<Map<String, dynamic>> forgotPassword(String username) async {
    return _postRequest('ForgotPasswordApi.htm', {
      'username': username,
    });
  }

  // 🔹 Reset Password API
  static Future<Map<String, dynamic>> resetPassword(
      String systemUserId, String otp, String newPassword) async {
    return _postRequest('ResetPasswordApi.htm', {
      'system_user_id': systemUserId,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  // 🔹 Get Registration OTP API
  static Future<Map<String, dynamic>> getRegistrationOtp(
      String mobileNo) async {
    return _postRequest('GetRegistrationOtpApi.htm', {
      'mobile_no': mobileNo,
    });
  }

  // 🔹 Registration API
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String mobileNo,
    required String emailId,
    required String userType, // 'Customer' or 'Channel Partner'
    required String password,
  }) async {
    final response = await _postRequest('RegistrationApi.htm', {
      'full_name': fullName,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'user_type': userType,
      'password': password,
    });

    if (response.containsKey('data') &&
        response['data'] is List &&
        response['data'].isNotEmpty) {
      final user = response['data'][0];
      final systemUserId = user['system_user_id']?.toString();
      await _saveSystemUserId(systemUserId);
    }

    return response;
  }

  // 🔹 Get Inquiries API
  static Future<Map<String, dynamic>> getInquiries(
      [String? systemUserId]) async {
    // If not passed, try to read from storage
    systemUserId ??= await getStoredSystemUserId();

    if (systemUserId == null || systemUserId.isEmpty) {
      throw Exception("⚠️ No system_user_id found. Please login again.");
    }

    return _postRequest('GetInquiriesApi.htm', {
      'system_user_id': systemUserId,
    });
  }
}
