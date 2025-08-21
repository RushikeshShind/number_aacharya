import 'dart:async';
import 'package:flutter/material.dart';
import 'analyzing_screen.dart';
import 'report_ready_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isInputMode = false;
  final nameController = TextEditingController(text: "Rushikesh Shinde");
  final dobController = TextEditingController(text: "03/01/2003");
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9F2D9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          "New Search",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Analyze your number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/search.png',
              height: 160,
            ),
            const SizedBox(height: 30),
            _buildTextField("Name", nameController),
            const SizedBox(height: 15),
            _buildTextField("Date of Birth", dobController,
                suffixIcon: Icons.calendar_today),
            const SizedBox(height: 15),
            _buildDropdown(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton("Input", isInputMode, true),
                const SizedBox(width: 10),
                _buildToggleButton("Suggest", !isInputMode, false),
              ],
            ),
            const SizedBox(height: 15),
            if (isInputMode) _buildTextField("Enter Phone Number", phoneController),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton("Search", Colors.green, Colors.white, () {
                  _showAnalyzingScreen(context);
                }),
                const SizedBox(width: 15),
                _buildActionButton("Cancel", Colors.yellow[700]!, Colors.white, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Country of Birth", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: "India", child: Text("India")),
            DropdownMenuItem(value: "USA", child: Text("USA")),
            DropdownMenuItem(value: "UK", child: Text("UK")),
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool active, bool isInput) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isInputMode = isInput;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD9F2D9) : Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  void _showAnalyzingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyzingScreen()),
    ).then((_) {
      _showReportScreen(context);
    });
  }

  void _showReportScreen(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportReadyScreen()),
      );
    });
  }
}