import 'package:flutter/material.dart';
import 'package:uku_app/data/api_profile_settings_repository.dart';
import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/auth/forgot_password_screen.dart';
import 'package:uku_app/features/auth/register_screen.dart';
import 'package:uku_app/navigation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = await MobileApi.shared.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final store = await UkuStore.loadFromApi(MobileApi.shared);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            store: store,
            profileRepository: ApiProfileSettingsRepository(MobileApi.shared),
            userName: user['name']?.toString() ?? 'User',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForgotPassword() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          initialEmail: _emailController.text.trim(),
        ),
      ),
    );
    if (email != null && mounted) _emailController.text = email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 58),
              Image.asset('assets/image/Logo.png', height: 100),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFB8C09)),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Login ke Akun Kamu',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              _buildTextField(hintText: 'Email', controller: _emailController),
              const SizedBox(height: 12),
              _buildTextField(
                hintText: 'Password',
                controller: _passwordController,
                isObscure: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _openForgotPassword,
                  child: const Text('Lupa Password?',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 10),
              _buildButton(
                text: 'Login',
                onPressed: _isLoading ? null : _login,
              ),
              IntrinsicHeight(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 13, bottom: 13, left: 47, right: 47),
                  width: double.infinity,
                  child: Column(children: [
                    IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 13),
                          width: double.infinity,
                          child: Row(children: [
                            Container(
                              color: Color(0xFF9E9E9E),
                              margin: const EdgeInsets.only(right: 8),
                              width: 75,
                              height: 1,
                              child: SizedBox(),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Text(
                                "Atau login  menggunakan",
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              color: Color(0xFF9E9E9E),
                              width: 74,
                              height: 1,
                              child: SizedBox(),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Row(children: [
                          InkWell(
                            onTap: () {
                              print('Pressed');
                            },
                            child: IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xFFFAAE36),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x36000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(9),
                                  margin: const EdgeInsets.only(right: 32),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 36,
                                            height: 36,
                                            child: Image.network(
                                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/EkWxkRXtj2/yto9kz03_expires_30_days.png",
                                              fit: BoxFit.fill,
                                            )),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print('Pressed');
                            },
                            child: IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xFFFAAE36),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x36000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 46,
                                            height: 46,
                                            child: Image.network(
                                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/EkWxkRXtj2/5q3bpj2q_expires_30_days.png",
                                              fit: BoxFit.fill,
                                            )),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Register()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Belum punya akun? ',
                        style:
                            TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                      ),
                      TextSpan(
                        text: 'Daftar Sekarang',
                        style:
                            TextStyle(color: Color(0xFFFAAE36), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: hintText == 'Email' ? TextInputType.emailAddress : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26)),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFAAE36),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required VoidCallback onPressed,
    Icon? fallbackIcon,
    Color backgroundColor = const Color(0xFFFAAE36),
    double iconSize = 36,
  }) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: fallbackIcon ??
            Image.asset(asset,
                width: iconSize, height: iconSize, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Atau login menggunakan',
              style: TextStyle(color: Colors.black54, fontSize: 11)),
        ),
        Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }
}
