import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_aacharya/screens/home_screen.dart';
import 'package:number_aacharya/screens/signup_screen.dart';
import 'package:number_aacharya/screens/ForgotPasswordScreen.dart';
import 'package:number_aacharya/services/api_service.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  _LoginFormScreenState createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser(Map<String, dynamic> user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    await prefs.setString('system_user_id', '${user['system_user_id']}');
    await prefs.setString('username', user['mobile_no']);
    await prefs.setString('password', password);
  }

  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      _showErrorSnackBar('Please enter username and password');
      return false;
    } else if (username.isEmpty) {
      _showErrorSnackBar('Please enter username');
      return false;
    } else if (password.isEmpty) {
      _showErrorSnackBar('Please enter password');
      return false;
    }
    return true;
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

  Future<void> _login() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.containsKey('data') &&
          response['data'] is List &&
          response['data'].isNotEmpty) {
        final user = response['data'][0];
        final message = user['message']?.toString() ?? '';

        if (message.toLowerCase().contains('successful')) {
          await _saveUser(user, _passwordController.text.trim());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showErrorSnackBar(
            message.isNotEmpty ? message : 'Invalid username or password',
          );
        }
      } else {
        _showErrorSnackBar('Invalid response from server');
      }
    } catch (e) {
      _showErrorSnackBar('Internet connection issue. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Arial',
          color: Color(0xFF1B5E20),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            fontFamily: 'Arial',
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 22,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: const Color(0xFF2E7D32),
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
        ),
      ),
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
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: height * 0.06),
                
                // Logo with decorative container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/report.png',
                    width: width * 0.35,
                    height: width * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
                
                SizedBox(height: height * 0.04),
                
                // App Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ).createShader(bounds),
                  child: Text(
                    "Number Aacharya",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Arial",
                      fontSize: width * 0.085,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                SizedBox(height: height * 0.015),
                
                // Subtitle
                Text(
                  "Unlock your destiny through numerology",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Arial",
                    fontSize: width * 0.04,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                SizedBox(height: height * 0.05),
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please login to continue",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: width * 0.038,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // Username Field
                      _buildInputField(
                        controller: _usernameController,
                        hint: "Enter your username",
                        icon: Icons.person_outline_rounded,
                      ),
                      
                      const SizedBox(height: 18),
                      
                      // Password Field
                      _buildInputField(
                        controller: _passwordController,
                        hint: "Enter your password",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              color: const Color(0xFFD32F2F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: height * 0.03),
                
                // Sign Up Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        fontFamily: "Arial",
                        fontSize: width * 0.04,
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontFamily: "Arial",
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}