import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupSuccessScreen extends StatelessWidget {
  final String mobileNumber;
  final String password;

  const SignupSuccessScreen({
    super.key,
    required this.mobileNumber,
    required this.password,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E7D32),
              const Color(0xFF4CAF50),
              const Color(0xFF81C784),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success Icon with Animation Effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 32),

              // Success Message
              const Text(
                "Signup Successful!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Your account has been created successfully.\nHere are your login credentials:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Credentials Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Username
                      _buildCredentialItem(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        label: "Username",
                        value: mobileNumber,
                        isFirst: true,
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),

                      // Password
                      _buildCredentialItem(
                        context: context,
                        icon: Icons.lock_outline_rounded,
                        label: "Password",
                        value: password,
                        isLast: true,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFBC02D),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFF57F17),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Please save your credentials securely",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Go to Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login-form",
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black38,
                    ),
                    child: const Text(
                      "Go to Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPassword ? '•' * value.length : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Copy Button
          InkWell(
            onTap: () => _copyToClipboard(context, value, label),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.copy_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}