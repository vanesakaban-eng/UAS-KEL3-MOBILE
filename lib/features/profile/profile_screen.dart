import 'package:flutter/material.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/features/profile/about_us_screen.dart';
import 'package:uku_app/features/profile/change_password_screen.dart';
import 'package:uku_app/features/profile/edit_profil.dart';
import 'package:uku_app/features/faq/faq_screen.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repository,
    this.userName = 'User',
    this.onBack,
  });

  final ProfileSettingsRepository repository;
  final String userName;
  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _orange = Color(0xFFFF9200);
  ProfileSettings? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.repository.load();
      if (mounted) setState(() => _profile = profile);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat profil. Coba buka kembali halaman ini.'),
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(repository: widget.repository),
      ),
    );
    if (mounted) await _loadProfile();
  }

  Future<void> _changePassword() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(repository: widget.repository),
      ),
    );
  }

  void _openFaq() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const FaqScreen()),
    );
  }

  void _openAboutUs() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AboutUsScreen()),
    );
  }

  Future<void> _logout() async {
    try {
      await widget.repository.clearSecret();
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal keluar. Silakan coba lagi.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: _orange, size: 28),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = _profile?.username.isNotEmpty == true
        ? _profile!.username
        : (_profile?.name.isNotEmpty == true
            ? _profile!.name
            : widget.userName);
    final email = _profile?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              SizedBox(
                height: 110,
                child: Stack(
                  children: [
                    Positioned(
                      left: -12,
                      top: 12,
                      child: AppBackButton(
                        onPressed: widget.onBack ??
                            () => Navigator.maybePop(context),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 7,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: _orange, size: 34),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _menuItem(
                icon: Icons.person,
                label: 'Edit Profile',
                onTap: _editProfile,
              ),
              _menuItem(
                icon: Icons.quiz,
                label: 'FAQ',
                onTap: _openFaq,
              ),
              _menuItem(
                icon: Icons.info,
                label: 'Tentang Kami',
                onTap: _openAboutUs,
              ),
              _menuItem(
                icon: Icons.lock,
                label: 'Ubah Kata Sandi',
                onTap: _changePassword,
              ),
              const SizedBox(height: 34),
              ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFAAE36),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('LOGOUT', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
