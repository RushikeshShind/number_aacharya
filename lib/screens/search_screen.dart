
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:number_aacharya/screens/view_report_screen.dart';
import 'package:number_aacharya/screens/home_screen.dart';
import 'package:number_aacharya/screens/analyzing_screen.dart';
import 'package:number_aacharya/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, dynamic> prefilledData;

  const SearchScreen({super.key, required this.prefilledData});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  String? _selectedCountryCode = '+91';
  List<Map<String, dynamic>> _countryCodes = [];
  bool _isLoading = false;
  int _maxPhoneLength = 10;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late bool _isFirstNameReadOnly;
  late bool _isLastNameReadOnly;
  late bool _isDobReadOnly;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.prefilledData['firstName'] ?? '';
    lastNameController.text = widget.prefilledData['lastName'] ?? '';
    dobController.text = widget.prefilledData['dob'] ?? '';
    phoneController.text = widget.prefilledData['phone'] ?? '';

    _isFirstNameReadOnly = (widget.prefilledData['firstName'] ?? '').isNotEmpty;
    _isLastNameReadOnly = (widget.prefilledData['lastName'] ?? '').isNotEmpty;
    _isDobReadOnly = (widget.prefilledData['dob'] ?? '').isNotEmpty;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _fetchCountryCodes();
  }

  Future<void> _fetchCountryCodes() async {
    try {
      final response = await ApiService.getCountryMaster();
      if (response.containsKey('data') && response['data'] is List) {
        setState(() {
          _countryCodes = List<Map<String, dynamic>>.from(response['data']);
          if (_countryCodes.every((code) => code['country_code'] != '+91')) {
            _selectedCountryCode = _countryCodes.isNotEmpty ? _countryCodes[0]['country_code'] : '+91';
            _updateMaxPhoneLength();
          } else {
            _updateMaxPhoneLength();
          }
        });
      }
    } catch (e) {
      print("Error fetching country codes: $e");
    }
  }

  void _updateMaxPhoneLength() {
    _maxPhoneLength = (_selectedCountryCode == '+91') ? 10 : 20;
  }

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(name.trim());
  }

  bool _isValidPhone(String phone) {
    final phoneTrimmed = phone.trim();
    if (_selectedCountryCode == '+91') {
      return RegExp(r'^[0-9]{10}$').hasMatch(phoneTrimmed);
    } else {
      return RegExp(r'^[0-9]{8,}$').hasMatch(phoneTrimmed);
    }
  }

  bool _isValidDate(String date) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) return false;
    try {
      final parts = date.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final dateTime = DateTime(year, month, day);
      final now = DateTime.now();
      return dateTime.day == day &&
          dateTime.month == month &&
          dateTime.year == year &&
          dateTime.isBefore(now.add(const Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }

  bool _validateAllFields() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final dob = dobController.text.trim();
    final phone = phoneController.text.trim();
    
    if (firstName.isEmpty) {
      _showModernSnackbar("Please enter first name");
      return false;
    }
    if (lastName.isEmpty) {
      _showModernSnackbar("Please enter last name");
      return false;
    }
    if (dob.isEmpty) {
      _showModernSnackbar("Please select date of birth");
      return false;
    }
    if (phone.isEmpty) {
      _showModernSnackbar("Please enter phone number");
      return false;
    }
    if (!_isValidName(firstName)) {
      _showModernSnackbar("Please enter a valid first name");
      return false;
    }
    if (!_isValidName(lastName)) {
      _showModernSnackbar("Please enter a valid last name");
      return false;
    }
    if (!_isValidDate(dob)) {
      _showModernSnackbar("Please enter a valid date of birth");
      return false;
    }
    if (!_isValidPhone(phone)) {
      _showModernSnackbar(_selectedCountryCode == '+91' 
          ? "Please enter a valid 10-digit phone number" 
          : "Please enter a valid phone number");
      return false;
    }
    return true;
  }

  void _showModernSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC1121F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate() async {
    if (_isDobReadOnly) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF008000),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  Future<void> _submitInquiry() async {
    if (!_validateAllFields() || _isLoading) return;
    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF008000), Color(0xFF00A000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF008000).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Analyzing your data",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Creating your numerology report...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final systemUserId = await ApiService.getStoredSystemUserId();
      if (systemUserId == null) {
        Navigator.pop(context);
        _showModernSnackbar("Please log in to submit an inquiry");
        setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService.addInquiry(
        systemUserId: systemUserId,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dob: dobController.text.trim(),
        mobileNo: phoneController.text.trim(),
        countryCode: _selectedCountryCode ?? '+91',
      );

      Navigator.pop(context);

      if (response.containsKey('data') && response['data'] is List && response['data'].isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewReportScreen(reportData: response['data'][0]),
          ),
        );
        firstNameController.clear();
        lastNameController.clear();
        dobController.clear();
        phoneController.clear();
        setState(() => _selectedCountryCode = '+91');
      } else {
        _showModernSnackbar('Failed to load report data');
      }
    } catch (e) {
      Navigator.pop(context);
      _showModernSnackbar("Error: Please try again");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(width),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Full-width header image
                          _buildHeaderImage(width),
                          
                          // Content section with padding
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                            child: Column(
                              children: [
                                SizedBox(height: height * 0.025),
                                _buildTextField("First Name", firstNameController, width, 
                                    Icons.person_outline, readOnly: _isFirstNameReadOnly),
                                SizedBox(height: height * 0.018),
                                _buildTextField("Last Name", lastNameController, width, 
                                    Icons.person_outline, readOnly: _isLastNameReadOnly),
                                SizedBox(height: height * 0.018),
                                _buildDateField(width),
                                SizedBox(height: height * 0.018),
                                _buildPhoneField(width),
                                SizedBox(height: height * 0.035),
                                _buildActionButtons(width),
                                SizedBox(height: height * 0.03),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeaderImage(double width) {
    return Column(
      children: [
        // Numerology circle image - increased size
        SizedBox(
          width: width * 0.75,
          height: 280,
          child: Image.asset(
            'assets/images/enter_details.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFFB84D),
                      const Color(0xFF7FD89E).withOpacity(0.6),
                      const Color(0xFFB8E6C9).withOpacity(0.4),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new, 
                  color: const Color(0xFF008000), size: width * 0.05),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "New Inquiry",
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008000), Color(0xFF00A000)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Enter Details",
        style: TextStyle(
          fontSize: width * 0.045,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    double width,
    IconData icon, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasFocus ? Colors.red : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: hasFocus ? const Color(0xFF008000) : Colors.black87,
                  ),
                  inputFormatters: label.contains("Name")
                      ? [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          LengthLimitingTextInputFormatter(50),
                        ]
                      : [],
                  decoration: InputDecoration(
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Date of Birth (DD/MM/YYYY)",
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasFocus ? Colors.red : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: dobController,
                  keyboardType: TextInputType.number,
                  readOnly: _isDobReadOnly,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: hasFocus ? const Color(0xFF008000) : Colors.black87,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    _DateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                      onPressed: _isDobReadOnly ? null : _selectDate,
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Phone Number",
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Row(
          children: [
            Container(
              width: width * 0.38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['country_code'],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              height: 20,
                              child: Image.network(
                                country['flag_file'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.flag, size: 18, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              country['country_code'],
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountryCode = newValue;
                        _updateMaxPhoneLength();
                      });
                    },
                    isExpanded: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Focus(
                child: Builder(
                  builder: (context) {
                    final hasFocus = Focus.of(context).hasFocus;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasFocus ? Colors.red : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w400,
                          color: hasFocus ? const Color(0xFF008000) : Colors.black87,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_maxPhoneLength),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(double width) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : _submitInquiry,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                    : const LinearGradient(
                        colors: [Color(0xFF008000), Color(0xFF00A000)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF008000).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Search",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.042,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC1121F), Color(0xFFE63946)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC1121F).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.042,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

// Custom painter for mystical pattern fallback
class MysticalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw radiating lines from bottom center
    final center = Offset(size.width / 2, size.height);
    final gradient = LinearGradient(
      colors: [
        Colors.yellow.withOpacity(0.6),
        Colors.green.withOpacity(0.3),
        Colors.transparent,
      ],
    );

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * 3.14159 / 180;
      final endX = center.dx + size.width * 0.8 * cos(angle - 3.14159 / 2);
      final endY = center.dy + size.height * 1.2 * sin(angle - 3.14159 / 2);
      
      paint.shader = gradient.createShader(
        Rect.fromPoints(center, Offset(endX, endY)),
      );
      
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll('/', '');
    String formatted = '';
    
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digitsOnly[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}