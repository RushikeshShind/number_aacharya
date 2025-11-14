import 'package:flutter/material.dart';
import 'home_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  Future<void>? _popupFuture;

  @override
  void initState() {
    super.initState();
    // After 3 seconds show success popup
    _popupFuture = Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _showSuccessPopup();
    });
  }

  void _showSuccessPopup() {
    if (!mounted) return; // Prevent accessing context if unmounted
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot close manually
      builder: (context) {
        return Center(
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      size: 80, color: Colors.green),
                  const SizedBox(height: 15),
                  const Text(
                    "Your Report is Ready!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Close popup after 2 seconds, but don't navigate to HomeScreen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop(); // Close popup
    });
  }

  @override
  void dispose() {
    // Cancel any pending futures (optional, since Future.delayed isn't cancelable directly)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/analyzing.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Analyzing...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.green[700],
            ),
            const SizedBox(height: 20),
            const Text(
              "Please wait while we generate your numerology report.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}