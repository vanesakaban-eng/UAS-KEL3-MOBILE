import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
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
}
