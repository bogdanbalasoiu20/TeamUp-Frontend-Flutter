import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/register_page.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';
import 'package:team_up_fe_new/screens/login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color endColor = AppColors.primaryGreenLight;

    return Scaffold(
      body: Stack(
        children: [

          //Fundalul (gradient + imagine)
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
              //   opacity: 0.18,
              // ),
            ),
          ),

          // Blur peste imagine
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.10),
            ),
          ),

          // Gradient negru subtil pentru contrast mai bun
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.12),
                  Colors.black.withOpacity(0.25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),


          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[


                  Column(
                    children: [
                      const SizedBox(height: 140), // împinge titlul mai jos
                      _FadeSlide(
                        delay: 0,
                        child: const Text(
                          'TeamUp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),


                  Column(
                    children: [
                      const SizedBox(height: 20),
                      _FadeSlide(
                        delay: 200,
                        child: _AnimatedBall(),
                      ),

                      const SizedBox(height: 40),

                      _FadeSlide(
                        delay: 350,
                        child: const Text(
                          'Football starts here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitlu nou
                      _FadeSlide(
                        delay: 450,
                        child: Text(
                          'Become your own player',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),


                  Column(
                    children: [
                      _FadeSlide(
                        delay: 600,
                        child: _WelcomeButton(
                          text: 'SIGN IN',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=> const LoginScreen())
                            );
                            print('Navigare la Sign In');
                          },
                          isFilled: true,
                          fillColor: endColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _FadeSlide(
                        delay: 750,
                        child: _WelcomeButton(
                          text: 'SIGN UP',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=>const RegisterScreen())
                            );
                            print('Navigare la Sign Up');
                          },
                          isFilled: false,
                          fillColor: endColor,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Footer
                      _FadeSlide(
                        delay: 900,
                        child: Text(
                          "Powered by TeamUp",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
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
}


// Widget privat pentru butoanele de Sign In / Sign Up
class _WelcomeButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isFilled;
  final Color fillColor;

  const _WelcomeButton({
    required this.text,
    required this.onTap,
    required this.isFilled,
    required this.fillColor,
  });

  @override
  State<_WelcomeButton> createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<_WelcomeButton> {
  bool _isPressed = false;

  void _onPress(bool pressed) {
    setState(() {
      _isPressed = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final onTap = widget.onTap;
    final isFilled = widget.isFilled;
    final fillColor = widget.fillColor;

    return GestureDetector(
      onTapDown: (_) => _onPress(true),
      onTapUp: (_) => _onPress(false),
      onTapCancel: () => _onPress(false),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: isFilled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isFilled ? Colors.transparent : Colors.white,
            width: 2,
          ),
          boxShadow: _isPressed
              ? []
              : [
            if (isFilled)
              BoxShadow(
                color: fillColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              text,
              style: TextStyle(
                color: isFilled ? fillColor : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Animatia pentru minge
class _AnimatedBall extends StatefulWidget {
  @override
  State<_AnimatedBall> createState() => _AnimatedBallState();
}

class _AnimatedBallState extends State<_AnimatedBall>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_soccer,
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}


// Fade + Slide animator
class _FadeSlide extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeSlide({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
    );
  }
}
