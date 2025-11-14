import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF008000);
  static const Color dangerRed = Color(0xFFE14B4B);
  static const Color lightGray = Color(0xFF9E9E9E);
}

class Page1MainDetail extends StatelessWidget {
  final Map<String, dynamic> reportData;
  const Page1MainDetail({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),

          // Illustration
          Image.asset(
            "assets/images/report_screen.png",
            height: size.height * 0.22,
            fit: BoxFit.contain,
          ),
          SizedBox(height: size.height * 0.03),

          // Title
          Text(
            "Number Aacharya",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size.width * 0.08,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          Text(
            "Personal Numerology summary",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size.width * 0.04,
              color: AppColors.lightGray,
            ),
          ),
          SizedBox(height: size.height * 0.04),

          // User Details Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Text(
                  "You Entered Details",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.038,
                    color: AppColors.lightGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // First / Last name arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _arrowLabel(size, "First name", true),
                    SizedBox(width: size.width * 0.15),
                    _arrowLabel(size, "Last name", false),
                  ],
                ),
                SizedBox(height: size.height * 0.01),

                // Full name
                Text(
                  "${reportData['first_name']?.toString().toUpperCase() ?? ''} ${reportData['last_name']?.toString().toUpperCase() ?? ''}",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.03),

                // DOB
                _arrowLabel(size, "Date of birth", true),
                SizedBox(height: size.height * 0.01),
                Text(
                  reportData['date_of_birth']?.toString() ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: size.height * 0.03),

                // Phone
                _arrowLabel(size, "Phone Number", false),
                SizedBox(height: size.height * 0.01),
                Text(
                  "+${reportData['country_code']} ${reportData['phone_number']}",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.03),

          // Check Report Button
          ElevatedButton(
            onPressed: () {
              // TODO: API call or navigation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.15,
                vertical: size.height * 0.018,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "Check Report",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.045,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Footer
          Text(
            "Powered By",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size.width * 0.035,
              color: AppColors.lightGray,
            ),
          ),
          Text(
            "ARUN MUCHHALA INTERNATIONAL GROUP",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size.width * 0.03,
              color: AppColors.dangerRed,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),

          // Swipe hint
          Text(
            "swipe left >",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.primaryGreen,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  Widget _arrowLabel(Size size, String text, bool left) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (left)
          Icon(Icons.arrow_downward, size: 16, color: AppColors.primaryGreen),
        if (!left) const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size.width * 0.03,
            color: AppColors.lightGray,
          ),
        ),
        if (!left)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_downward, size: 16, color: AppColors.primaryGreen),
          ),
      ],
    );
  }
}