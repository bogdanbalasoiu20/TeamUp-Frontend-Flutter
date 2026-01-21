import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/matches/create_match_page.dart';
import 'package:team_up_fe_new/screens/auth/login_page.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedPosition;

  bool _isLoading = false;

  // --------------------------
  // SEND REGISTER REQUEST
  // --------------------------
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
    }

    setState(() => _isLoading = false);
  }

  // --------------------------
  // UI BUILD
  // --------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ------------------ BACKGROUND ------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF003B2F),
                  AppColors.primaryGreenDark,
                  AppColors.primaryGreenLight,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // ------------------ TITLE -----------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 90, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        blurRadius: 14,
                        color: Colors.black54,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Join the TeamUp community",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ------------------ WHITE SHEET ------------------
          Positioned(
            top: size.height * 0.30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, -3),
                  ),
                ],
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    // INPUTS (CARD STYLE)
                    _inputCard("Email", emailController, Icons.mail),
                    const SizedBox(height: 20),

                    _inputCard("Username", usernameController, Icons.person),
                    const SizedBox(height: 20),

                    _passwordCard("Password", passwordController),
                    const SizedBox(height: 20),

                    _inputCard("Phone Number", phoneController, Icons.phone),
                    const SizedBox(height: 20),

                    _inputCard("Birthday (yyyy-MM-dd)", birthdayController, Icons.calendar_today),
                    const SizedBox(height: 20),

                    // POSITION DROPDOWN RE-DESIGNED
                    const Text(
                      "Preferred Position",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003B2F),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPosition,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.grey.shade700),
                          items: [
                            "GOALKEEPER",
                            "DEFENDER",
                            "MIDFIELDER",
                            "FORWARD"
                          ].map((e) =>
                              DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => selectedPosition = v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _inputCard("City", cityController, Icons.location_city),
                    const SizedBox(height: 20),

                    _inputCard("Description", descriptionController, Icons.info),
                    const SizedBox(height: 40),

                    // ------------------ REGISTER BUTTON ---------------
                    GestureDetector(
                      onTap: _isLoading ? null : register,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF003B2F),
                              Color(0xFF0A6F4A),
                              Color(0xFF46C264),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              color: Colors.green.withOpacity(0.35),
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ------------------ FOOTER ------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 26, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "Sign in",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0A6F4A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // ⭐️ REUSABLE PREMIUM INPUT CARD
  // -------------------------------------------------------
  Widget _inputCard(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ PASSWORD FIELD ------------------
  Widget _passwordCard(String label, TextEditingController controller) {
    return PasswordInputCard(
      label: label,
      controller: controller,
    );
  }
}

// -------------------------------------------------------
// PASSWORD CARD WIDGET
// -------------------------------------------------------
class PasswordInputCard extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const PasswordInputCard({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<PasswordInputCard> createState() => _PasswordInputCardState();
}

class _PasswordInputCardState extends State<PasswordInputCard> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.lock_outline, color: Colors.grey.shade700),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
