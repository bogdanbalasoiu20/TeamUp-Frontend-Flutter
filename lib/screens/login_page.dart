import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/welcome_page.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Controller-ele pentru input (email si parola)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false; //loading pentru butonul de sign in

  //functia care trimite requestul catre backend
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    //validare simpla pe FE – evita requesturile inutile spre backend
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    //endpoint login
    final url = Uri.parse("https://teamup-backend-omi4.onrender.com/api/auth/login");

    try {
      //Request HTTP catre backend
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emailOrUsername": email,  //trebuie sa fie EXACT ca in DTO din backend
          "password": password,
        }),
      );

      //Dacă login-ul este corect
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data["data"]["token"];  //extragem JWT token

        //salvam token-ul local in telefon
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );

        //navigam spre ecranul principal (temporar WelcomeScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
        );
      } else {
        //eroare venita din backend – afisam mesajul lor
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["message"] ?? "Authentication error")),
        );
      }

    } catch (e) {
      //eroare pe partea de retea / server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size; //afla dimensiunea ecranului

    return Scaffold(
      resizeToAvoidBottomInset: true, //permite ridicarea UI-ului cand apare tastatura

      body: Stack(
        children: [

          //FUNDAL (gradient + imagine)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF003B2F),
                  AppColors.primaryGreenDark,
                  AppColors.primaryGreenLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: const DecorationImage(
                image: AssetImage("lib/images/football_field.png"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
          ),

          //TITLU ("Hello", "Sign in!")
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 80, 28, 0), //spatiere fata de margini
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hello",
                  style: TextStyle(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Sign in!",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),

          //CONTAINERUL ALB (inputuri + buton + forgot password)
          Positioned(
            top: size.height * 0.32, //distanta fata de partea de sus
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

              child: SingleChildScrollView( //permite scroll cand apare tastatura
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    //Camp Username/Email
                    BehanceUnderlineInput(
                      label: "Username/Email",
                      rightIcon: Icons.check,
                      controller: emailController,
                    ),

                    const SizedBox(height: 24),

                    //Camp Password
                    BehanceUnderlineInput(
                      label: "Password",
                      isPassword: true,
                      controller: passwordController,
                    ),

                    const SizedBox(height: 14),

                    //Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E8B57),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // ░░ BUTON SIGN IN
                    GestureDetector(
                      onTap: _isLoading ? null : login, //apelam login doar daca nu e loading
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
                            "SIGN IN",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120), //spatiu pentru tastatura
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ░░ FOOTER (Sign up) – ramane fix in partea de jos
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 26, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2E8B57),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//WIDGET CUSTOM PENTRU INPUT (stil Behance)
class BehanceUnderlineInput extends StatefulWidget {
  final String label;
  final IconData? rightIcon;
  final bool isPassword;
  final TextEditingController controller;

  const BehanceUnderlineInput({
    super.key,
    required this.label,
    this.rightIcon,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<BehanceUnderlineInput> createState() => _BehanceUnderlineInputState();
}

class _BehanceUnderlineInputState extends State<BehanceUnderlineInput> {
  bool _obscure = true; //show/hide pentru parola

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,

      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),

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

        //Icon din dreapta (check sau eye)
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure; //inverseaza show/hide
            });
          },
        )
            : (widget.rightIcon != null
            ? Icon(widget.rightIcon, color: Colors.grey.shade600)
            : null),

        contentPadding: const EdgeInsets.only(top: 18, bottom: 10),
      ),
    );
  }
}
