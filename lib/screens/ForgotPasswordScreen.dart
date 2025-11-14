import 'package:flutter/material.dart';
import 'package:number_aacharya/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _systemUserId;
  String? _serverOtp;
  bool _isLoading = false;
  int _currentStep = 1;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final username = _usernameController.text.trim();

    if (username.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(username)) {
      _showErrorSnackBar("Enter a valid 10-digit mobile number");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.forgotPassword(username);

      if (response['data'] != null &&
          response['data'].isNotEmpty &&
          response['data'][0]['system_user_id'] != null) {
        final user = response['data'][0];
        final systemUserId = user['system_user_id'] as int?;
        final otp = user['otp']?.toString();
        final message = user['message']?.toString() ?? '';

        if (systemUserId != null &&
            otp != null &&
            message.contains("OTP sent")) {
          setState(() {
            _systemUserId = systemUserId.toString();
            _serverOtp = otp;
            _currentStep = 2;
          });
          _showSuccessSnackBar(message);
        } else {
          _showErrorSnackBar(
            message.isNotEmpty ? message : "Invalid username. Please enter a valid username.",
          );
        }
      } else {
        _showErrorSnackBar("Invalid username. Please enter a valid username.");
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showErrorSnackBar("Please enter a valid 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (otp == _serverOtp) {
        setState(() => _currentStep = 3);
        _showSuccessSnackBar("OTP verified successfully");
      } else {
        _showErrorSnackBar("Invalid OTP");
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, bool> _validatePassword(String password) {
    return {
      "At least 6 characters": password.length >= 6,
      "1 uppercase letter": RegExp(r'[A-Z]').hasMatch(password),
      "1 lowercase letter": RegExp(r'[a-z]').hasMatch(password),
      "1 number": RegExp(r'[0-9]').hasMatch(password),
      "1 special char": RegExp(r'[!@#\$&*~]').hasMatch(password),
    };
  }

  Future<void> _resetPassword() async {
    final otp = _otpControllers.map((c) => c.text).join();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showErrorSnackBar("Please enter a valid 6-digit OTP");
      return;
    }

    final rules = _validatePassword(newPassword);
    if (rules.containsValue(false)) {
      _showErrorSnackBar("Password does not meet requirements");
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.resetPassword(
        _systemUserId!,
        otp,
        newPassword,
      );

      if (response['success'] == true) {
        _showSuccessSnackBar("Password reset successful");
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(response['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpBox(TextEditingController controller, int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 2),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (val.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        onTap: () {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
      ),
    );
  }

  Widget _buildPasswordRules(String password) {
    final rules = _validatePassword(password);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password Requirements:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          ...rules.entries.map((rule) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    rule.value ? Icons.check_circle : Icons.cancel,
                    color: rule.value ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rule.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: rule.value ? const Color(0xFF1B5E20) : const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {"icon": Icons.phone_outlined, "label": "Phone"},
      {"icon": Icons.message_outlined, "label": "OTP"},
      {"icon": Icons.lock_outline_rounded, "label": "Password"},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final stepNum = index + 1;
        final isActive = _currentStep == stepNum;
        final isCompleted = _currentStep > stepNum;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                      ),
                    ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF2E7D32)
                          : isActive
                              ? Colors.white
                              : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF2E7D32)
                            : isCompleted
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : steps[index]["icon"] as IconData,
                      color: isCompleted
                          ? Colors.white
                          : isActive
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                steps[index]["label"] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive || isCompleted
                      ? const Color(0xFF1B5E20)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1B5E20)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          suffixIcon: suffixIcon,
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newPassword = _newPasswordController.text;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF1F8F4),
              Colors.white,
              const Color(0xFFFFF3F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2E7D32)),
                        onPressed: () {
                          if (_currentStep > 1) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Step Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildStepIndicator(),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Phone
                      if (_currentStep == 1) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.phone_android_rounded, size: 60, color: const Color(0xFF2E7D32)),
                              const SizedBox(height: 16),
                              const Text(
                                "Verify Your Phone",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter your registered mobile number to receive OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: _usernameController,
                          label: "Mobile Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                      ],

                      // Step 2: OTP
                      if (_currentStep == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.message_outlined, size: 60, color: const Color(0xFF2E7D32)),
                              const SizedBox(height: 16),
                              const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter the 6-digit OTP sent to\n${_usernameController.text}",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _otpControllers
                              .asMap()
                              .entries
                              .map((entry) => _buildOtpBox(entry.value, entry.key))
                              .toList(),
                        ),
                      ],

                      // Step 3: Password
                      if (_currentStep == 3) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.lock_reset_rounded, size: 60, color: const Color(0xFF2E7D32)),
                              const SizedBox(height: 16),
                              const Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Create a new secure password for your account",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: _newPasswordController,
                          label: "New Password",
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureNewPassword,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF2E7D32),
                            ),
                            onPressed: () =>
                                setState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordRules(newPassword),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF2E7D32),
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _currentStep == 1
                            ? _sendOtp
                            : _currentStep == 2
                                ? _verifyOtp
                                : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep == 1
                                ? "Send OTP"
                                : _currentStep == 2
                                    ? "Verify OTP"
                                    : "Reset Password",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}