import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_aacharya/screens/SignupSuccessScreen.dart';
import 'package:number_aacharya/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 1;
  bool _agreeTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _userType;

  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  bool _isLoadingCountries = true;

  final _otpControllers = List.generate(6, (_) => TextEditingController());

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _serverOtp;
  int _maxMobileLength = 10;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final response = await ApiService.getCountryMaster();
      if (response['data'] != null && response['data'] is List) {
        setState(() {
          _countries = List<Map<String, dynamic>>.from(response['data']);
          _selectedCountry = _countries.firstWhere(
            (country) => country['country_id'] == 1,
            orElse: () => _countries.isNotEmpty ? _countries[0] : {},
          );
          _updateMaxMobileLength();
          _isLoadingCountries = false;
        });
      } else {
        setState(() => _isLoadingCountries = false);
        _showErrorSnackBar('Failed to load countries');
      }
    } catch (e) {
      setState(() => _isLoadingCountries = false);
      _showErrorSnackBar('Error loading countries: $e');
    }
  }

  void _updateMaxMobileLength() {
    if (_selectedCountry == null) {
      _maxMobileLength = 10;
      return;
    }
    _maxMobileLength = (_selectedCountry!['country_code'] == '+91') ? 10 : 20;
  }

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isValidMobile(String mobile) {
    if (_selectedCountry == null) return false;
    final countryCode = _selectedCountry!['country_code'] ?? '';
    final RegExp digitOnly = RegExp(r'^[0-9]+$');
    if (!digitOnly.hasMatch(mobile)) return false;
    if (countryCode == '+91') {
      return mobile.length == 10;
    } else {
      return mobile.length >= 8;
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

  bool _validateStep1() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return false;
    }
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return false;
    }
    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return false;
    }
    if (_selectedCountry == null) {
      _showErrorSnackBar('Please select a country');
      return false;
    }
    if (mobile.isEmpty) {
      _showErrorSnackBar('Please enter your mobile number');
      return false;
    }
    if (!_isValidMobile(mobile)) {
      _showErrorSnackBar(_selectedCountry!['country_code'] == '+91'
          ? "Please enter a valid 10-digit mobile number"
          : "Please enter a valid mobile number (min 8 digits)");
      return false;
    }
    if (_userType == null) {
      _showErrorSnackBar('Please select user type');
      return false;
    }
    if (!_agreeTerms) {
      _showErrorSnackBar('Please agree to terms and conditions');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showErrorSnackBar("Please enter complete 6-digit OTP");
      return false;
    }
    if (_serverOtp != null && otp != _serverOtp) {
      _showErrorSnackBar("Invalid OTP");
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      _showErrorSnackBar('Please enter password');
      return false;
    }
    final rules = _validatePassword(password);
    if (rules.containsValue(false)) {
      _showErrorSnackBar("Password does not meet requirements");
      return false;
    }
    if (confirmPassword.isEmpty) {
      _showErrorSnackBar('Please confirm your password');
      return false;
    }
    if (password != confirmPassword) {
      _showErrorSnackBar("Passwords do not match");
      return false;
    }
    return true;
  }

  Future<void> _nextStep() async {
    if (_isLoading) return;

    try {
      if (_step == 1) {
        if (!_validateStep1()) return;
        setState(() => _isLoading = true);
        final mobileNumber = _mobileController.text.trim();
        final response = await ApiService.getRegistrationOtp(mobileNumber);

        if (response['data'] != null && response['data'].isNotEmpty) {
          final data = response['data'][0];
          final message = data['message'] ?? 'OTP sent successfully';
          _serverOtp = data['otp'];
          setState(() => _step = 2);
          _showSuccessSnackBar(message);
        } else {
          _showErrorSnackBar("Failed to send OTP");
        }
      } else if (_step == 2) {
        if (!_validateStep2()) return;
        setState(() => _step = 3);
      } else if (_step == 3) {
        if (!_validateStep3()) return;
        setState(() => _isLoading = true);
        final mobileNumber = _mobileController.text.trim();
        final response = await ApiService.register(
          fullName: _nameController.text,
          mobileNo: mobileNumber,
          emailId: _emailController.text,
          userType: _userType!,
          password: _passwordController.text,
        );

        if (response['data'] != null && response['data'].isNotEmpty) {
          final message = response['data'][0]['message'] ?? "Registration successful";
          _showSuccessSnackBar(message);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignupSuccessScreen(
                mobileNumber: mobileNumber,
                password: _passwordController.text,
              ),
            ),
          );
        } else {
          _showErrorSnackBar(response['message'] ?? 'Registration failed');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscureText = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
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
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        obscureText: obscureText,
        onTap: onTap,
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

  Widget _buildStep1() {
    return Column(
      children: [
        _buildInputField(
          controller: _nameController,
          label: "Full Name",
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _emailController,
          label: "Email ID",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      width: 110,
      height: 56,
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
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.2),
        ),
      ),
      child: _isLoadingCountries
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                border: InputBorder.none,
              ),
              value: _selectedCountry,
              isExpanded: true,
              items: _countries.map((country) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: country,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.5),
                          child: Image.network(
                            country['flag_file'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.flag_outlined,
                                size: 12,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          country['country_code'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCountry = val;
                  _updateMaxMobileLength();
                });
              },
            ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Container(
        height: 56,
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
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.2),
          ),
        ),
        child: TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: _maxMobileLength,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1B5E20)),
          decoration: InputDecoration(
            labelText: "Mobile Number",
            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  ],
),
        const SizedBox(height: 16),
        Container(
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
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "User Type",
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              prefixIcon: const Icon(Icons.people_outline_rounded, color: Color(0xFF2E7D32), size: 22),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
            ),
            value: _userType,
            items: const [
              DropdownMenuItem(value: "Customer", child: Text("Customer")),
              DropdownMenuItem(value: "Channel Partner", child: Text("Channel Partner")),
            ],
            onChanged: (val) => setState(() => _userType = val),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _agreeTerms,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              ),
              const Expanded(
                child: Text(
                  "I agree to the Terms and Conditions",
                  style: TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
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

  Widget _buildStep2() {
    return Column(
      children: [
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
                "Verify Your Mobile Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter the 6-digit OTP sent to\n${_selectedCountry?['country_code'] ?? ''} ${_mobileController.text}",
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
    );
  }

  Widget _buildStep3() {
    final password = _passwordController.text;
    return Column(
      children: [
        _buildInputField(
          controller: _passwordController,
          label: "New Password",
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          onTap: () => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: const Color(0xFF2E7D32),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildPasswordRules(password),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: const Color(0xFF2E7D32),
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                          if (_step > 1) {
                            setState(() => _step -= 1);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Step $_step of 3",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _step / 3,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _step == 1 ? "Enter Your Details" : _step == 2 ? "Verify OTP" : "Set Your Password",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _step == 1 ? _buildStep1() : _step == 2 ? _buildStep2() : _buildStep3(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                _step == 3 ? "Submit" : "Continue",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/login-form"),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(fontSize: width * 0.04, color: Colors.grey.shade700),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}