import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://number.kureone.com/';
  static const storage = FlutterSecureStorage();

  // ================================
  // 🔹 Common Handlers
  // ================================

  // Common GET request handler
  static Future<Map<String, dynamic>> _getRequest(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(uri);
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

  // Common POST request handler
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

  // ================================
  // 🔹 Secure Storage Helpers
  // ================================

  // Save system_user_id securely
  static Future<void> _saveSystemUserId(String? id) async {
    if (id != null && id.isNotEmpty) {
      await storage.write(key: 'system_user_id', value: id);
      print("✅ Saved system_user_id: $id");
    }
  }

  // Save full user data securely (with country_code fallback)
  static Future<void> _saveUserData(Map<String, dynamic> user) async {
    if (!user.containsKey("country_code") || user["country_code"] == null) {
      user["country_code"] = "+91"; // default
    }
    await storage.write(key: "user", value: jsonEncode(user));
    print("✅ Saved user data with country_code: ${user["country_code"]}");
  }

  // Read system_user_id
  static Future<String?> getStoredSystemUserId() async {
    if (_isLoggingOut) return null;
    final id = await storage.read(key: 'system_user_id');
    return id;
  }

  // Read stored user
  static Future<Map<String, dynamic>?> getStoredUser() async {
    final userStr = await storage.read(key: "user");
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  // ================================
  // 🔹 Auth & User APIs
  // ================================

  static Future<Map<String, dynamic>> forgotPassword(String username) async {
    final response =
        await _getRequest('ForgotPasswordApi.htm?username=$username');
    if (response.containsKey('data') &&
        response['data'] is List &&
        response['data'].isNotEmpty) {
      final user = response['data'][0];
      final systemUserId = user['system_user_id']?.toString();
      await _saveSystemUserId(systemUserId);
    }
    return response;
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String systemUserId, String otp) async {
    final response = await _getRequest(
        'VerifyOtpApi.htm?system_user_id=$systemUserId&otp=$otp');
    return {
      'success': response['data'] != null &&
          response['data'].isNotEmpty &&
          response['data'][0]['message']?.toString().contains('successfully') ==
              true,
      'message': response['data'] != null && response['data'].isNotEmpty
          ? response['data'][0]['message']?.toString() ?? 'Invalid OTP'
          : 'Invalid OTP response',
    };
  }

  static Future<Map<String, dynamic>> resetPassword(
      String systemUserId, String otp, String newPassword) async {
    final response = await _getRequest(
        'ResetPasswordApi.htm?system_user_id=$systemUserId&otp=$otp&new_password=$newPassword');
    return {
      'success': response['data'] != null &&
          response['data'].isNotEmpty &&
          response['data'][0]['message']?.toString().contains('Successfully') ==
              true,
      'message': response['data'] != null && response['data'].isNotEmpty
          ? response['data'][0]['message']?.toString() ??
              'Failed to reset password'
          : 'Unexpected response format',
    };
  }

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
      await _saveUserData(user);
    }

    return response;
  }

  static Future<Map<String, dynamic>> changePassword(
      String systemUserId, String oldPassword, String newPassword) async {
    return _postRequest('ChangePasswordApi.htm', {
      'system_user_id': systemUserId,
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  static Future<Map<String, dynamic>> getRegistrationOtp(String mobileNo) async {
    return _postRequest('GetRegistrationOtpApi.htm', {
      'mobile_no': mobileNo,
    });
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String mobileNo,
    required String emailId,
    required String userType, // 'Customer' or 'Channel Partner'
    required String password,
    String countryCode = "+91",
  }) async {
    final response = await _postRequest('RegistrationApi.htm', {
      'full_name': fullName,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'user_type': userType,
      'password': password,
      'country_code': countryCode,
    });

    if (response.containsKey('data') &&
        response['data'] is List &&
        response['data'].isNotEmpty) {
      final user = response['data'][0];
      final systemUserId = user['system_user_id']?.toString();
      await _saveSystemUserId(systemUserId);
      await _saveUserData(user);
    }

    return response;
  }

  // ================================
  // 🔹 Inquiry APIs
  // ================================

  static Future<Map<String, dynamic>> getInquiries(
      [String? systemUserId]) async {
    systemUserId ??= await getStoredSystemUserId();

    if (systemUserId == null || systemUserId.isEmpty) {
      throw Exception("⚠️ No system_user_id found. Please login again.");
    }

    return _postRequest('GetInquiriesApi.htm', {
      'system_user_id': systemUserId,
    });
  }

  static Future<Map<String, dynamic>> getLatestInquiries(
      [String? systemUserId]) async {
    try {
      final response = await getInquiries(systemUserId);

      if (response.containsKey('data') && response['data'] is List) {
        List<Map<String, dynamic>> allInquiries =
            List<Map<String, dynamic>>.from(response['data']);

        // Sort by inquiry_id (higher = newer)
        allInquiries.sort((a, b) {
          final aId = int.tryParse(a['inquiry_id']?.toString() ?? '0') ?? 0;
          final bId = int.tryParse(b['inquiry_id']?.toString() ?? '0') ?? 0;
          return bId.compareTo(aId);
        });

        return {
          'data': allInquiries.take(5).toList(),
          'success': true,
        };
      }

      return response;
    } catch (e) {
      throw Exception('Failed to get latest inquiries: $e');
    }
  }

  // UPDATED: Add Inquiry API with country_code
static Future<Map<String, dynamic>> addInquiry({
  required String systemUserId,
  required String firstName,
  required String lastName,
  required String dob, // format: DD/MM/YYYY
  required String mobileNo,
  String countryCode = "",
}) async {
  final url = Uri.parse(
    '${baseUrl}AddInquiryApi.htm'
    '?system_user_id=$systemUserId'
    '&first_name=$firstName'
    '&last_name=$lastName'
    '&date_of_birth=$dob'
    '&phone_number=$mobileNo'
    '&country_code=$countryCode'
    '&total_amount=0.0'
    '&credits_id=0',
  );

  print("➡️ AddInquiry API URL: $url");

  try {
    final response = await http.get(url);
    print("✅ Status: ${response.statusCode}");
    print("✅ Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      
      // Return the full response including the data array
      return decodedResponse;
    } else {
      return {"success": false, "message": "Server error, try again later."};
    }
  } catch (e) {
    return {"success": false, "message": "Network error: $e"};
  }
}// ================================
  // 🔹 Credits & Transactions
  // ================================

  static Future<Map<String, dynamic>> getUserCredits() async {
    final systemUserId = await getStoredSystemUserId();
    if (systemUserId == null) {
      return {"success": false, "message": "User not logged in"};
    }

    final url =
        Uri.parse('${baseUrl}GetUserCreditsApi.htm?system_user_id=$systemUserId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": "Failed to fetch user credits"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getCreditsMaster() async {
    final url = Uri.parse('${baseUrl}GetCreditsMasterApi.htm');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": "Failed to fetch credit packs"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> addUserCredits({
    required String creditsId,
    required String totalAmount,
  }) async {
    final systemUserId = await getStoredSystemUserId();
    if (systemUserId == null) {
      return {"success": false, "message": "User not logged in"};
    }

    final url = Uri.parse(
        '${baseUrl}AddUserCreditsApi.htm?system_user_id=$systemUserId&credits_id=$creditsId&total_amount=$totalAmount');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": "Failed to purchase credits"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getUserTransactionHistory() async {
    final systemUserId = await getStoredSystemUserId();
    if (systemUserId == null) {
      return {"success": false, "message": "User not logged in"};
    }

    final url = Uri.parse(
        '${baseUrl}GetUserTransactionHistoryApi.htm?system_user_id=$systemUserId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed to fetch transaction history"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // ================================
  // 🔹 Logout & Helpers
  // ================================

  static bool _isLoggingOut = false;

  static Future<void> clearStoredData() async {
    _isLoggingOut = true;
    await storage.deleteAll();
    print("✅ Cleared all secure storage data");
    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  // Country Master API
  static Future<Map<String, dynamic>> getCountryMaster() async {
    final url = Uri.parse('${baseUrl}GetCountryMasterApi.htm');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": "Failed to fetch countries"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
