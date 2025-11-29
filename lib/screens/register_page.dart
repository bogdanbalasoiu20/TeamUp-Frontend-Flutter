import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/create_match_page.dart';
import 'package:team_up_fe_new/screens/home_page.dart';
import 'package:team_up_fe_new/screens/login_page.dart';
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

  // API CALL
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

      //extrag token-ul din response ca la login
      final token = response["data"]["token"];

      //salvez token-ul sub aceeasi cheie ca în login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token);

      //succes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      //navigare
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CreateMatchPage()),
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




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF003B2F),
                  AppColors.primaryGreenDark,
                  AppColors.primaryGreenLight,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              // image: const DecorationImage(
              //   image: AssetImage("lib/images/football_field.png"),
              //   fit: BoxFit.cover,
              //   opacity: 0.25,
              // ),
            ),
          ),

          // TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 80, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
              ],
            ),
          ),

          // WHITE CONTAINER WITH INPUTS
          Positioned(
            top: size.height * 0.32,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    BehanceUnderlineInput(
                      label: "Email",
                      controller: emailController,
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "Username",
                      controller: usernameController,
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "Password",
                      isPassword: true,
                      controller: passwordController,
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "Phone Number",
                      controller: phoneController,
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "Birthday (yyyy-MM-dd)",
                      controller: birthdayController,
                    ),

                    const SizedBox(height: 20),

                    // POSITION DROPDOWN
                    Text("Position",
                        style: const TextStyle(
                            color: AppColors.primaryGreenLight,
                            fontWeight: FontWeight.w700)),

                    DropdownButton<String>(
                      value: selectedPosition,
                      isExpanded: true,
                      items: [
                        "GOALKEEPER", "DEFENDER", "MIDFIELDER", "FORWARD"
                      ].map((e) =>
                          DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState((){ selectedPosition = v; }),
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "City",
                      controller: cityController,
                    ),

                    const SizedBox(height: 20),

                    BehanceUnderlineInput(
                      label: "Description",
                      controller: descriptionController,
                    ),

                    const SizedBox(height: 40),

                    // REGISTER BUTTON
                    GestureDetector(
                      onTap: _isLoading ? null : register,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF003B2F),
                              AppColors.primaryGreenDark,
                              AppColors.primaryGreenLight,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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

      //FOOTER (Sign up) – ramane fix in partea de jos
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 26, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Do you have account?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_)=>LoginScreen())
                );
              },
              child: const Text(
                "Sign in",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E8B57),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}


// SAME INPUT WIDGET YOU ALREADY HAVE
class BehanceUnderlineInput extends StatefulWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;

  const BehanceUnderlineInput({
    super.key,
    required this.label,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<BehanceUnderlineInput> createState() => _BehanceUnderlineInputState();
}

class _BehanceUnderlineInputState extends State<BehanceUnderlineInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: AppColors.primaryGreenLight,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD3D3D3), width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreenLight, width: 1.4),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
        contentPadding: const EdgeInsets.only(top: 18, bottom: 10),
      ),
    );
  }
}
