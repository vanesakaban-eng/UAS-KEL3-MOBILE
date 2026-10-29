import 'package:flutter/material.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/features/profile/change_password_screen.dart';
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
  late final ProfileSettingsRepository _repository =
      widget.repository ?? LocalProfileSettingsRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
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
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.load();
      if (!mounted) return;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _usernameController.text = profile.username;
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

  Future<void> _changePassword() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(repository: _repository),
      ),
    );
  }

  Widget _buildInputGroup(
    String label, {
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 90,
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
                                    fontSize: 18,
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
                          width: 86,
                          height: 86,
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
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputGroup('Nama', controller: _nameController),
                      _buildInputGroup(
                        'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildInputGroup(
                        'Username',
                        controller: _usernameController,
                      ),
                      _buildInputGroup(
                        'Nomor Telepon',
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFAAE36),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.lock, size: 20),
                          label: const Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFAAE36),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text(
                              'LOGOUT',
                              style: TextStyle(fontSize: 14),
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
        ),
      ),
    );
  }
}
