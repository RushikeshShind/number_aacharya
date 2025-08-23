import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/login_form_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/login.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20), // ✅ equal padding
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.08),

                    // Title
                    Text(
                      "Number",
                      style: TextStyle(
                        fontFamily: "Arial",
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4BAF8D),
                      ),
                    ),
                    Text(
                      "Aacharya",
                      style: TextStyle(
                        fontFamily: "Arial",
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4BAF8D),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    const Text(
                      "Unlock your destiny through\nnumerology",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.2),

                    // Buttons
                    _buildRoundedButton(
                      context: context,
                      text: "Customer Login",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginFormScreen()),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    _buildRoundedButton(
                      context: context,
                      text: "Channel Partner Login",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginFormScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity, // ✅ take full width minus padding
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDDF6D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: "Arial",
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
