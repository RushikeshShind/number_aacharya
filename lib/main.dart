import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/credits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/list_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();

    bool isFirstTime = prefs.getBool("is_first_time") ?? true;
    String? user = prefs.getString("user");
    String? systemUserId = await storage.read(key: 'system_user_id');

    if (isFirstTime) {
      await prefs.setBool("is_first_time", false);
      return const WelcomeScreen();
    } else if (user != null && systemUserId != null) {
      return const HomeScreen();
    } else {
      await prefs.clear();
      await storage.deleteAll();
      return const LoginFormScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          
          return SplashScreen(nextScreen: snapshot.data!);
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/intro': (context) => const IntroScreen(),
        '/login-form': (context) => const LoginFormScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/list': (context) => const ListScreen(),
        '/search': (context) => const SearchScreen(prefilledData: {}),
        '/credits': (context) => const CreditsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}