import 'package:flutter/material.dart';
import 'register_screen.dart'; // <--- Ubah ke RegisterScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()), // <--- Arahkan ke RegisterScreen
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9C846),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/logo_depan.png',
              height: 200,
              errorBuilder: (context, error, stackTrace) => Image.asset('assets/image/logo.png', height: 140),
            ),
          ],
        ),
      ),
    );
  }
}