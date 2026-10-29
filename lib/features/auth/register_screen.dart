import 'package:flutter/material.dart';
import 'package:uku_app/data/api_profile_settings_repository.dart';
import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/navigation/main_navigation.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  String textField1 = '';
  String textField2 = '';
  String textField3 = '';
  String textField4 = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_isLoading) return;
    if (textField1.trim().isEmpty || !textField2.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi username dan email yang valid.')),
      );
      return;
    }
    if (textField3.length < 8 || textField3 != textField4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 8 karakter dan harus sama.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await MobileApi.shared.register(
        name: textField1.trim(),
        email: textField2.trim(),
        password: textField3,
      );
      final store = await UkuStore.loadFromApi(MobileApi.shared);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            store: store,
            profileRepository: ApiProfileSettingsRepository(MobileApi.shared),
            userName: user['name']?.toString() ?? textField1.trim(),
          ),
        ),
        (_) => false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    color: Color(0xFFFFFFFF),
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Container(
                            padding: const EdgeInsets.only(top: 58),
                            width: double.infinity,
                            child: Column(children: [
                              Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/EkWxkRXtj2/f7wopzal_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  )),
                              Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                  "Selamat Datang!",
                                  style: TextStyle(
                                    color: Color(0xFFFB8C09),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IntrinsicHeight(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 1),
                                  margin: const EdgeInsets.only(
                                      bottom: 10, left: 47, right: 47),
                                  width: double.infinity,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 13),
                                          child: Text(
                                            "Buat Akun UKu ",
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IntrinsicHeight(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            width: double.infinity,
                                            child: TextField(
                                              style: TextStyle(
                                                color: Color(0xFF9E9E9E),
                                                fontSize: 12,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  textField1 = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Username",
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 15,
                                                        bottom: 15,
                                                        left: 27,
                                                        right: 27),
                                                filled: false,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000),
                                                      width: 1.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IntrinsicHeight(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            width: double.infinity,
                                            child: TextField(
                                              style: TextStyle(
                                                color: Color(0xFF9E9E9E),
                                                fontSize: 12,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  textField2 = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Email",
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 15,
                                                        bottom: 15,
                                                        left: 26,
                                                        right: 26),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000),
                                                      width: 1.5),
                                                ),
                                                filled: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IntrinsicHeight(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            width: double.infinity,
                                            child: TextField(
                                              style: TextStyle(
                                                color: Color(0xFF9E9E9E),
                                                fontSize: 12,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  textField3 = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Password",
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 15,
                                                        bottom: 15,
                                                        left: 27,
                                                        right: 27),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000),
                                                      width: 1.5),
                                                ),
                                                filled: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IntrinsicHeight(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 35, left: 1),
                                            width: double.infinity,
                                            child: TextField(
                                              style: TextStyle(
                                                color: Color(0xFF9E9E9E),
                                                fontSize: 12,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  textField4 = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Validasi Password",
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 15,
                                                        bottom: 15,
                                                        left: 27,
                                                        right: 27),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: const BorderSide(
                                                      color: Color(0x42000000),
                                                      width: 1.5),
                                                ),
                                                filled: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _isLoading ? null : _register,
                                          child: IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Color(0xFFFAAE36),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0x36000000),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 13),
                                              width: double.infinity,
                                              child: Column(children: [
                                                Text(
                                                  "Daftar",
                                                  style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                              IntrinsicHeight(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 13, left: 47, right: 47),
                                  width: double.infinity,
                                  child: Column(children: [
                                    IntrinsicWidth(
                                      child: IntrinsicHeight(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 13),
                                          width: double.infinity,
                                          child: Row(children: [
                                            Container(
                                              color: Color(0xFF9E9E9E),
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              width: 75,
                                              height: 1,
                                              child: SizedBox(),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color(0xFFFAAE36),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x36000000),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(9),
                                                  margin: const EdgeInsets.only(
                                                      right: 32),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 36,
                                                            height: 36,
                                                            child:
                                                                Image.network(
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color(0xFFFAAE36),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x36000000),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 46,
                                                            height: 46,
                                                            child:
                                                                Image.network(
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
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 18),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Sudah punya akun? ",
                                          style: TextStyle(
                                            color: Color(0xFF9E9E9E),
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Login Sekarang",
                                          style: TextStyle(
                                            color: Color(0xFFFAAE36),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
