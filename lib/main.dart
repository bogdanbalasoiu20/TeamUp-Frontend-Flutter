import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/main_pages/welcome_page.dart';

void main() {
  runApp(const FitnessClubApp());
}

class FitnessClubApp extends StatelessWidget {
  const FitnessClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeamUp UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // setez WelcomeScreen ca prima pagina
      home: const WelcomeScreen(),
    );
  }
}