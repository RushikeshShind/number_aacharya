import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "WELCOME TO",
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "NUMBER\nAACHARYA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  color: Color(0xFF7DC19D),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                  height: 0.8,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('assets/images/splash.png', width: 330),
              const SizedBox(height: 60),
              SizedBox(
                width: 226,
                height: 66,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/intro');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDDF6D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
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