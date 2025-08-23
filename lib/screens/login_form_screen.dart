import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_aacharya/screens/home_screen.dart';
import 'package:number_aacharya/screens/signup_screen.dart';
import 'package:number_aacharya/services/api_service.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  _LoginFormScreenState createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials(String username, String password, String systemUserId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setString('system_user_id', systemUserId);
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      print('Login response: $response');

      if (response.containsKey('data') && response['data'] is List && response['data'].isNotEmpty) {
        final message = response['data'][0]['message']?.toString() ?? '';
        if (message.toLowerCase().contains('successful')) {
          final systemUserId = response['data'][0]['system_user_id'].toString();

          // Save creds
          await _saveCredentials(
            _usernameController.text,
            _passwordController.text,
            systemUserId,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.isNotEmpty ? message : 'Invalid username or password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response from server')),
        );
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internet connection issue. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/login.png',
                fit: BoxFit.contain,
                width: screenWidth * 0.9,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.08),

                    Text(
                      "Number",
                      style: TextStyle(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4BAF8D),
                      ),
                    ),
                    Text(
                      "Aacharya",
                      style: TextStyle(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4BAF8D),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    const Text(
                      "Unlock your destiny through\nnumerology",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                    ),

                    SizedBox(height: screenHeight * 0.12),

                    _buildInputField(
                      controller: _usernameController,
                      hint: "Enter your username",
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildInputField(
                      controller: _passwordController,
                      hint: "Enter your password",
                      isPassword: true,
                    ),

                    const SizedBox(height: 12),

                    _buildRoundedButton(text: "Submit", onTap: _login),

                    SizedBox(height: screenHeight * 0.025),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Color(0xFF4BAF8D), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF4BAF8D)),
            ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({required String text, required VoidCallback onTap}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.8,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDDF6D2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 3,
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF6D2),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
        ),
      ),
    );
  }
}
