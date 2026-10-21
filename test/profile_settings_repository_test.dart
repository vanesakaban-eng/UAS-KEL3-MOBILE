import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uku_app/data/profile_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('profile fields persist in shared preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LocalProfileSettingsRepository();
    const profile = ProfileSettings(
      name: 'Anisa',
      email: 'anisa@example.com',
      username: 'anisa',
      phoneNumber: '08123456789',
    );

    await repository.save(profile);
    final loaded = await repository.load();

    expect(loaded.name, profile.name);
    expect(loaded.email, profile.email);
    expect(loaded.username, profile.username);
    expect(loaded.phoneNumber, profile.phoneNumber);
  });
}
