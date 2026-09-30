import 'package:flutter/material.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFA9D2B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFFA9D2B)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.black12,
                child: Image.asset('assets/image/profil.png', height: 70),
              ),
              const SizedBox(height: 24),
              _buildInputGroup('Nama', 'User'),
              const SizedBox(height: 14),
              _buildInputGroup('Email', 'User@email.com'),
              const SizedBox(height: 14),
              _buildInputGroup('Username', 'Use123'),
              const SizedBox(height: 14),
              _buildInputGroup('Password', '******', isPassword: true),
              const SizedBox(height: 14),
              _buildInputGroup('Nomor Telepon', '08123456789'),
              const SizedBox(height: 30),
              SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA9D2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, String initialValue, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          obscureText: isPassword,
          decoration: InputDecoration(
            suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Color(0xFFFA9D2B)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black26)),
          ),
        ),
      ],
    );
  }
}