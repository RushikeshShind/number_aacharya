import 'package:flutter/material.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 1;
  bool _agreeTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _userType;

  final _otpController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$');
    return regex.hasMatch(password);
  }

  void _nextStep() {
    if (_step == 1) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _mobileController.text.length != 10 ||
          _userType == null ||
          !_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields and agree to terms")),
        );
        return;
      }
    }
    if (_step == 2) {
      if (_otpController.text.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid 6-digit OTP")),
        );
        return;
      }
    }
    if (_step == 3) {
      if (!_validatePassword(_passwordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password must have 1 uppercase, 1 lowercase, 1 number, 1 special char, and be at least 6 chars long")),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }
    setState(() {
      _step++;
    });
  }

  Widget _buildStep1() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "Full Name",
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: "Email ID",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: "Mobile Number",
            prefixIcon: Icon(Icons.phone),
            counterText: "",
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "User Type",
            prefixIcon: Icon(Icons.people),
          ),
          value: _userType,
          items: const [
            DropdownMenuItem(value: "Customer", child: Text("Customer")),
            DropdownMenuItem(value: "Channel Partner", child: Text("Channel Partner")),
          ],
          onChanged: (val) {
            setState(() {
              _userType = val;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _agreeTerms,
              onChanged: (val) {
                setState(() {
                  _agreeTerms = val ?? false;
                });
              },
            ),
            const Expanded(
              child: Text("I agree to the Terms and Conditions"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: const InputDecoration(
        labelText: "Enter OTP",
        prefixIcon: Icon(Icons.security),
        counterText: "",
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Confirm Password",
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDDF6D2), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              _step == 1 ? "Enter Your Details" : _step == 2 ? "Enter OTP" : "Set Your Password",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: _step == 1 ? _buildStep1() : _step == 2 ? _buildStep2() : _buildStep3(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DC19D),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_step == 3 ? "Submit" : "Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
