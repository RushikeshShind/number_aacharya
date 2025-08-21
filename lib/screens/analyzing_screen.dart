import 'package:flutter/material.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

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