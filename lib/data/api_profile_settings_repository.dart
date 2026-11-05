import 'package:uku_app/data/mobile_api.dart';
import 'package:uku_app/data/profile_settings_repository.dart';

class ApiProfileSettingsRepository implements ProfileSettingsRepository {
  const ApiProfileSettingsRepository(this.api);

  final MobileApi api;

  @override
  Future<ProfileSettings> load() async {
    final user = await api.profile();
    return ProfileSettings(
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      phoneNumber: user['phoneNumber']?.toString() ?? '',
    );
  }

  @override
  Future<String?> loadPassword() async => null;

  @override
  Future<void> save(ProfileSettings profile, {String? password}) =>
      api.updateProfile(
        name: profile.name,
        email: profile.email,
        username: profile.username,
        phoneNumber: profile.phoneNumber,
        password: password,
      );

  @override
  Future<void> clearSecret() async {
    try {
      await api.logout();
    } catch (_) {
      // The token is cleared by MobileApi even when the server is offline.
    }
  }
}
