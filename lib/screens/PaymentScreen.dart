import 'package:flutter/material.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'dart:math' as math;

class PaymentScreen extends StatefulWidget {
  final String creditsId;
  final String noOfCredits;
  final String amount;

  const PaymentScreen({
    super.key,
    required this.creditsId,
    required this.noOfCredits,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  bool _isPaying = false;
  int _selectedMethod = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'UPI',
      'icon': Icons.account_balance,
      'color': Color(0xFF008000),
      'image': 'assets/icons/upi.png'
    },
    {
      'name': 'Card',
      'icon': Icons.credit_card,
      'color': Color(0xFF0066CC),
      'image': 'assets/icons/card.png'
    },
    {
      'name': 'Net Banking',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFFFF6B00),
      'image': 'assets/icons/netbanking.png'
    },
    {
      'name': 'Wallet',
      'icon': Icons.wallet,
      'color': Color(0xFF9C27B0),
      'image': 'assets/icons/wallet.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isPaying = true);

    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentProcessingDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 2000));

    final res = await ApiService.addUserCredits(
      creditsId: widget.creditsId,
      totalAmount: widget.amount,
    );

    setState(() => _isPaying = false);

    if (!mounted) return;

    Navigator.pop(context);

    if (res["success"] == false) {
      _showResultDialog(
        isSuccess: false,
        message: res["message"] ?? "Something went wrong.",
      );
    } else {
      _showResultDialog(
        isSuccess: true,
        message: "You purchased ${widget.noOfCredits} credits for ₹${widget.amount}.",
      );
    }
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentResultDialog(
        isSuccess: isSuccess,
        message: message,
        onClose: () {
          Navigator.pop(context);
          if (isSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
      ),
    );
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
                    "Payment",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF008000),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, size: 14, color: Color(0xFF008000)),
                        SizedBox(width: 4),
                        Text(
                          "Secure",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF008000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Card
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Order Summary",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${widget.noOfCredits} Credits",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.06,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    const Text(
                                      "Credit Pack",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.stars_rounded,
                                    color: Colors.white,
                                    size: screenWidth * 0.08,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.025),
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            SizedBox(height: screenHeight * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "₹${widget.amount}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.085,
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

                      // Payment Method Section
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
                            "Select Payment Method",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Payment Methods Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: screenWidth * 0.04,
                          mainAxisSpacing: screenHeight * 0.015,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final isSelected = _selectedMethod == index;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedMethod = index),
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
                                      : Colors.grey[300]!,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenWidth * 0.12,
                                    height: screenWidth * 0.12,
                                    padding: EdgeInsets.all(screenWidth * 0.025),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF008000).withOpacity(0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(
                                      method['image'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          method['icon'],
                                          color: method['color'],
                                          size: screenWidth * 0.06,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Text(
                                    method['name'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Security Info
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: const Color(0xFF008000).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.verified_user,
                                color: const Color(0xFF008000),
                                size: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                "Your payment is secured with 256-bit SSL encryption",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: screenWidth - (horizontalPadding * 2),
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF008000), Color(0xFF00A000)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF008000).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isPaying ? null : _processPayment,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isPaying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Payment Processing Dialog
class _PaymentProcessingDialog extends StatefulWidget {
  @override
  State<_PaymentProcessingDialog> createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.08),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF008000), Color(0xFF00A000)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sync, color: Colors.white, size: screenWidth * 0.08),
                  ),
                );
              },
            ),
            SizedBox(height: screenWidth * 0.06),
            const Text(
              "Processing Payment",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              "Please wait...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Result Dialog
class _PaymentResultDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onClose;

  const _PaymentResultDialog({
    required this.isSuccess,
    required this.message,
    required this.onClose,
  });

  @override
  State<_PaymentResultDialog> createState() => _PaymentResultDialogState();
}

class _PaymentResultDialogState extends State<_PaymentResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.08),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isSuccess
                        ? [const Color(0xFF008000), const Color(0xFF00A000)]
                        : [const Color(0xFFC1121F), const Color(0xFFE03B3B)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isSuccess ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: screenWidth * 0.12,
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              Text(
                widget.isSuccess ? "Payment Successful!" : "Payment Failed",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isSuccess
                            ? [const Color(0xFF008000), const Color(0xFF00A000)]
                            : [const Color(0xFFC1121F), const Color(0xFFE03B3B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text(
                        "Okay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
}