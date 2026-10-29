import 'package:flutter/material.dart';
import 'package:uku_app/data/api_profile_settings_repository.dart';
import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State {
  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(seconds: 10));
    if (!mounted) return;

    Widget nextScreen = const LoginScreen();
    if (await MobileApi.shared.hasToken) {
      try {
        final user = await MobileApi.shared.profile();
        final store = await UkuStore.loadFromApi(MobileApi.shared);
        nextScreen = MainNavigationScreen(
          store: store,
          profileRepository: ApiProfileSettingsRepository(MobileApi.shared),
          userName: user['name']?.toString() ?? 'User',
        );
      } on Exception {
        await MobileApi.shared.logout();
        nextScreen = const LoginScreen();
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
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
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/image/logo.png', height: 140),
            ),
          ],
        ),
      ),
    );
  }
}
