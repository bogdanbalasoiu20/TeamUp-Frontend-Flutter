import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/auth/register_page.dart';
import 'package:team_up_fe_new/screens/auth/login_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final Color _bgDark = const Color(0xFF091210);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);
  final Color _fieldLineColor = const Color(0xFFFFFFFF).withOpacity(0.12);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A6F4A).withOpacity(0.25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  Expanded(
                    flex: 5,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          width: 260,
                          height: 340,
                          decoration: BoxDecoration(
                            border: Border.all(color: _fieldLineColor, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.01),
                          ),
                          child: Stack(
                            children: [
                              Center(child: Container(height: 2, width: double.infinity, color: _fieldLineColor)),
                              Center(
                                  child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _fieldLineColor, width: 2)
                                      )
                                  )
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: _fieldLineColor, width: 2),
                                        left: BorderSide(color: _fieldLineColor, width: 2),
                                        right: BorderSide(color: _fieldLineColor, width: 2),
                                      )
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: _fieldLineColor, width: 2),
                                        left: BorderSide(color: _fieldLineColor, width: 2),
                                        right: BorderSide(color: _fieldLineColor, width: 2),
                                      )
                                  ),
                                ),
                              ),


                              // Portar
                              _buildAnimatedPlayer(Alignment(0, 0.88), 0.0, "GK", false),

                              // Fundas Stanga
                              _buildAnimatedPlayer(Alignment(-0.7, 0.5), 0.1, "LB", false),

                              // Fundas Dreapta
                              _buildAnimatedPlayer(Alignment(0.7, 0.5), 0.2, "RB", false),

                              // Mijlocas Central
                              _buildAnimatedPlayer(Alignment(0, 0.05), 0.3, "CM", false),

                              // Atacant
                              _buildAnimatedPlayer(Alignment(0, -0.6), 0.5, "ST", true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TEAM UP",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 36 : 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Find your squad.\nOrganize matches. Rate the game.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: _textSecondary,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 40),

                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentGreen,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "I HAVE AN ACCOUNT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPlayer(Alignment alignment, double delay, String label, bool isCaptain) {
    final double start = delay * 0.5;
    final double end = (delay * 0.5) + 0.4;

    final Animation<double> scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.elasticOut),
      ),
    );

    final Animation<double> opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeIn),
      ),
    );

    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnim.value,
            child: Transform.scale(
              scale: scaleAnim.value,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCaptain ? _accentGreen : const Color(0xFF1F352E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCaptain ? _accentGreen : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCaptain
                          ? _accentGreen.withOpacity(0.4)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: isCaptain ? 15 : 5,
                      spreadRadius: isCaptain ? 2 : 0,
                    )
                  ],
                ),
                child: Center(
                  child: isCaptain
                      ? const Icon(Icons.star, size: 18, color: Colors.black)
                      : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}