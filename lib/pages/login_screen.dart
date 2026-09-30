import 'package:flutter/material.dart';
import 'main_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset('assets/image/Logo.png', height: 100),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFA9D2B)),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Login ke Akun Kamu', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              _buildTextField(hintText: 'Email'),
              const SizedBox(height: 12),
              _buildTextField(hintText: 'Password', isObscure: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Lupa Password?', style: TextStyle(color: Colors.black54, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 10),
              _buildButton(
                text: 'Login',
                onPressed: () {
                  // Berpindah ke Halaman Home Utama
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/google.png', height: 80 ),
                    onPressed: () {

                    },
                    
                  ),
                  const SizedBox(width: 16), // Jarak antara tombol Google dan Facebook
              // Tombol Facebook
    IconButton(
      icon: Image.asset(
        'assets/icons/facebook.png',
        height: 80,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.facebook, size: 36, color: Color(0xFF1877F2)),
      ),
      onPressed: () {
        // Aksi login Facebook
      },
    ),
  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black26)),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFA9D2B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Atau login menggunakan', style: TextStyle(color: Colors.black54, fontSize: 11)),
        ),
        Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }
}