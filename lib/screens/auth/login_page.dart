import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/matches/create_match_page.dart';
import 'package:team_up_fe_new/screens/map/match_map_page.dart';
import 'package:team_up_fe_new/screens/auth/register_page.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/widgets/navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/api/auth/login", {
        "emailOrUsername": email,
        "password": password,
      });

      print("### LOGIN RAW RESPONSE = $response");

      final token = response["data"]["token"];
      final username = response["data"]["userDto"]["username"];
      final userId = response["data"]["userDto"]["id"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token);
      await prefs.setString("username", username);
      await prefs.setString("user_id", userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );

      print("####USERNAME: "+ username);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()));
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


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT PREMIUM
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

          // TITLU
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 90, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        blurRadius: 14,
                        color: Colors.black54,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // WHITE SHEET
          Positioned(
            top: size.height * 0.32,
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
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -3),
                  ),
                ],
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    // INPUT CARD: EMAIL
                    _inputCard(
                      label: "Username or Email",
                      controller: emailController,
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 24),

                    // INPUT CARD: PASSWORD
                    _passwordCard(
                      label: "Password",
                      controller: passwordController,
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0A6F4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // BUTTON LOGIN
                    GestureDetector(
                      onTap: _isLoading ? null : login,
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
                              color: Colors.greenAccent.withOpacity(0.4),
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "SIGN IN",
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

      // FOOTER
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 26, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Don't have an account?",
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
                    MaterialPageRoute(builder: (_) => const RegisterScreen())
                );
              },
              child: const Text(
                "Sign up",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0A6F4A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------
  // BEAUTIFUL INPUT CARDS
  // --------------------

  Widget _inputCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 8),

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

  Widget _passwordCard({
    required String label,
    required TextEditingController controller,
  }) {
    return PasswordInputCard(
      label: label,
      controller: controller,
    );
  }
}

// --------------------
// CUSTOM PASSWORD FIELD
// --------------------
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 8),

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
                  color: Colors.grey.shade600,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
