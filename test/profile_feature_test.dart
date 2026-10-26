import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/profile_settings_repository.dart';
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
    this.password = password;
  }
}

void main() {
  testWidgets('profile edit matches the requested form layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(
        repository: _FakeProfileSettingsRepository(),
      ),
    ));
    await tester.pump();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('type here'), findsNWidgets(5));
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.widgetWithText(ElevatedButton, 'LOGOUT'), findsOneWidget);

    final password = tester.widget<EditableText>(
      find.byType(EditableText).at(3),
    );
    expect(password.obscureText, isTrue);
    expect(password.controller.text, 'saved-password');

    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(3)).obscureText,
      isFalse,
    );
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
