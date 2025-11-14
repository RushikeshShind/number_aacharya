import 'package:flutter/material.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'package:number_aacharya/screens/list_screen.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalCredits = 0;
  int _totalDebits = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await ApiService.getUserTransactionHistory();
      
      if (response.containsKey('data') && response['data'] is List) {
        final transactions = List<Map<String, dynamic>>.from(response['data']);
        
        int credits = 0;
        int debits = 0;
        
        for (var transaction in transactions) {
          final amount = int.tryParse(transaction['no_of_credits_debits'].toString()) ?? 0;
          if (transaction['transaction_type'].toString().toUpperCase() == 'CREDIT') {
            credits += amount;
          } else {
            debits += amount;
          }
        }
        
        if (mounted) {
          setState(() {
            _transactions = transactions.reversed.toList();
            _totalCredits = credits;
            _totalDebits = debits;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No transaction history found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transaction history. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return DateFormat('dd MMM yyyy').format(date);
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatsCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
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
          // Current Balance Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${_totalCredits - _totalDebits}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Credits and Debits Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Credits',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalCredits',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Debits',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalDebits',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCredit = transaction['transaction_type'].toString().toUpperCase() == 'CREDIT';
    final amount = int.tryParse(transaction['no_of_credits_debits'].toString()) ?? 0;
    final date = transaction['transaction_date']?.toString() ?? '';

    final cardContent = Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        bottom: 12,
        top: index == 0 ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isCredit 
              ? const Color(0xFF008000).withOpacity(0.2) 
              : const Color(0xFFC1121F).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.13,
              height: screenWidth * 0.13,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCredit 
                      ? [const Color(0xFF008000).withOpacity(0.15), const Color(0xFF00A000).withOpacity(0.15)]
                      : [const Color(0xFFC1121F).withOpacity(0.15), const Color(0xFFE03B3B).withOpacity(0.15)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isCredit ? const Color(0xFF008000) : const Color(0xFFC1121F),
                size: 28,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCredit ? 'Credit Added' : 'Credit Used',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCredit 
                          ? [const Color(0xFF008000).withOpacity(0.1), const Color(0xFF00A000).withOpacity(0.1)]
                          : [const Color(0xFFC1121F).withOpacity(0.1), const Color(0xFFE03B3B).withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isCredit ? '+' : '-'}$amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCredit ? const Color(0xFF008000) : const Color(0xFFC1121F),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (!isCredit) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );

    if (!isCredit) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListScreen()),
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 16,
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
                  const Expanded(
                    child: Text(
                      "Transaction History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF008000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF008000)),
                      onPressed: _loadTransactionHistory,
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
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC1121F).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Color(0xFFC1121F),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF008000), Color(0xFF00A000)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF008000).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _loadTransactionHistory,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No transactions found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your transaction history will appear here',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                _buildStatsCard(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF008000),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Recent Transactions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _transactions.length,
                                    itemBuilder: (context, index) {
                                      return _buildTransactionCard(_transactions[index], index);
                                    },
                                  ),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}