import 'package:flutter/material.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.repository,
    this.onBack,
    this.onSaved,
  });

  final ProfileSettingsRepository? repository;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _orange = Color(0xFFFF9200);
  bool _showPassword = false;
  late final ProfileSettingsRepository _repository =
      widget.repository ?? LocalProfileSettingsRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.load();
      final password = await _repository.loadPassword();
      if (!mounted) return;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _usernameController.text = profile.username;
      _passwordController.text = password ?? '';
      _phoneNumberController.text = profile.phoneNumber;
    } on Exception {
      if (mounted) _showStorageError();
    }
  }

  Future<void> _saveProfile() async {
    try {
      await _repository.save(
        ProfileSettings(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
        ),
        password: _passwordController.text.isEmpty
            ? null
            : _passwordController.text,
      );
      if (!mounted) return;
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context);
      }
    } on Exception {
      if (mounted) _showStorageError();
    }
  }

  void _showStorageError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal mengakses penyimpanan profil. Coba lagi.'),
      ),
    );
  }

  Widget _buildInputGroup(
    String label, {
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: TextFormField(
              controller: controller,
              obscureText: isPassword && !_showPassword,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 11),
              decoration: InputDecoration(
                hintText: 'type here',
                hintStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        tooltip: _showPassword
                            ? 'Sembunyikan password'
                            : 'Tampilkan password',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 34,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 17,
                          color: _orange,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _repository.clearSecret();
    } on Exception {
      if (mounted) _showStorageError();
      return;
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 12,
                          child: Transform.translate(
                            offset: const Offset(-20, 0),
                            child: AppBackButton(
                              onPressed: widget.onBack ??
                                  () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 12,
                          child: IconButton(
                            tooltip: 'Simpan profil',
                            onPressed: _saveProfile,
                            icon: const Icon(
                              Icons.check,
                              color: _orange,
                              size: 20,
                            ),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 58),
                            child: Text(
                              'Edit Profil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: _orange,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputGroup('Nama', controller: _nameController),
                  _buildInputGroup('Email', controller: _emailController,
                      keyboardType: TextInputType.emailAddress),
                  _buildInputGroup('Username',
                      controller: _usernameController),
                  _buildInputGroup('Password',
                      controller: _passwordController, isPassword: true),
                  _buildInputGroup(
                    'Nomor Telepon',
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.logout, size: 14),
                        label: const Text(
                          'LOGOUT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
