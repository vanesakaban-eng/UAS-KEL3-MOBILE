import 'package:flutter/material.dart';
import 'package:uku_app/data/mobile_api.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const _orange = Color(0xFFFAAE36);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPasswords = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await MobileApi.shared.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, _emailController.text.trim());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration(String label, {Widget? suffixIcon}) =>
      InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _orange),
        ),
      );

  Widget _passwordToggle() => IconButton(
        tooltip: _showPasswords ? 'Sembunyikan password' : 'Tampilkan password',
        onPressed: () => setState(() => _showPasswords = !_showPasswords),
        icon: Icon(
          _showPasswords ? Icons.visibility_off : Icons.visibility,
          color: _orange,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun UKu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              Center(child: Image.asset('assets/image/Logo.png', height: 88)),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Nama'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Email'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Masukkan email yang valid.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPasswords,
                decoration: _decoration(
                  'Password (minimal 8 karakter)',
                  suffixIcon: _passwordToggle(),
                ),
                validator: (value) => value == null || value.length < 8
                    ? 'Password minimal 8 karakter.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: !_showPasswords,
                decoration: _decoration(
                  'Ulangi Password',
                  suffixIcon: _passwordToggle(),
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Konfirmasi password tidak sama.'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_isLoading ? 'Mengirim kode...' : 'Daftar'),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}