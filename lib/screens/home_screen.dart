import 'package:flutter/material.dart';
import 'package:number_aacharya/screens/pdf_viewer_screen.dart';
import 'package:number_aacharya/services/api_service.dart';
import 'list_screen.dart';
import 'credits_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const ListScreen(),
    const SearchScreen(),
    const CreditsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index != 0) {
      final screen = _screens[index];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4BAF8D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.folder), label: "List"),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Joyent.png',
              height: 24,
              width: 24,
            ),
            label: "Search",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Credits"),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Profile"),
        ],
      ),
    );
  }
}

// HomeDashboard UI with API data and updated greeting
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = false;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchInquiries();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final storedId = await ApiService.getStoredSystemUserId();
      if (storedId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        return;
      }

      // You can also fetch full profile if API available,
      // for now just set a placeholder
      if (mounted) {
        setState(() {
          _firstName = "Rushi"; // TODO: Replace with real API if needed
        });
      }
    } catch (e) {
      print("User details error: $e");
    }
  }

  Future<void> _fetchInquiries() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getInquiries();
      print('Home inquiries response: $response');

      if (response.containsKey('data') && response['data'] is List) {
        setState(() {
          _inquiries = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No inquiries found')),
          );
        }
      }
    } catch (e) {
      print("Inquiries error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch inquiries')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/profile.jpg'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${_firstName ?? 'Guest'} 👋',
                            style: const TextStyle(
                              color: Color(0xFF4BAF8D),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const Text("Welcome Back",
                              style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    color: const Color(0xFF4BAF8D),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Search Bar
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search anything",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Credit Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD9F2C8), Color(0xFFA6DFA1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Your Credit",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "4/10",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Buy Credits",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              // Dashboard title
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF4BAF8D)))
              else if (_inquiries.isEmpty)
                const Center(child: Text('No inquiries available'))
              else
                Column(
                  children: _inquiries.map((inquiry) {
                    final dateParts = (inquiry['date_of_birth'] ?? '02/05/1998').split('/');
                    final day = dateParts[0];
                    final month = dateParts[1];
                    final year = dateParts[2];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Date box
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7E3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(day,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(month, style: const TextStyle(fontSize: 12)),
                                  Text(year, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name & Phone
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${inquiry['first_name'] ?? ''} ${inquiry['last_name'] ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    inquiry['phone_number'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Download
                            IconButton(
                              onPressed: () => _viewPdf(inquiry['report_file'] ?? ''),
                              icon: const Icon(Icons.download, color: Color(0xFF4BAF8D)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
