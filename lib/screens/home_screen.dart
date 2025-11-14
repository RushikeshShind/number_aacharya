import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/pdf_viewer_screen.dart';
import 'package:number_aacharya/screens/view_report_screen.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_screen.dart';
import 'credits_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'login_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const ListScreen(),
    const SearchScreen(prefilledData: {}),
    const CreditsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      final systemUserId = await ApiService.getStoredSystemUserId();

      if (userStr == null || systemUserId == null) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginFormScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint("Session check error: $e");
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginFormScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<String> _getLatestCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_credits") ?? "0";
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      final credits = await _getLatestCredits();
      if (credits == "0") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreditsScreen()),
        );
        return;
      }
    }

    setState(() => _selectedIndex = index);
    if (index != 0) {
      final screen = _screens[index];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    }
  }

 // Place this INSIDE your _HomeScreenState class, replacing the old build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    body: _screens[_selectedIndex],
    extendBody: true,
    bottomNavigationBar: Container(
  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 255, 255, 255),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF008000).withOpacity(0.5),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  clipBehavior: Clip.none,           
  child: Container(
    height: 75,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.folder_open_outlined,
                label: "Reports",
                index: 1,
              ),
              _buildCenterButton(),
              _buildNavItem(
                icon: Icons.local_offer_outlined,
                label: "Credits",
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                index: 4,
              ),
            ],
          ),
        ),
    )
      );

  
}

// Helper method - place inside _HomeScreenState class
Widget _buildNavItem({
  required IconData icon,
  required String label,
  required int index,
}) {
  final isSelected = _selectedIndex == index;
  
  return GestureDetector(
    onTap: () => _onItemTapped(index),
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? const Color(0xFF008000) : Colors.grey.shade600,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color.fromARGB(255, 14, 13, 13) : Colors.grey.shade600,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF008000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    ),
  );
}

