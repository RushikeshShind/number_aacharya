import 'package:flutter/material.dart';
import 'dart:convert';

class AppColors {
  static const Color primaryGreen = Color(0xFF008000);
  static const Color accentYellow = Color(0xFFF6B042);
  static const Color bloodRed = Color(0xFFC1121F);
  static const Color neutralOrange = Color(0xFFFF9800);
  static const Color lightGray = Color(0xFF9E9E9E);
  static const Color purple = Color(0xFF9C27B0);
  static const Color navyBlue = Color(0xFF000080);
  static const Color gridMissing = Color(0xFFEEEEEE);
  static const Color gridPresent = Color(0xFF1A1A1A);

  static final Map<String, Color> birthColorMap = {
    'Orange/Red': const Color(0xFFFF5722),
    'Milk White/Silver': const Color(0xFFF5F5F5),
    'Yellow/Gold': const Color(0xFFFFC107),
    'Dark Colours (Blue & Grey)': const Color(0xFF37474F),
    'Green': primaryGreen,
    'Pink/Cream/White': const Color(0xFFFCE4EC),
    'Black/Navy Blue': navyBlue,
    'Red': const Color(0xFFF44336),
  };
}
class PageViewPhysicsWrapper extends StatelessWidget {
  final ScrollPhysics physics;
  final Widget child;
  const PageViewPhysicsWrapper({super.key, required this.physics, required this.child});

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: ScrollController(),
      child: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(physics: physics),
        child: child,
      ),
    );
  }
}
class ViewReportScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;
  const ViewReportScreen({super.key, required this.reportData});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  

  int currentPage = 0;
  final int totalPages = 16;
  bool _showTutorial = true;
  int _categoryIndex = 0;

  Map<String, dynamic> _decodeResponseData() {
    dynamic data = widget.reportData['response_data'];

    // Step 1: If it's a string, decode once
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        print("First JSON decode failed: $e");
      }
    }

    // Step 2: If still a string → double-encoded → decode again
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        print("Second JSON decode failed: $e");
      }
    }

    // Ensure it's a Map
    return data is Map<String, dynamic> ? data : {};
  }

  Map<String, dynamic> get result {
    final data = _decodeResponseData();
    return data['result'] ?? {};
  }

  Map<String, dynamic> get mobileCheck {
    final data = _decodeResponseData();
    final resultData = data['result'] ?? {};
    return resultData['mobileCheckResult'] ?? {};
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
  if (index < 0 || index >= totalPages) return; // ← Ye line add karo
  setState(() {
    currentPage = index;
    if (index > 0) _showTutorial = false;
    if (index == 14) _categoryIndex = 0;
  });
}

  void _goToSearch() => Navigator.pushReplacementNamed(context, '/search');
  void _goToHome() =>
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

  @override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final bool hideHeaderFooter = false;
final bool isTransparent = [2, 3].contains(currentPage);


  return Scaffold(
    backgroundColor: Colors.white,
    extendBody: false, 
    body: AnimatedBuilder(
    animation: _animController,
    builder: (context, child) {
      return Transform.scale(
        scale: _scaleAnim.value,
        child: Opacity(
          opacity: _fadeAnim.value,
          child: Stack(
            children: [
              Column(
                children: [
                  if (!hideHeaderFooter) _buildTopHeader(size),
                  
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const BouncingScrollPhysics(),
                        itemCount: totalPages,
                        itemBuilder: (context, i) => _buildPage(i, size),
                      ),
                    
                  ),
                  if (!hideHeaderFooter)
    Container(
      padding: EdgeInsets.only(
        top: size.height * 0.02,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: _buildBottomDots(size),
    ),
                    ],
                  ),
                  if (_showTutorial && currentPage == 0)
                    _buildTutorialOverlay(size),
                  if (currentPage == totalPages - 1)
                    _buildFinalButtons(size),
                ],
              ),
            ),
          );
        },
      ),
    
  );
}

  /* --------------------------------------------------------------------- */
  /*                               UI ELEMENTS                             */
  /* --------------------------------------------------------------------- */

  Widget _buildTutorialOverlay(Size size) => GestureDetector(
  onTap: () {}, // Blocks all taps when tutorial is showing
  child: Container(
    color: Colors.black.withOpacity(0.6),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swipe_left, size: 80, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            "See more information – swipe left",
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _showTutorial = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              "Got it!",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  ),
);


