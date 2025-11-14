import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // "Powered By" text with circle
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // AMIG Logo
                      Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: Image.asset(
                          'assets/images/AMIG.png',
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                        ),
                      ),
                      // "Powered By" text with green circle background
                      // Positioned(
                      //   top: 0,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 24,
                      //       vertical: 6,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.transparent,
                      //       border: Border.all(
                      //         color: const Color(0xFF00FF00),
                      //         width: 3,
                      //       ),
                      //       borderRadius: BorderRadius.circular(30),
                      //     ),
                      //     child: const Text(
                      //       'Powered By',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         color: Colors.black,
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // // ARUN MUCHHALA INTERNATIONAL GROUP text
                  // const Text(
                  //   'ARUN MUCHHALA',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     color: Color(0xFFFF0000),
                  //     fontWeight: FontWeight.bold,
                  //     letterSpacing: 1.5,
                  //   ),
                  // ),
                  // const Text(
                  //   'INTERNATIONAL GROUP',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     color: Color(0xFFFF0000),
                  //     fontWeight: FontWeight.bold,
                  //     letterSpacing: 1.5,
                  //   ),
                  // ),
                  
                
                  // WELCOME TO text
                  const Text(
                    'Welcome to the world of numbers and energy!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      fontFamily: 'poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Yantra design with Number Aacharya text
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Yantra background
                      Image.asset(
                        'assets/images/report.png',
                        width: size.width * 0.85,
                      ),
                      // Number Aacharya text overlay
                      // Positioned(
                      //   child: Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Text(
                      //         'Number',
                      //         style: TextStyle(
                      //           fontSize: 42,
                      //           color: const Color(0xFF006400),
                      //           fontWeight: FontWeight.w600,
                      //           fontStyle: FontStyle.italic,
                      //           shadows: [
                      //             Shadow(
                      //               offset: const Offset(2, 2),
                      //               blurRadius: 3,
                      //               color: Colors.black.withOpacity(0.2),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Text(
                      //         'Aacharya',
                      //         style: TextStyle(
                      //           fontSize: 42,
                      //           color: const Color(0xFF006400),
                      //           fontWeight: FontWeight.w600,
                      //           fontStyle: FontStyle.italic,
                      //           shadows: [
                      //             Shadow(
                      //               offset: const Offset(2, 2),
                      //               blurRadius: 3,
                      //               color: Colors.black.withOpacity(0.2),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Developed By text
                  const Text(
                    'Developed By:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // AMSUN UNIVERSE LLP text
                  const Text(
                    'AMSUN UNIVERSE LLP',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFFF0000),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Get Started button
                  SizedBox(
                    width: size.width * 0.7,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/intro');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}