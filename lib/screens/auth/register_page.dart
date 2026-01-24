import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/matches/create_match_page.dart';
import 'package:team_up_fe_new/screens/auth/login_page.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedPosition;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  Future<void> register() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/api/auth/register", {
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        "birthday": birthdayController.text.trim(),
        "position": selectedPosition,
        "city": cityController.text.trim(),
        "description": descriptionController.text.trim(),
      });

      final token = response["data"]["token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateMatchPage()),
      );
    } catch (e) {
      if (e is ApiException) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Unexpected error")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A6F4A).withOpacity(0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentGreen.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join the ultimate football community.",
                    style: TextStyle(
                      fontSize: 16,
                      color: _textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader("Credentials"),
                  _buildModernInput(emailController, "Email Address", Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildModernInput(usernameController, "Username", Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildModernInput(
                      passwordController,
                      "Password",
                      Icons.lock_outline,
                      isPassword: true
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader("Player Profile"),

                  // POSITION DROPDOWN
                  _buildModernDropdown(),

                  const SizedBox(height: 16),
                  _buildModernInput(birthdayController, "Birthday (yyyy-MM-dd)", Icons.calendar_today_outlined),
                  const SizedBox(height: 16),
                  _buildModernInput(phoneController, "Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildModernInput(cityController, "City", Icons.location_city_outlined),
                  const SizedBox(height: 16),
                  _buildModernInput(
                      descriptionController,
                      "Short Bio / Description",
                      Icons.description_outlined,
                      maxLines: 3
                  ),

                  const SizedBox(height: 40),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentGreen,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: _cardSurface,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                          : const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FOOTER
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: _textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: _accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildModernInput(
      TextEditingController controller,
      String hint,
      IconData icon,
      {
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }
      ) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
            child: Icon(icon, color: _accentGreen.withOpacity(0.8), size: 22),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: _textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPosition,
          hint: Text(
            "Preferred Position",
            style: TextStyle(color: _textSecondary.withOpacity(0.7)),
          ),
          isExpanded: true,
          dropdownColor: _cardSurface, // Matches the dark card color
          icon: Icon(Icons.arrow_drop_down, color: _accentGreen),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: ["GOALKEEPER", "DEFENDER", "MIDFIELDER", "FORWARD"]
              .map((e) => DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                Icon(Icons.sports_soccer, size: 18, color: _accentGreen.withOpacity(0.7)),
                const SizedBox(width: 12),
                Text(e),
              ],
            ),
          ))
              .toList(),
          onChanged: (v) => setState(() => selectedPosition = v),
        ),
      ),
    );
  }
}