Widget _buildFinalButtons(Size size) => Positioned(
  bottom: size.height * 0.12,
  left: size.width * 0.1,
  right: size.width * 0.1,
  child: Column(
    children: [
    
      // ElevatedButton(
      //   onPressed: _goToSearch,
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: AppColors.primaryGreen,
      //     padding: const EdgeInsets.symmetric(vertical: 16),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30),
      //     ),
      //     elevation: 8,
      //     shadowColor: AppColors.primaryGreen.withOpacity(0.4),
      //   ),
      //   child: const Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(Icons.search, color: Colors.white, size: 24),
      //       SizedBox(width: 10),
      //       Text(
      //         "Search Again",
      //         style: TextStyle(
      //           fontSize: 18,
      //           fontWeight: FontWeight.w600,
      //           color: Colors.white,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      
      const SizedBox(height: 12),
      
      // // Exit to Home Button
      // OutlinedButton(
      //   onPressed: _goToHome,
      //   style: OutlinedButton.styleFrom(
      //     side: const BorderSide(color: AppColors.primaryGreen, width: 2),
      //     padding: const EdgeInsets.symmetric(vertical: 16),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30),
      //     ),
      //     backgroundColor: Colors.white,
      //   ),
      //   child: const Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(Icons.home, color: AppColors.primaryGreen, size: 24),
      //       SizedBox(width: 10),
      //       Text(
      //         "Exit to Home",
      //         style: TextStyle(
      //           fontSize: 18,
      //           fontWeight: FontWeight.w600,
      //           color: AppColors.primaryGreen,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    ],
  ),
);

  /* --------------------------------------------------------------------- */
  /*                               PAGE BUILDER                            */
  /* --------------------------------------------------------------------- */

  Widget _buildPage(int index, Size size) {
    final bool hasBg = ![
      2,
      3,
    ].contains(index); // Exclude Conductor (page 3) and Driver (page 4)
    final Widget page = switch (index) {
      0 => _buildPage1(size), //view frist screen
      1 => _buildPage2(size), //total number screen
      2 => _buildPage4(size), //driver number
      3 => _buildPage3(size), //conductor number
      4 => _buildPage5(size), //lucky number
      5 => _buildPage6(size), //unlucky number
      6 => _buildPage8(size), //Mobile case color
      7 => _buildPage10(size), //lucky photo direction
      8 => _buildPage9(size), //charging station vastu
      9 => _buildPage11(size), //lucky wallpaper
      10 => _buildPage7(size), // Recommended number
      11 => _buildPage12(size), // Issue Found
      12 => _buildPage13(size), //numberology grid
      13 => _buildPage14(size), //2nd number analysis
      14 => _buildPage15(size), //Mobile number pair
      15 => _buildPage16(size), //final advices
      _ => const SizedBox.shrink(),
    };

 if (!hasBg) return page;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: page,
    );
  }

