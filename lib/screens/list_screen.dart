import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/pdf_viewer_screen.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      await _fetchInquiries(); // fetch only after userId is ready
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
      print("GetInquiries API response: $response"); // Debugging log
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
      print('Inquiries error: $e');
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

void _viewPdf(String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewerScreen(url: url),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: const Color(0xFFD9F2D9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  "List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "View the Report",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // List of inquiries
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4BAF8D)))
                : _inquiries.isEmpty
                    ? const Center(child: Text('No inquiries available'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _inquiries.length,
                        itemBuilder: (context, index) {
                          final inquiry = _inquiries[index];
                          final dateParts = (inquiry['date_of_birth'] ?? '02/05/1998').split('/');
                          final day = dateParts[0];
                          final month = dateParts[1];
                          final year = dateParts[2];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Date
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9F2D9),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                    width: 70,
                                    height: 70,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text(month, style: const TextStyle(fontSize: 12)),
                                        Text(year, style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Name & Phone Number
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${inquiry['first_name'] ?? 'Unknown'} ${inquiry['last_name'] ?? ''}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(inquiry['phone_number'] ?? 'N/A',
                                              style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Download icon
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9F2D9),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: IconButton(
                                      icon: const Icon(Icons.download, size: 18),
                                      onPressed: () => _viewPdf(inquiry['report_file'] ?? ''),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
