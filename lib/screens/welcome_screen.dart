import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700; // small phones like 5”, 5.5"

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // TOP SPACING
                SizedBox(height: constraints.maxHeight * 0.03),

                // LOGO
                Image.asset(
                  'assets/images/AMIG.png',
                  width: constraints.maxWidth * 0.42,
                  height: constraints.maxWidth * 0.42,
                  fit: BoxFit.contain,
                ),

                // TEXT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Welcome to the world of\nnumbers and energy!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmall ? 22 : 26,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                // IMAGE (YANTRA / REPORT)
                Flexible(
                  flex: isSmall ? 3 : 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/report.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // DEVELOPED BY
                Column(
                  children: [
                    Text(
                      'Developed By',
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AMSUN UNIVERSE LLP',
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 18,
                        color: Color(0xFFFF0000),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // GET STARTED Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: constraints.maxWidth * 0.75,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00A651),
                          Color(0xFF008000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF008000).withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/intro');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'GET STARTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
