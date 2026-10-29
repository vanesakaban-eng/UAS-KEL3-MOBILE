import 'package:flutter/material.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.repository,
  });

  final ProfileSettingsRepository repository;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const _orange = Color(0xFFFF9200);
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();
  String? _savedPassword;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPassword();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPassword() async {
    try {
      final password = await widget.repository.loadPassword();
      if (!mounted) return;
      setState(() {
        _savedPassword = password;
        _isLoading = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Gagal memuat kata sandi. Silakan coba lagi.');
    }
  }

  Future<void> _updatePassword() async {
    if (_isLoading || _isSaving || !_formKey.currentState!.validate()) return;

    if (_savedPassword == null || _savedPassword!.isEmpty) {
      _showMessage('Kata sandi lama belum tersimpan di perangkat ini.');
      return;
    }
    if (_oldPasswordController.text != _savedPassword) {
      _showMessage('Kata sandi lama tidak sesuai.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final profile = await widget.repository.load();
      await widget.repository.save(
        profile,
        password: _newPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi berhasil diperbarui.')),
      );
      Navigator.pop(context, true);
    } on Exception {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage('Gagal menyimpan kata sandi. Silakan coba lagi.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showForgotPasswordInfo() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'Pemulihan kata sandi belum tersedia. '
          'Untuk memperbarui kata sandi, masukkan kata sandi lama Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              obscureText: true,
              validator: validator ??
                  (value) => value == null || value.isEmpty
                      ? 'Bagian ini wajib diisi.'
                      : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
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
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 58),
                              child: Text(
                                'Ubah Kata Sandi',
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
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      'Kata Sandi Lama',
                      _oldPasswordController,
                    ),
                    _buildPasswordField(
                      'Kata Sandi Baru',
                      _newPasswordController,
                    ),
                    _buildPasswordField(
                      'Konfirmasi Kata Sandi Baru',
                      _confirmationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bagian ini wajib diisi.';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Konfirmasi kata sandi tidak sesuai.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading || _isSaving ? null : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFAAE36),
                          disabledBackgroundColor: const Color(0xFFFAAE36),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Perbarui Kata Sandi',
                                style: TextStyle(fontSize: 12),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6D6D6),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Batalkan',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: _showForgotPasswordInfo,
                        style: TextButton.styleFrom(
                          foregroundColor: _orange,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Lupa Password?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
