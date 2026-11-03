import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
import 'package:uku_app/features/auth/forgot_password_screen.dart';
import 'package:uku_app/features/profile/change_password_screen.dart';
import 'package:uku_app/features/profile/edit_profil.dart';
import 'package:uku_app/navigation/main_navigation.dart';

class _FakeProfileSettingsRepository implements ProfileSettingsRepository {
  ProfileSettings profile = const ProfileSettings();
  String? password = 'saved-password';

  @override
  Future<void> clearSecret() async {}

  @override
  Future<ProfileSettings> load() async => profile;

  @override
  Future<String?> loadPassword() async => password;

  @override
  Future<void> save(ProfileSettings value, {String? password}) async {
    profile = value;
    if (password != null) this.password = password;
  }
}

void main() {
  testWidgets('profile edit matches the requested form layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeProfileSettingsRepository();
    repository.profile = const ProfileSettings(email: 'user@example.com');
    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(
        repository: repository,
        onSaved: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('type here'), findsNWidgets(4));
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Ubah Kata Sandi'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'LOGOUT'), findsOneWidget);

    await tester.tap(find.text('Ubah Kata Sandi'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(find.text('Kata Sandi Lama'), findsOneWidget);
    expect(find.text('Kata Sandi Baru'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi Baru'), findsOneWidget);
    expect(find.text('Perbarui Kata Sandi'), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);

    await tester.tap(find.text('Lupa Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Kirim Kode Reset'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'user@example.com',
    );
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'saved-password');
    await tester.enterText(find.byType(TextFormField).at(1), 'new-password');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'different-password',
    );
    await tester.tap(find.text('Perbarui Kata Sandi'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi kata sandi tidak sesuai.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong-password');
    await tester.enterText(find.byType(TextFormField).at(1), 'new-password');
    await tester.enterText(find.byType(TextFormField).at(2), 'new-password');
    await tester.tap(find.text('Perbarui Kata Sandi'));
    await tester.pumpAndSettle();
    expect(find.text('Kata sandi lama tidak sesuai.'), findsOneWidget);
    expect(repository.password, 'saved-password');

    await tester.enterText(find.byType(TextFormField).at(0), 'saved-password');
    await tester.tap(find.text('Perbarui Kata Sandi'));
    await tester.pumpAndSettle();
    expect(repository.password, 'new-password');
    expect(find.text('Edit Profil'), findsOneWidget);
  });

  testWidgets('profile is the rightmost main navigation destination',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainNavigationScreen(
          profileRepository: _FakeProfileSettingsRepository(),
        ),
      ),
    );

    final profileDestination = find.text('Profil');
    expect(profileDestination, findsOneWidget);
    await tester.tap(profileDestination);
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, User'), findsOneWidget);
  });

  testWidgets('forgot password uses the password page styling', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(initialEmail: 'user@example.com'),
      ),
    );

    expect(find.text('Lupa Password'), findsOneWidget);
    expect(find.text('Email Akun'), findsOneWidget);
    expect(find.text('Kirim Kode Reset'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'user@example.com');

    final emailField = find.byType(TextField);
    final inputDecoration = tester.widget<TextField>(emailField).decoration!;
    expect(inputDecoration.border, isA<OutlineInputBorder>());
    expect(
      (inputDecoration.border as OutlineInputBorder).borderRadius,
      BorderRadius.circular(7),
    );
    expect(
      tester.getSize(find
          .ancestor(
            of: emailField,
            matching: find.byType(SizedBox),
          )
          .first),
      const Size(334, 34),
    );
  });
}
