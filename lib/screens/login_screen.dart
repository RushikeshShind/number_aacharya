import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isInitialScreen = true;
  bool _isPasswordVisible = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final String correctUsername = "8010524625";
  final String correctPassword = "Super@1234";

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_usernameController.text == correctUsername &&
        _passwordController.text == correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      ); 
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Title
              Text(
                "Number",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4BAF8D),
                ),
              ),
              Text(
                "Aacharya",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4BAF8D),
                ),
              ),

              SizedBox(height: screenHeight * 0.005),

              // Subtitle
              const Text(
                "Unlock your destiny through\nnumerology",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Astrology Image
              Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/login.png',
                  width: screenWidth * 0.75,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Conditional UI
              _isInitialScreen ? _buildInitialButtons(screenHeight) : _buildLoginForm(screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialButtons(double screenHeight) {
    return Column(
      children: [
        _buildRoundedButton(
          text: "Customer Login",
          onTap: () {
            setState(() {
              _isInitialScreen = false;
            });
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildRoundedButton(
          text: "Channel Partner Login",
          onTap: () {
            setState(() {
              _isInitialScreen = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLoginForm(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot password?",
                style: TextStyle(
                  color: Color(0xFF4BAF8D),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildRoundedButton(
            text: "Submit",
            onTap: _login,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: const Text(
              "Don't have an account? Sign Up",
              style: TextStyle(
                color: Color(0xFF4BAF8D),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDDF6D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        filled: true,
        fillColor: const Color(0xFFDDF6D2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
