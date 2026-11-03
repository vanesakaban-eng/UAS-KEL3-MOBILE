import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _orange = Color(0xFFFAAE36);
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage('Masukkan alamat email yang valid.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final message = await MobileApi.shared.requestPasswordReset(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _showMessage(message);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    if (_codeController.text.trim().length != 6) {
      _showMessage('Masukkan kode 6 digit dari email.');
      return;
    }
    if (_passwordController.text.length < 8 ||
        _passwordController.text != _confirmController.text) {
      _showMessage('Password minimal 8 karakter dan harus sama.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final message = await MobileApi.shared.resetPassword(
        email: email,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.pop(context, email);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildInputGroup(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
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
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              style: const TextStyle(fontSize: 11),
              decoration: InputDecoration(
                hintText: 'type here',
                hintStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                ),
                counterText: '',
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
                disabledBorder: OutlineInputBorder(
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

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    Color foregroundColor = Colors.white,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: backgroundColor == _orange ? 2 : 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
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
                              'Lupa Password',
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
                  _buildInputGroup(
                    'Email Akun',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_codeSent,
                  ),
                  if (!_codeSent) ...[
                    const SizedBox(height: 2),
                    _buildActionButton(
                      label: _isLoading ? 'Mengirim...' : 'Kirim Kode Reset',
                      onPressed: _isLoading ? null : _sendCode,
                      backgroundColor: _orange,
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      label: 'Batalkan',
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      backgroundColor: const Color(0xFFD6D6D6),
                      foregroundColor: Colors.black,
                    ),
                  ],
                  if (_codeSent) ...[
                    _buildInputGroup(
                      'Kode 6 Digit',
                      _codeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 6,
                    ),
                    _buildInputGroup(
                      'Password Baru',
                      _passwordController,
                      obscureText: true,
                    ),
                    _buildInputGroup(
                      'Konfirmasi Password Baru',
                      _confirmController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 2),
                    _buildActionButton(
                      label:
                          _isLoading ? 'Menyimpan...' : 'Simpan Password Baru',
                      onPressed: _isLoading ? null : _resetPassword,
                      backgroundColor: _orange,
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      label: 'Batalkan',
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      backgroundColor: const Color(0xFFD6D6D6),
                      foregroundColor: Colors.black,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _sendCode,
                        style: TextButton.styleFrom(
                          foregroundColor: _orange,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Kirim ulang kode'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