// Center button - place inside _HomeScreenState class
Widget _buildCenterButton() {
  final isSelected = _selectedIndex == 2;
  
  return Transform.translate(
    offset: const Offset(0, -32), // Increased offset to properly float above
    child: GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    Color(0xFF008000),
                    const Color.fromARGB(255, 2, 172, 2),
                  ]
                : [
                    Color(0xFF008000),
                    const Color.fromARGB(255, 2, 206, 2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 84, 225, 65).withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 4, // Thicker white border
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/report.png',
            height: 36,
            width: 36,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
}

// END OF _HomeScreenState CLASS - Add closing brace }

// ═══════════════════════════════════════════════════════════════
// Place this OUTSIDE all classes, at the very end of the file
// ═══════════════════════════════════════════════════════════════

class _UniversePatternPainter extends CustomPainter {
  final double animationValue;
  _UniversePatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06 * animationValue)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final stars = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.85, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.85),
      Offset(size.width * 0.65, size.height * 0.55),
      Offset(size.width * 0.12, size.height * 0.45),
    ];

    for (var i = 0; i < stars.length; i++) {
      final point = stars[i];
      final starOpacity = ((animationValue + (i * 0.1)) % 1.0);
      canvas.drawCircle(
        point,
        2 * animationValue,
        paint
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.15 * starOpacity),
      );
      final crossPaint = paint
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.08 * starOpacity);
      canvas.drawLine(
        Offset(point.dx - (5 * animationValue), point.dy),
        Offset(point.dx + (5 * animationValue), point.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(point.dx, point.dy - (5 * animationValue)),
        Offset(point.dx, point.dy + (5 * animationValue)),
        crossPaint,
      );
    }

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * (0.2 + (0.05 * animationValue)),
      size.width * 0.6,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.8,
      size.height * (0.7 - (0.05 * animationValue)),
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(
      path1,
      paint
        ..color = Colors.white.withOpacity(0.1 * animationValue)
        ..strokeWidth = 2,
    );

    final path2 = Path();
    path2.moveTo(size.width, size.height * 0.3);
    path2.quadraticBezierTo(
      size.width * 0.7,
      size.height * (0.5 - (0.03 * animationValue)),
      size.width * 0.4,
      size.height * 0.4,
    );
    path2.quadraticBezierTo(
      size.width * 0.2,
      size.height * (0.35 + (0.03 * animationValue)),
      0,
      size.height * 0.7,
    );
    canvas.drawPath(
      path2,
      paint
        ..color = Colors.white.withOpacity(0.08 * animationValue)
        ..strokeWidth = 1.5,
    );

    for (var i = 0; i < 8; i++) {
      final t = i / 8;
      final dotOpacity = ((animationValue + t) % 1.0);
      canvas.drawCircle(
        Offset(size.width * t, size.height * (0.4 + (0.2 * (1 - t)))),
        1.5,
        paint
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.12 * dotOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(_UniversePatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});
  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = false;
  String? _firstName;
  String? _userCredits;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchLatestInquiries();
    _fetchCredits();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final storedId = await ApiService.getStoredSystemUserId();
      if (storedId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null && mounted) {
        final user = jsonDecode(userStr);
        setState(() => _firstName = user['name'] ?? "No Name");
      }
    } catch (e) {
      debugPrint("User details error: $e");
    }
  }

  Future<void> _fetchLatestInquiries() async {
    if (_isLoading || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getLatestInquiries();
      if (!mounted) return;
      if (response['success'] == false) return;
      if (response['data'] is List) {
        final data = List<Map<String, dynamic>>.from(response['data']);
        final latestFive = data.reversed.take(5).toList();
        setState(() => _inquiries = latestFive);
      } else {
        setState(() => _inquiries = []);
      }
    } catch (e) {
      debugPrint("Latest inquiries error: $e");
      if (mounted) setState(() => _inquiries = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCredits() async {
    try {
      final response = await ApiService.getUserCredits();
      if (!mounted) return;
      if (response['success'] == false) return;
      final credits = response["data"]?.isNotEmpty == true
          ? response["data"][0]["credit_balance"]?.toString() ?? "0"
          : "0";
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_credits", credits);
      if (mounted) setState(() => _userCredits = credits);
    } catch (e) {
      debugPrint("Credits error: $e");
      if (mounted) setState(() => _userCredits = "0");
    }
  }

  void _viewReport(Map<String, dynamic> inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewReportScreen(reportData: inquiry)),
    );
  }

  void _viewPdf(String url) {
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerScreen(url: url)),
    );
  }

  Future<String> _getLatestCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_credits") ?? "0";
  }

  void _checkDifferentNumber(Map<String, dynamic> inquiry) async {
    final credits = await _getLatestCredits();
    if (credits == "0") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CreditsScreen()));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          prefilledData: {
            'firstName': inquiry['first_name'] ?? '',
            'lastName': inquiry['last_name'] ?? '',
            'dob': inquiry['date_of_birth'] ?? '',
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF008000),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF008000).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${_firstName ?? 'Guest'}',
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              "Welcome Back",
                              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Image.asset('assets/icons/notification.png', height: 24, width: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── CREDIT CARD (SOLID GREEN) ──
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFF008000),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF008000).withOpacity(0.4),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(seconds: 3),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, animValue, child) {
                                      return CustomPaint(painter: _UniversePatternPainter(animValue));
                                    },
                                  ),
                                ),
                                // ... (depth circles – unchanged)
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(seconds: 4),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, circleAnim, child) {
                                    return Stack(
                                      children: [
                                        Positioned(
                                          top: -60 + (10 * circleAnim),
                                          right: -60 + (10 * circleAnim),
                                          child: Container(
                                            width: 160, height: 160,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(colors: [
                                                Colors.white.withOpacity(0.12 * circleAnim),
                                                Colors.transparent,
                                              ]),
                                            ),
                                          ),
                                        ),
                                        // ... other circles
                                      ],
                                    );
                                  },
                                ),
                                // ... content (unchanged)
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 30.0, end: 0.0),
                                  curve: Curves.easeOut,
                                  builder: (context, slideValue, child) {
                                    return Transform.translate(
                                      offset: Offset(0, slideValue),
                                      child: Opacity(
                                        opacity: 1 - (slideValue / 30),
                                        child: Padding(
                                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Your Credits",
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(context).size.width * 0.038,
                                                            color: Colors.white.withOpacity(0.95),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            _userCredits ?? "0",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(context).size.width * 0.11,
                                                              fontWeight: FontWeight.w900,
                                                              color: Colors.white,
                                                              letterSpacing: -2,
                                                              shadows: [Shadow(color: Colors.black.withOpacity(0.15), offset: Offset(0, 2), blurRadius: 8)],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                                                    ),
                                                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: MediaQuery.of(context).size.width * 0.08),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditsScreen()));
                                                    _fetchCredits();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    foregroundColor: const Color(0xFF008000),
                                                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.018),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                    elevation: 0,
                                                  ),
                                                  child: Text("Buy Credits", style: TextStyle(fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.04)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── RECENT REPORTS HEADER ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2D3748))),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen())),
                      child: const Row(
                        children: [
                          Text("View All", style: TextStyle(color: Color(0xFF008000), fontWeight: FontWeight.w600, fontSize: 15)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF008000)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── LOADING / EMPTY / LIST ──
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF008000))))
                else if (_inquiries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No recent reports available', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _inquiries.map((inquiry) {
                      final dateParts = (inquiry['date_of_birth'] ?? '02/05/1998').split('/');
                      final day = dateParts.isNotEmpty ? dateParts[0] : '02';
                      final month = dateParts.length > 1 ? dateParts[1] : '05';
                      final year = dateParts.length > 2 ? dateParts[2] : '1998';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF8FCFF)]),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF008000).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                // ── TOP SECTION ──
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF008000).withOpacity(0.08),
                                        const Color(0xFF008000).withOpacity(0.03),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70, height: 70,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF008000),
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [BoxShadow(color: const Color(0xFF008000).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(day, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)),
                                            Text('$month/$year', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${inquiry['first_name'] ?? ''} ${inquiry['last_name'] ?? ''}'.trim(),
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF1A202C)),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF008000).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.phone, size: 12, color: Color(0xFF008000)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    inquiry['phone_number']?.toString() ?? 'N/A',
                                                    style: const TextStyle(fontSize: 12, color: Color(0xFF008000), fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── ACTION SECTION ──
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // VIEW BUTTON (GREEN)
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _viewReport(inquiry),
                                                borderRadius: BorderRadius.circular(14),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF008000).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(color: const Color(0xFF008000).withOpacity(0.2), width: 1),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.visibility, size: 18, color: Color(0xFF008000)),
                                                      SizedBox(width: 8),
                                                      Text("View", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF008000))),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // PDF BUTTON (NEW RED: #C1121F)
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _viewPdf(inquiry['report_file']?.toString() ?? ''),
                                                borderRadius: BorderRadius.circular(14),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFC1121F).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(color: const Color(0xFFC1121F).withOpacity(0.2), width: 1),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/icons/download.png',
                                                        height: 18,
                                                        width: 18,
                                                        color: const Color(0xFFC1121F),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        "PDF",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFFC1121F),
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
                                      const SizedBox(height: 12),

                                      // CHECK DIFFERENT NUMBER (GREEN)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _checkDifferentNumber(inquiry),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF008000),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            elevation: 0,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.refresh_rounded, size: 18),
                                              SizedBox(width: 8),
                                              Text("Check Different Number", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}