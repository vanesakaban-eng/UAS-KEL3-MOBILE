import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings {
  const ProfileSettings({
    this.name = '',
    this.email = '',
    this.username = '',
    this.phoneNumber = '',
  });

  final String name;
  final String email;
  final String username;
  final String phoneNumber;
}

abstract interface class ProfileSettingsRepository {
  Future<ProfileSettings> load();

  Future<String?> loadPassword();

  Future<void> save(ProfileSettings profile, {String? password});

  Future<void> clearSecret();
}

class LocalProfileSettingsRepository implements ProfileSettingsRepository {
  LocalProfileSettingsRepository({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  static const _nameKey = 'profile.name';
  static const _emailKey = 'profile.email';
  static const _usernameKey = 'profile.username';
  static const _phoneNumberKey = 'profile.phone_number';
  static const _passwordKey = 'auth.password';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<ProfileSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return ProfileSettings(
      name: preferences.getString(_nameKey) ?? '',
      email: preferences.getString(_emailKey) ?? '',
      username: preferences.getString(_usernameKey) ?? '',
      phoneNumber: preferences.getString(_phoneNumberKey) ?? '',
    );
  }

  @override
  Future<String?> loadPassword() => _secureStorage.read(key: _passwordKey);

  @override
  Future<void> save(ProfileSettings profile, {String? password}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, profile.name);
    await preferences.setString(_emailKey, profile.email);
    await preferences.setString(_usernameKey, profile.username);
    await preferences.setString(_phoneNumberKey, profile.phoneNumber);

    if (password != null && password.isNotEmpty) {
      await _secureStorage.write(key: _passwordKey, value: password);
    }
  }

  @override
  Future<void> clearSecret() => _secureStorage.delete(key: _passwordKey);
}
