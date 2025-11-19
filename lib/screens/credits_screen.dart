import 'package:flutter/material.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'PaymentScreen.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  int _currentCredits = 0;
  List<Map<String, dynamic>> _creditPacks = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedPack;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _fetchCredits();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchCredits() async {
    setState(() => _isLoading = true);

    try {
      final userRes = await ApiService.getUserCredits();
      if (userRes["data"] != null && userRes["data"].isNotEmpty) {
        setState(() {
          _currentCredits = userRes["data"][0]["credit_balance"] ?? 0;
        });
      }

      final masterRes = await ApiService.getCreditsMaster();
      if (masterRes["data"] != null) {
        setState(() {
          _creditPacks = List<Map<String, dynamic>>.from(masterRes["data"] as List);
        });
      }
      _animController.forward();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectPack(Map<String, dynamic> pack) {
    setState(() {
      _selectedPack = pack;
    });
  }

  Future<void> _goToPayment() async {
    if (_selectedPack == null) return;

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PaymentScreen(
          creditsId: _selectedPack!['credits_id'].toString(),
          noOfCredits: _selectedPack!['no_of_credits'].toString(),
          amount: _selectedPack!['amount'].toString(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (result == true) {
      _fetchCredits();
    }
  }

  IconData _getCreditIcon(int credits) {
    switch (credits) {
      case 1: return Icons.stars_rounded;
      case 5: return Icons.star_purple500_rounded;
      case 10: return Icons.emoji_events_rounded;
      case 30: return Icons.workspace_premium_rounded;
      case 50: return Icons.military_tech_rounded;
      default: return Icons.monetization_on_rounded;
    }
  }

  Color _getIconColor(int credits) {
    switch (credits) {
      case 1: return const Color(0xFFFFB300);
      case 5: return const Color(0xFFFF6F00);
      case 10: return const Color(0xFFE91E63);
      case 30: return const Color(0xFF9C27B0);
      case 50: return const Color(0xFF3F51B5);
      default: return const Color(0xFF008000);
    }
  }

  int _calculateDiscount(int original, int current) {
    if (original <= 0) return 0;
    return ((original - current) * 100 / original).round();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  const Text(
                    "Credits",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF008000),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008000)),
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Credits Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.06),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF008000), Color(0xFF00A000)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF008000).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Available Credits",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/maincredit.png",
                                        width: screenWidth * 0.08,
                                        height: screenWidth * 0.08,
                                      ),
                                      SizedBox(width: screenWidth * 0.03),
                                      Text(
                                        "$_currentCredits",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Buy Credits Title
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF008000),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Buy Credits",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Credit Packs
                            ...List.generate(_creditPacks.length, (index) {
                              final pack = _creditPacks[index];
                              final isSelected = _selectedPack != null &&
                                  _selectedPack!['credits_id'] == pack['credits_id'];
                              final discount = _calculateDiscount(
                                pack['original_amount'] ?? 0,
                                pack['amount'] ?? 0,
                              );

                              return Padding(
                                padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                                child: GestureDetector(
                                  onTap: () => _selectPack(pack),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: EdgeInsets.all(screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF008000)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(0xFF008000).withOpacity(0.15)
                                              : Colors.black.withOpacity(0.05),
                                          blurRadius: isSelected ? 12 : 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.15,
                                          height: screenWidth * 0.15,
                                          padding: EdgeInsets.all(screenWidth * 0.025),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? _getIconColor(pack['no_of_credits']).withOpacity(0.15)
                                                : _getIconColor(pack['no_of_credits']).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getCreditIcon(pack['no_of_credits']),
                                            size: screenWidth * 0.08,
                                            color: _getIconColor(pack['no_of_credits']),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.04),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${pack['no_of_credits']} Credits",
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              SizedBox(height: screenHeight * 0.005),
                                              Text(
                                                pack['description'] ?? "Perfect for regular use",
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.032,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if (discount > 0) ...[
                                              Text(
                                                "₹${pack['original_amount']}",
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.grey[400],
                                                  decoration: TextDecoration.lineThrough,
                                                  decorationColor: Colors.grey[400],
                                                  decorationThickness: 2,
                                                ),
                                              ),
                                              SizedBox(height: screenHeight * 0.003),
                                            ],
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "₹${pack['amount']}",
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.05,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF008000),
                                                  ),
                                                ),
                                                if (discount > 0) ...[
                                                  SizedBox(width: screenWidth * 0.02),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFF5252),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      "$discount% OFF",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (isSelected)
                                              Container(
                                                margin: const EdgeInsets.only(top: 6),
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF008000),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),

                            SizedBox(height: screenHeight * 0.12),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : Container(
              width: screenWidth - (horizontalPadding * 2),
              height: 56,
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                gradient: _selectedPack != null
                    ? const LinearGradient(
                        colors: [Color(0xFF008000), Color(0xFF00A000)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey[300]!, Colors.grey[400]!],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedPack != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFF008000).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectedPack != null ? _goToPayment : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      _selectedPack != null ? "Continue to Payment" : "Select a Credit Pack",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedPack != null ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}