import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/login_form_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_selection_screen.dart'; 
import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'screens/search_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginSelectionScreen(), 
        '/login-form': (context) => const LoginFormScreen(), 
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/list': (context) => const ListScreen(),
        '/search': (context) => const SearchScreen(),
        '/credits': (context) => const CreditsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}