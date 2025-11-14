import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_form_screen.dart';
import 'transaction_history_screen.dart';
import 'package:number_aacharya/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      if (!mounted) return;
      setState(() {
        _user = jsonDecode(userStr);
      });
    }
  }

  Future<void> _changePasswordDialog() async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool _obscureOldPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;
    bool _isLoading = false;
    bool hasMinLength = false;
    bool hasUppercase = false;
    bool hasLowercase = false;
    bool hasNumber = false;
    bool hasSpecialChar = false;

    void updatePasswordChecklist(StateSetter setState) {
      final password = newPassController.text;
      setState(() {
        hasMinLength = password.length >= 8;
        hasUppercase = RegExp(r'(?=.*[A-Z])').hasMatch(password);
        hasLowercase = RegExp(r'(?=.*[a-z])').hasMatch(password);
        hasNumber = RegExp(r'(?=.*\d)').hasMatch(password);
        hasSpecialChar =
            RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          Widget buildChecklistItem(bool isFulfilled, String label) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isFulfilled ? Icons.check_circle : Icons.cancel,
                    color: isFulfilled ? const Color(0xFF008000) : Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFulfilled ? const Color(0xFF008000) : Colors.grey[600],
                        fontWeight: isFulfilled ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9,
                maxHeight: screenHeight * 0.8,
              ),
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF008000), Color(0xFF00A000)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_reset, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Old Password
                            TextFormField(
                              controller: oldPassController,
                              obscureText: _obscureOldPassword,
                              decoration: InputDecoration(
                                labelText: "Old Password",
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF008000), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF008000)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      _obscureOldPassword = !_obscureOldPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your old password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // New Password
                            TextFormField(
                              controller: newPassController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: "New Password",
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF008000), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF008000)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      _obscureNewPassword = !_obscureNewPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                updatePasswordChecklist(setDialogState);
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password checklist
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Password must contain:",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  buildChecklistItem(hasMinLength, 'At least 8 characters'),
                                  buildChecklistItem(hasUppercase, 'One uppercase letter (A-Z)'),
                                  buildChecklistItem(hasLowercase, 'One lowercase letter (a-z)'),
                                  buildChecklistItem(hasNumber, 'One number (0-9)'),
                                  buildChecklistItem(hasSpecialChar, 'One special character (!@#\$%^&*)'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            TextFormField(
                              controller: confirmPassController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: "Confirm New Password",
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF008000), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF008000)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                if (value != newPassController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
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
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;

                                    setDialogState(() => _isLoading = true);

                                    if (_user == null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("User not logged in")),
                                        );
                                      }
                                      setDialogState(() => _isLoading = false);
                                      return;
                                    }

                                    final prefs = await SharedPreferences.getInstance();
                                    final systemUserId = prefs.getString('system_user_id');

                                    if (systemUserId == null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("User not logged in")),
                                        );
                                      }
                                      setDialogState(() => _isLoading = false);
                                      return;
                                    }

                                    try {
                                      final response = await ApiService.changePassword(
                                        systemUserId,
                                        oldPassController.text.trim(),
                                        newPassController.text.trim(),
                                      );

                                      if (response.containsKey('data') &&
                                          response['data'] is List &&
                                          response['data'].isNotEmpty) {
                                        final message = response['data'][0]['message']?.toString() ?? '';
                                        if (message.toLowerCase().contains('success')) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Successfully updated the password"),
                                                backgroundColor: Color(0xFF008000),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(message.isNotEmpty ? message : "Password change failed"),
                                                backgroundColor: const Color(0xFFC1121F),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Password change failed"),
                                              backgroundColor: Color(0xFFC1121F),
                                            ),
                                          );
                                        }
                                      }

                                      if (mounted) Navigator.pop(dialogContext);
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Error changing password. Try again."),
                                            backgroundColor: Color(0xFFC1121F),
                                          ),
                                        );
                                        Navigator.pop(dialogContext);
                                      }
                                    } finally {
                                      setDialogState(() => _isLoading = false);
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        if (mounted) {
                                          oldPassController.dispose();
                                          newPassController.dispose();
                                          confirmPassController.dispose();
                                        }
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Change Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
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
      body: _user == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008000)),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Custom App Bar with Gradient
                SliverAppBar(
                  expandedHeight: screenHeight * 0.25,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF008000),
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF008000), Color(0xFF00A000)],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: screenWidth * 0.12,
                                backgroundColor: Colors.white,
                                child: Text(
                                  (_user?['name'] ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF008000),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              _user?['name'] ?? "No Name",
                              style: const TextStyle(
                                fontSize: 24,
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

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),

                        // Profile Info Cards
                        _buildModernInfoCard(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: _user?['email_id'] ?? "N/A",
                          color: const Color(0xFF008000),
                        ),
                        const SizedBox(height: 12),

                        _buildModernInfoCard(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          value: "${_user?['country_code'] ?? ''} ${_user?['mobile_no'] ?? ''}",
                          color: const Color(0xFF008000),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Transaction History Button
                        _buildActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(),
                              ),
                            );
                          },
                          icon: Icons.history,
                          label: "Transaction History",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF008000), Color(0xFF00A000)],
                          ),
                          iconColor: Colors.white,
                        ),

                        const SizedBox(height: 12),

                        // Change Password Button
                        _buildActionButton(
                          onPressed: _changePasswordDialog,
                          icon: Icons.lock_reset,
                          label: "Change Password",
                          gradient: LinearGradient(
                            colors: [Colors.grey[100]!, Colors.grey[200]!],
                          ),
                          textColor: const Color(0xFF1A1A1A),
                          iconColor: const Color(0xFF008000),
                        ),

                        const SizedBox(height: 12),

                        // Logout Button
                        _buildActionButton(
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFC1121F),
                                    ),
                                  );
                                },
                              );

                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              await ApiService.clearStoredData();

                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginFormScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error during logout. Please try again."),
                                    backgroundColor: Color(0xFFC1121F),
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icons.logout,
                          label: "Logout",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC1121F), Color(0xFFE03B3B)],
                          ),
                          iconColor: Colors.white,
                        ),

                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Gradient gradient,
    Color textColor = Colors.white,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}