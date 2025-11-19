import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login-form');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView Section
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildIntroPage(
                  title: "EVERY NUMBER CARRIES\nA VIBRATION.",
                  image: 'assets/images/intro1.png',
                  description:
                      "Your Mobile Number Is More Than Digits\n— It Carries An Energy That Interacts\nWith Your Daily Life.",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
                _buildIntroPage(
                  title: "A MISALIGNED NUMBER CAN\nCREATE HIDDEN OBSTACLES.",
                  image: 'assets/images/intro2.png',
                  description:
                      "Stress, Delays, Struggles — Sometimes\nThe Source Is Your Number's Energy,\nNot Your Effort.",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
                _buildIntroPage(
                  title: "USE A NUMBER THAT ALIGNS\nWITH YOUR DESTINY",
                  image: 'assets/images/intro3.png',
                  description:
                      "Number Aacharya Helps You Decode\nYour Number's Vibration And Reveals\nWhether It Supports Or Blocks Your\nPath.",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
                _buildLastPage(
                  title: "CHECK YOUR NUMBER.\nCHANGE YOUR ENERGY.",
                  bgImage: 'assets/images/intro4.png',
                  description:
                      "Get Your Personalised Mobile Number Report Instantly — See Whether Your Number Is Lucky For You Or Not.",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
              ],
            ),

            // Bottom Section with indicators and buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Skip/Next and Arrow Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip/Next Text Button
                        if (_currentPage < 3)
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signup');
                            },
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60),

                        // Indicator Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index
                                    ? const Color(0xFF008000)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),

                        // Arrow Button - Hide on last page
                        if (_currentPage < 3)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF008000),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF008000).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _nextPage,
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 50),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // "I ALREADY HAVE AN ACCOUNT" or "GET STARTED" Button
                    if (_currentPage == 3)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008000),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'GET STARTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                        ],
                      ),

                    // "I ALREADY HAVE AN ACCOUNT" Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login-form');
                      },
                      child: Text(
                        'I ALREADY HAVE AN ACCOUNT',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage({
    required String title,
    required String image,
    required String description,
    required double screenHeight,
    required double screenWidth,
  }) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.08),

           

            // Image with animation
            Image.asset(
              image,
              width: screenWidth * 0.65,
              height: screenHeight * 0.35,
              fit: BoxFit.contain,
            ),

            SizedBox(height: screenHeight * 0.04),
             // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: screenHeight * 0.06),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPage({
    required String title,
    required String bgImage,
    required String description,
    required double screenHeight,
    required double screenWidth,
  }) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.15),

              // Title at top
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Description at bottom
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              SizedBox(height: screenHeight * 0.2),
            ],
          ),
        ),
      ),
    );
  }
}