import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/view_report_screen.dart';
import 'package:number_aacharya/screens/pdf_viewer_screen.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'credits_screen.dart';
import 'search_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = false;
  String? _systemUserId;

  @override
  void initState() {
    super.initState();
    _fetchSystemUserIdAndInquiries();
  }

  Future<void> _fetchSystemUserIdAndInquiries() async {
    const storage = FlutterSecureStorage();
    final systemUserId = await storage.read(key: 'system_user_id');
    if (systemUserId != null) {
      setState(() {
        _systemUserId = systemUserId;
      });
      await _fetchInquiries();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    }
  }

  Future<void> _fetchInquiries() async {
    if (_isLoading || _systemUserId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getInquiries(_systemUserId!);
      if (response.containsKey('data') && response['data'] is List) {
        setState(() => _inquiries = List<Map<String, dynamic>>.from(response['data']));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No inquiries found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Internet connection issue. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _viewReport(Map<String, dynamic> inquiry) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReportScreen(reportData: inquiry),
      ),
    );
  }

  void _downloadReport(String url) {
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerScreen(url: url)),
    );
  }

  Future<String> _getLatestCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_credits") ?? "0";
  }

  void _checkDifferentNumber(Map<String, dynamic> inquiry) async {
    final credits = await _getLatestCredits();
    if (credits == "0") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreditsScreen()),
      );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF2D3748), size: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          "All Reports",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF008000), // GREEN
              ),
            )
          : _inquiries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No reports available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _inquiries.length,
                  itemBuilder: (context, index) {
                    final inquiry = _inquiries[index];
                    final dateParts = (inquiry['date_of_birth'] ?? '02/05/1998').split('/');
                    final day = dateParts.isNotEmpty ? dateParts[0] : '02';
                    final month = dateParts.length > 1 ? dateParts[1] : '05';
                    final year = dateParts.length > 2 ? dateParts[2] : '1998';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF8FCFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF008000).withOpacity(0.08), // GREEN shadow
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
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
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // DATE BADGE – SOLID GREEN
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF008000), // SOLID GREEN
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF008000).withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            day,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 24,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$month/$year',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withOpacity(0.9),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // NAME & PHONE
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${inquiry['first_name'] ?? ''} ${inquiry['last_name'] ?? ''}'.trim(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                              color: Color(0xFF1A202C),
                                              letterSpacing: -0.3,
                                            ),
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
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF008000),
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                                        // VIEW BUTTON – GREEN
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
                                                  border: Border.all(
                                                    color: const Color(0xFF008000).withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/view.jpg',
                                                      height: 18,
                                                      width: 18,
                                                      color: const Color(0xFF008000),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      "View",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF008000),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // PDF BUTTON – RED #C1121F
                                        Expanded(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => _downloadReport(inquiry['report_file']?.toString() ?? ''),
                                              borderRadius: BorderRadius.circular(14),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFC1121F).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: const Color(0xFFC1121F).withOpacity(0.2),
                                                    width: 1,
                                                  ),
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

                                    // CHECK DIFFERENT NUMBER – GREEN
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => _checkDifferentNumber(inquiry),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF008000),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.refresh_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              "Check Different Number",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
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
                  },
                ),
    );
  }
}