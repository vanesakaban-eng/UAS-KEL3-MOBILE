import 'package:flutter/material.dart';
import 'package:uku_app/data/api_profile_settings_repository.dart';
import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/auth/forgot_password_screen.dart';
import 'package:uku_app/features/auth/register_screen.dart';
import 'package:uku_app/features/auth/verify_email_screen.dart';
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
  bool _showPassword = false;
  String? _verificationEmail;

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
      if (error is MobileApiException && error.code == 'EMAIL_NOT_VERIFIED') {
        setState(() => _verificationEmail = _emailController.text.trim());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openRegister() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const Register()),
    );
    if (email == null || !mounted) return;
    setState(() => _verificationEmail = email);
    _emailController.text = email;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Periksa email, lalu verifikasi akun sebelum login.'),
      ),
    );
  }

  Future<void> _openVerification() async {
    final email = _verificationEmail ?? _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email yang akan diverifikasi.')),
      );
      return;
    }
    final verifiedEmail = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyEmailScreen(initialEmail: email),
      ),
    );
    if (verifiedEmail == null || !mounted) return;
    setState(() => _verificationEmail = null);
    _emailController.text = verifiedEmail;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email terverifikasi. Silakan login.')),
    );
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
                isPassword: true,
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
              if (_verificationEmail != null)
                TextButton.icon(
                  onPressed: _openVerification,
                  icon: const Icon(Icons.mark_email_unread_outlined),
                  label: const Text('Verifikasi email'),
                ),
              const SizedBox(height: 18),
              GestureDetector(
                key: const ValueKey('open-register'),
                behavior: HitTestBehavior.opaque,
                onTap: _openRegister,
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
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_showPassword,
      keyboardType: hintText == 'Email' ? TextInputType.emailAddress : null,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _showPassword
                    ? 'Sembunyikan password'
                    : 'Tampilkan password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFFAAE36),
                ),
              )
            : null,
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
}