Widget _buildTopHeader(Size size, {bool isTransparent = false}) => Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      bottom: 12,
      left: size.width * 0.04,
      right: size.width * 0.04,
    ),
    decoration: const BoxDecoration(color: Colors.transparent),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo on the left
        Image.asset(
          'assets/images/AMIG.png',
          height: size.width * 0.20, // Slightly smaller for small screens
          width: size.width * 0.20,
          fit: BoxFit.contain,
        ),
        SizedBox(width: size.width * 0.02),
        // Text content in the center
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Number Aacharya",
                style: TextStyle(
                  fontSize: size.width * 0.048, // More responsive
                  fontWeight: FontWeight.bold,
                  color: isTransparent ? Colors.white : AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: size.height * 0.003),
              Text(
                "Personal numerology summary",
                style: TextStyle(
                  fontSize: size.width * 0.032, // More responsive
                  color: isTransparent
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Exit button on the right
        IconButton(
          onPressed: _goToHome,
          icon: Icon(
            Icons.logout,
            color: isTransparent ? Colors.white : AppColors.primaryGreen,
            size: size.width * 0.055, // Slightly smaller
          ),
          tooltip: 'Exit to Home',
          padding: EdgeInsets.all(size.width * 0.02),
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );


  Widget _buildBottomDots(Size size, {bool isTransparent = false}) => Container(
  color: Colors.transparent,
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      totalPages,
      (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: currentPage == i ? 24 : 8,
        decoration: BoxDecoration(
          color: currentPage == i
              ? (isTransparent ? Colors.white : AppColors.primaryGreen)
              : (isTransparent
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.lightGray),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  ),
);

  /* --------------------------------------------------------------------- */
  /*                               PAGE 1                                 */
  /* --------------------------------------------------------------------- */
  Widget _buildPage1(Size size) {
    final fname = result['fname'] ?? '';
    final lname = result['lname'] ?? '';
    final dob = result['dob'] ?? widget.reportData['date_of_birth'] ?? 'N/A';
    final phone = result['phone'] ?? widget.reportData['phone_number'] ?? 'N/A';

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: _buildSafePage(
        size,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: size.height * 0.03),
            Image.asset(
              'assets/images/report.png',
              height: size.height * 0.22,
            ),
            const SizedBox(height: 20),
            const Text(
              "You Entered Details",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
  "${fname.toUpperCase()} ${lname.toUpperCase()}",
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: size.width * 0.058, 
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
    letterSpacing: size.width * 0.003, 
  ),
),
            const SizedBox(height: 30),
            _labelWithArrow("First name", fname, true),
            const SizedBox(height: 20),
            _labelWithArrow("Last name", lname, false),
            const SizedBox(height: 20),
            _labelWithArrow("Date of birth", dob, true),
            const SizedBox(height: 20),
            _labelWithArrow("Phone Number", phone, false),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              icon: const Icon(
                Icons.description,
                size: 22,
                color: Colors.white,
              ),
              label: const Text(
                "Check Report",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.14,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Developed by",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            const Text(
              " AMSUN UNIVERSE LLP",
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _labelWithArrow(String label, String value, bool arrowOnLeft) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            if (arrowOnLeft) ...[
              Image.asset('assets/images/Fristname.png', height: 35, width: 35),
              const SizedBox(width: 15),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: arrowOnLeft
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!arrowOnLeft) ...[
              const SizedBox(width: 15),
              Image.asset('assets/images/lastname.png', height: 35, width: 35),
            ],
          ],
        ),
      );

  /* --------------------------------------------------------------------- */
  /*                               PAGE 2                                 */
  /* --------------------------------------------------------------------- */
  Widget _buildPage2(Size size) {
  final total = result['mobileNumberTotal'] ?? {};
  final steps = List<int>.from(total['intermediateResults'] ?? []);
  final phone = result['phone'] ?? '';

  return _buildSafePage(
  size,
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          // Title with arrow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: size.width * 0.115,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                    children: const [
                      TextSpan(
                        text: "PHONE\n",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "NUMBER ",
                        style: TextStyle(color: AppColors.primaryGreen),
                      ),
                      TextSpan(
                        text: "TOTAL",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone number display box
          const Text(
            "You Entered Details",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Phone Number",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 28),

          // Calculation section
          const Text(
            "Calculation :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Each digit of your mobile number is added together until we reach a single-digit number",
            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Example calculation
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: "Example: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: "If your mobile number is ",
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                const TextSpan(
                  text: "9876543210",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                TextSpan(text: "9 + 8 + 7 + 6 + 5 + 4 + 3 + 2 + 1 + 0 = 45\n"),
                TextSpan(text: "→ 4 + 5 = 9 "),
                TextSpan(
                  text: "✓",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Total number display
          const Text(
            "Total number :",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: steps.asMap().entries.map((e) {
                final isLast = e.key == steps.length - 1;
                return Row(
                  children: [
                    Text(
                      "${e.value}",
                      style: TextStyle(
                        fontSize: isLast
                            ? size.width * 0.20
                            : size.width * 0.14,
                        fontWeight: FontWeight.w900,
                        color: isLast ? AppColors.primaryGreen : Colors.black,
                      ),
                    ),
                    if (!isLast)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.black87,
                          size: 32,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    
  );
}
  /* --------------------------------------------------------------------- */
  /*                               PAGE 3 & 4                              */
  /* --------------------------------------------------------------------- */
  Widget _buildPage3(Size size) {
    final num = result['conductorNumber']?.toString() ?? '';
    final text = result['conductorText'] ?? '';
    return _gradientPageWithImage(
      size,
      "Conductor",
      num,
      text,
      'assets/images/conductor.jpg',
    );
  }

  Widget _buildPage4(Size size) {
    final num = result['driverNumber']?.toString() ?? '';
    final text = result['driverText'] ?? '';
    return _gradientPageWithImage(
      size,
      "Driver",
      num,
      text,
      'assets/images/driver_number.jpg',
    );
  }

  Widget _gradientPageWithImage(
  Size size,
  String title,
  String num,
  String desc,
  String imagePath,
) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.70),
            Colors.black.withOpacity(0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
  child: Column(
    children: [

      // LEFT-ALIGNED HEADER BLOCK
      Align(
        alignment: Alignment.centerLeft, // ← ALWAYS LEFT
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.06,
            size.height * 0.02,
            size.width * 0.06,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ← LEFT
            children: [
              Text(
                "Your",
                style: TextStyle(
                  fontSize: size.width * 0.095,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),

              Text(
                title, // Drive Number / Conductor Number
                style: TextStyle(
                  fontSize: size.width * 0.095,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                  height: 1.0,
                ),
              ),

              Text(
                "Number",
                style: TextStyle(
                  fontSize: size.width * 0.095,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),

              SizedBox(height: size.height * 0.005),

              Text(
                "as per your Date of Birth",
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
      

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ← ALL LEFT
                  children: [
                    SizedBox(height: size.height * 0.06),
                    
                    
                    // Big Number - CENTER ME!
                    Center(
                      child: Text(
                        num,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: size.width * 0.40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: size.width * -0.002,
                          height: 0.9,
                        ),
                      ),
                    ),


                    SizedBox(height: size.height * 0.03),

                    // Description - LEFT ALIGNED
                    Text(
                      desc,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: size.width * 0.038,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),
                  ],
                ),
              ),
            ),

            // Swipe indicator - RIGHT side
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.06,
                0,
                size.width * 0.06,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: _swipeLeft(size),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


 /* --------------------------------------------------------------------- */
  /*                               PAGE 5 & 6                              */
  /* --------------------------------------------------------------------- */
  Widget _buildPage5(Size size) {
    final lucky = List<String>.from(result['luckyNumbers'] ?? []);
    return _numberListPage(
      size,
      "Lucky",
      "(friendly)",
      lucky,
      AppColors.primaryGreen,
      false,
    );
  }

  Widget _buildPage6(Size size) {
    final unlucky = List<String>.from(result['unluckyNumbers'] ?? []);
    return _numberListPage(
      size,
      "Unlucky",
      "(Enemy)",
      unlucky,
      AppColors.bloodRed,
      true,
    );
  }

  Widget _numberListPage(
    Size size,
    String type,
    String subtitle,
    List<String> numbers,
    Color color,
    bool isUnlucky,
  ) => _buildSafePage(
    size,
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Your\n",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: "$type ",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: subtitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const TextSpan(
                text: "\nNumber(s)",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Updated description text based on isUnlucky flag
        Text(
          isUnlucky
              ? "This number(s) may not fully support your energy, so it's best to avoid relying on it"
              : "This is your lucky number(s), chosen to bring clarity and good energy into your day.",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        // Updated number display with commas
        Center(
          child: Wrap(
            spacing: 0,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(
              numbers.length * 2 - 1, // Total elements including commas
              (index) {
                if (index.isOdd) {
                  // This is a comma position
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ",",
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  );
                } else {
                  // This is a number position
                  final numberIndex = index ~/ 2;
                  return Text(
                    numbers[numberIndex],
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1.0,
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        _swipeLeft(size),
        const SizedBox(height: 20),
      ],
    ),
  );

 /* --------------------------------------------------------------------- */
  /*                               PAGE 7                                 */
  /* --------------------------------------------------------------------- */
  Widget _buildPage7(Size size) {
    final special = result['specialNumber']?.toString() ?? '';
    final compounds = List<String>.from(result['compoundNumber'] ?? []);

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Recommended",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
          const Text(
            "Mobile Number Total",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Updated text as per client requirement
          const Text(
            "For the best results, select a mobile number that totals to:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Special Number Display
          Center(
            child: Text(
              special,
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Compound Number Explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "When all digits of your mobile number are added, the first total (usually two digits) is called the compound. This compound helps show the deeper meaning of that number.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Compound Numbers Display
          Center(
            child: Text(
              compounds.join(', '),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------------- */
  /*                               PAGE 12 - COMBINED WITH STATUS          */
  /* --------------------------------------------------------------------- */
  Widget _buildPage12(Size size) {
    final status = mobileCheck['status']?.toString() ?? 'OK';
    final exception = mobileCheck['exception']?.toString();
    final rawIssues = mobileCheck['issues'];
    final List<String> issues = rawIssues is List
        ? rawIssues.map((e) => e.toString()).toList()
        : [];

    // === CHOOSE MESSAGE BASED ON STATUS & EXCEPTION ===
    String message;
    Color bgColor;
    Color textColor;
    IconData statusIcon;

    if (status == 'OK') {
      message =
          "This mobile number suits your personality 100%, creating balance, confidence, and success.";
      bgColor = AppColors.primaryGreen.withAlpha(25);
      textColor = AppColors.primaryGreen;
      statusIcon = Icons.check_circle;
    } else if (status == 'Issues Found' && exception == 'lessOK') {
      message =
          "Your personality and this number resonate 99% — an excellent match with just minor variations.";
      bgColor = AppColors.accentYellow.withAlpha(51);
      textColor = AppColors.neutralOrange;
      statusIcon = Icons.info;
    } else if (status == 'Issues Found') {
      message = "Please use a different phone number.";
      bgColor = AppColors.bloodRed.withAlpha(25);
      textColor = AppColors.bloodRed;
      statusIcon = Icons.warning;
    } else {
      message = "Please consider a different phone number.";
      bgColor = AppColors.accentYellow.withAlpha(51);
      textColor = AppColors.neutralOrange;
      statusIcon = Icons.info;
    }

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          const Text(
            "Mobile Number",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Analysis",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),

          // Status Message Box with Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withAlpha(51), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(statusIcon, color: textColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Issues Section
          if (issues.isNotEmpty) ...[
            const Text(
              "Identified Issues",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Issues List in a Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bloodRed.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.bloodRed.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Column(
                children: issues
                    .map((issue) => _issueItem(size, issue))
                    .toList(),
              ),
            ),
          ] else ...[
            // No Issues Found
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "No issues found. This number is perfect for you!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _issueItem(Size size, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.close_rounded,
              color: AppColors.bloodRed,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  height: 1.5,
                  color: AppColors.bloodRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  /* --------------------------------------------------------------------- */
  /*                               PAGE 8                                 */
  /* --------------------------------------------------------------------- */
  Widget _buildPage8(Size size) {
    final colorName = result['birthColor']?.toString() ?? 'Black/Navy Blue';
    final displayColor =
        AppColors.birthColorMap[colorName] ?? AppColors.navyBlue;

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Recommended",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Mobile Case Color",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            "This is your mobile case color to help bring balance and positivity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.bloodRed),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              colorName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
  
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------------- */
  /*                               PAGE 9                                 */
  /* --------------------------------------------------------------------- */
  Widget _buildPage9(Size size) {
    final dir = result['birthDirection']?.toString() ?? 'East';

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Recommended",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const Text(
            "Charging Station\nVastu",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            "Charge your device here to maintain balanced, positive energy in your home or office",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color: AppColors.bloodRed),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              dir,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
     
         
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------------- */
  /*                               PAGE 10                                */
  /* --------------------------------------------------------------------- */
  Widget _buildPage10(Size size) {
    final dir = result['luckyPhotoDirection']?.toString() ?? 'South East';

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Recommended",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const Text(
            "Lucky Photo\nDirection",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            "This direction is ideal for placing your photo at home or office. It helps your energy stay calm, balanced, and more connected",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color: AppColors.bloodRed),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              dir,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
         
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------------- */
  /*                               PAGE 11                                */
  /* --------------------------------------------------------------------- */
  Widget _buildPage11(Size size) {
    final text = result['luckyWallpaper']?.toString() ?? '';

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Recommended",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const Text(
            "Lucky Wallpaper",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            "Use this wallpaper to bring balanced, positive vibrations into your daily routine",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color: AppColors.bloodRed),
          ),
          const SizedBox(height: 40),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

 

  /* --------------------------------------------------------------------- */
  /*                               PAGE 13 (DYNAMIC)                       */
  /* --------------------------------------------------------------------- */
  Widget _buildPage13(Size size) {
    final gridRaw = result['Grid'] ?? [];
    final grid = gridRaw is List
        ? gridRaw.map((r) => List<Map<String, dynamic>>.from(r)).toList()
        : <List<Map<String, dynamic>>>[];

    // Get missing line message data
    final missingLineMessage = result['missingLineMessage'];
    final pointers = missingLineMessage != null && missingLineMessage['pointers'] is List
        ? List<String>.from(missingLineMessage['pointers'])
        : <String>[];
    final tips = missingLineMessage != null && missingLineMessage['tips'] is List
        ? List<String>.from(missingLineMessage['tips'])
        : <String>[];

    // Check if we have any analysis data to show
    final hasAnalysis = pointers.isNotEmpty || tips.isNotEmpty;

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Numerology",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const Text(
            "Grid",
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // GRID
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 9,
              itemBuilder: (context, i) {
                final row = i ~/ 3;
                final col = i % 3;
                final cell =
                    (grid.isNotEmpty &&
                        row < grid.length &&
                        col < grid[row].length)
                    ? grid[row][col]
                    : {'value': '', 'isMissing': true};
                final val = cell['value']?.toString() ?? '';
                final miss = cell['isMissing'] == true;

                return Container(
                  decoration: BoxDecoration(
                    color: miss
                        ? AppColors.gridMissing
                        : AppColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: miss ? Colors.transparent : AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: miss
                            ? const Color(0xFFA6AEBF)
                            : AppColors.gridPresent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Show analysis only if there's data
          if (hasAnalysis) ...[
            const SizedBox(height: 30),
            const Text(
              "Grid Analysis",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Pointers Section
            if (pointers.isNotEmpty) ...[
              const Text(
                "Pointers:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              ...pointers.map((pointer) => _analysisItem(pointer, size)),
              const SizedBox(height: 16),
            ],

            // Tips Section
            if (tips.isNotEmpty) ...[
              const Text(
                "Tips:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map((tip) => _tipItem(tip, size)),
            ],
          ],

          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget for pointer items (with bullet points)
  Widget _analysisItem(String text, Size size) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: size.width * 0.037,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  // Widget for tip items (with different styling)
  Widget _tipItem(String text, Size size) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: size.width * 0.037,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

 /* --------------------------------------------------------------------- */
  /*                               PAGE 14                                */
  /* --------------------------------------------------------------------- */
  Widget _buildPage14(Size size) {
    final analysis = result['secondNumberAnalysis'] ?? {};
    final digit = analysis['digit']?.toString() ?? '';
    final reason = analysis['reason']?['reason']?.toString() ?? '';
    final phone = result['phone']?.toString() ?? '';

    return _buildSafePage(
      size,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Effect of",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          Text(
            "Second digit",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const Text(
            "Analysis",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            "We showing Second Digit Number Analysis:",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          
          // Phone number with 2nd digit highlighted
          Center(
            child: _buildPhoneNumberWithHighlight(phone, size),
          ),
          
          const SizedBox(height: 24),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 40),
          _swipeLeft(size),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper widget to display phone number with 2nd digit highlighted
  Widget _buildPhoneNumberWithHighlight(String phone, Size size) {
    if (phone.isEmpty) {
      return const Text('No phone number available');
    }

    List<Widget> digitWidgets = [];
    
    for (int i = 0; i < phone.length; i++) {
      if (i == 1) {
        // 2nd digit - highlighted in green circle
        digitWidgets.add(
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                phone[i],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      } else {
        // Other digits - normal display
        digitWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              phone[i],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: digitWidgets,
    );
  }

 /* --------------------------------------------------------------------- */
  /*                               PAGE 15                                */
  /* --------------------------------------------------------------------- */
  Widget _buildPage15(Size size) {
    final pairs = List<Map<String, dynamic>>.from(
      result['categorizedPairs'] ?? [],
    );

    Color catColor(String cat) {
      final c = cat.toLowerCase();
      return c == 'good'
          ? AppColors.primaryGreen
          : c == 'neutral'
          ? AppColors.neutralOrange
          : AppColors.bloodRed;
    }

    // Filter available categories
    final availableCategories = ['good', 'neutral', 'bad'].where((cat) {
      return pairs.any((p) => (p['category']?.toString() ?? '').toLowerCase() == cat);
    }).toList();

    if (availableCategories.isEmpty) {
      return _buildSafePage(size, const Center(child: Text("No pair data available")));
    }

    // Ensure index is valid
    if (_categoryIndex >= availableCategories.length) {
      _categoryIndex = 0;
    }

    final currentCategory = availableCategories[_categoryIndex];
    final categoryItems = pairs
        .where((p) => (p['category']?.toString() ?? '').toLowerCase() == currentCategory)
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mobile",
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            Text(
              "Number Pair",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We showing Mobile Number Pair Analysis:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            
            // Legend
            Row(
              children: [
                _legend("Good", AppColors.primaryGreen),
                _legend("Neutral", AppColors.neutralOrange),
                _legend("Bad", AppColors.bloodRed),
              ],
            ),
            const SizedBox(height: 20),
            
            // Pair chips - 3 per row (using Wrap instead of GridView)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pairs.map((p) {
                final number = p['number']?.toString() ?? '';
                final color = catColor(p['category'] ?? '');
                return Container(
                  width: (size.width - (size.width * 0.12) - 20) / 3, // 3 columns
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Swipe gesture + Next button dono sahi se kaam karenge
GestureDetector(
  onHorizontalDragEnd: (details) {
    if (details.primaryVelocity! < 0) {
      // Swipe Left → Next
      setState(() {
        if (_categoryIndex < availableCategories.length - 1) {
          _categoryIndex++;
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    } else if (details.primaryVelocity! > 0) {
      // Swipe Right → Previous
      setState(() {
        if (_categoryIndex > 0) _categoryIndex--;
      });
    }
  },
  child: _pairSectionSwipeable(
    size,
    currentCategory.toUpperCase(),
    catColor(currentCategory),
    categoryItems,
    _categoryIndex,
    availableCategories.length,
    () {
      // Next arrow button pressed
      setState(() {
        if (_categoryIndex < availableCategories.length - 1) {
          _categoryIndex++;
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    },
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildPairGrid(List<Map<String, dynamic>> pairs, Color Function(String) catColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: pairs.length,
      itemBuilder: (context, index) {
        final p = pairs[index];
        return _chip(
          p['number']?.toString() ?? '',
          catColor(p['category'] ?? ''),
        );
      },
    );
  }

  Widget _legend(String label, Color color) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 16),
    ],
  );

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  Widget _pairSectionSwipeable(Size size, String title, Color color, List items, int currentIndex, int totalCategories, VoidCallback onNext) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                // Category indicator
                Text(
                  "${currentIndex + 1}/$totalCategories",
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                // Next arrow button
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Swipe hint
            Center(
              child: Text(
                "← Swipe to see other categories →",
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Show all numbers and their reasons in this category
            ...items.expand((p) {
              final number = p['number']?.toString() ?? '';
              final reasonsString = p['reasons']?.toString() ?? '';
              
              // Split reasons by semicolon and filter out empty strings
              final reasonsList = reasonsString
                  .split(';')
                  .map((r) => r.trim())
                  .where((r) => r.isNotEmpty)
                  .toList();

              return [
                // Number header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  // child: Text(
                  //   "Number $number:",
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.bold,
                  //     color: color,
                  //   ),
                  // ),
                ),
                // All reasons for this number
                ...reasonsList.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ];
            }).toList(),
          ],
        ),
      );
Widget _buildPage16(Size size) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Dynamic scaling based on screen width
      double w = constraints.maxWidth;
      double h = constraints.maxHeight;

      double scale = (w / 390).clamp(0.75, 1.2); 
      // 390 = iPhone 12 width → baseline

      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: h,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.05),

                      // ✔ Success Icon (Auto Scales)
                      Container(
                        padding: EdgeInsets.all(w * 0.05 * scale),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withAlpha(30),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 3 * scale,
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: w * 0.22 * scale,
                          color: AppColors.primaryGreen,
                        ),
                      ),

                      SizedBox(height: h * 0.025),

                      // ✔ Title (Auto Scales)
                      Text(
                        "Report Complete",
                        style: TextStyle(
                          fontSize: w * 0.08 * scale,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: h * 0.015),

                      // ✔ Decorative line
                      Container(
                        width: w * 0.2,
                        height: 4 * scale,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.primaryGreen.withAlpha(51),
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withAlpha(51),
                          ]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      // ✔ Premium Card – Fully Responsive
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: h * 0.025,
                          horizontal: w * 0.05,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(240),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: AppColors.primaryGreen.withAlpha(80),
                            width: 2 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withAlpha(50),
                              blurRadius: 20 * scale,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.diamond,
                              color: AppColors.primaryGreen,
                              size: w * 0.09 * scale,
                            ),
                            SizedBox(height: 10),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: w * 0.038 * scale,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "A premium life needs a premium number. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  TextSpan(text: "Discover yours with the "),
                                  TextSpan(
                                    text: "Number Aacharya report",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "—before you purchase your next mobile number.",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ✔ Bottom Buttons (Auto Shrink on Small Devices)
                      Padding(
                        padding: EdgeInsets.only(
                          top: h * 0.02,
                          bottom: 16,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _goToSearch,
                                icon: Icon(Icons.search, size: 20, color: Colors.white),
                                label: Text(
                                  "Search Again",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _goToHome,
                                icon: Icon(Icons.home, size: 20, color: AppColors.primaryGreen),
                                label: Text(
                                  "Exit to Home",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryGreen,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  /* --------------------------------------------------------------------- */
  /*                               HELPERS                                 */
  /* --------------------------------------------------------------------- */
  Widget _swipeLeft(Size size) => Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "swipe left",
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.arrow_forward,
          color: AppColors.primaryGreen,
          size: 18,
        ),
      ],
    ),
  );

 Widget _buildSafePage(Size size, Widget child) {
  return SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, // Slightly smaller padding
            vertical: size.height * 0.02, // Responsive vertical padding
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - (size.height * 0.04),
            ),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    ),
  );
}
}
