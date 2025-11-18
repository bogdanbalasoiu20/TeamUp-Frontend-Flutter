import 'package:flutter/material.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';

// Ecranul de deschidere(login+sign up). Primul care apare cand deschizi aplicatia
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color startColor = AppColors.primaryGreenDark;
    const Color endColor = AppColors.primaryGreenLight;

    return Scaffold(
      body: Container(
        //Fundalul
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Numele aplicatiei(coloana 1)
                const Text(
                  'TeamUp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 100),

                // Mesajul (coloana 2)
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 80),

                //Butonul de sign in(coloana 3)
                _WelcomeButton(
                  text: 'SIGN IN',
                  onTap: () {
                    // TODO: De facut navigarea catre SignInScreen
                    print('Navigare la Sign In');
                  },
                  isFilled: true,
                  fillColor: endColor,
                ),
                const SizedBox(height: 20),

                //Butonul de sign up(coloana 4)
                _WelcomeButton(
                  text: 'SIGN UP',
                  onTap: () {
                    // TODO: De facut navigarea catre SignUpScreen
                    print('Navigare la Sign Up');
                  },
                  isFilled: false,
                  fillColor: endColor,
                ),
                const SizedBox(height: 80),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget privat pentru butoanele de Sign In / Sign Up
class _WelcomeButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isFilled ? Colors.white : Colors.transparent,
          side: BorderSide(
            color: isFilled ? Colors.transparent : Colors.white,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isFilled ? fillColor : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}