import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MobileApiException implements Exception {
  const MobileApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class MobileApi {
  MobileApi({
    http.Client? client,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _storage = storage,
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  static final shared = MobileApi();
  static const _tokenKey = 'auth.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5001/api'
        : 'http://localhost:5001/api';
  }

  Future<String?> get token => _storage.read(key: _tokenKey);

  Future<bool> get hasToken async => (await token)?.isNotEmpty ?? false;

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool authenticated = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated) {
      final savedToken = await token;
      if (savedToken != null) headers['Authorization'] = 'Bearer $savedToken';
    }

    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    final decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const MobileApiException('Format respons server tidak valid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MobileApiException(
        decoded['message']?.toString() ?? 'Permintaan ke server gagal.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _authenticate(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _send(
      'POST',
      path,
      body: body,
      authenticated: false,
    );
    final value = response['token'];
    if (value is! String || value.isEmpty) {
      throw const MobileApiException('Server tidak mengembalikan token login.');
    }
    await _storage.write(key: _tokenKey, value: value);
    final user = response['user'];
    if (user is! Map<String, dynamic>) {
      throw const MobileApiException('Data pengguna dari server tidak valid.');
    }
    return user;
  }

  Future<Map<String, dynamic>> login(String email, String password) =>
      _authenticate('/auth/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _authenticate('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

  Future<String> requestPasswordReset(String email) async {
    final result = await _send(
      'POST',
      '/auth/forgot-password',
      body: {'email': email},
      authenticated: false,
    );
    return result['message']?.toString() ?? 'Permintaan reset diproses.';
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final result = await _send(
      'POST',
      '/auth/reset-password',
      body: {'email': email, 'code': code, 'newPassword': newPassword},
      authenticated: false,
    );
    return result['message']?.toString() ?? 'Password berhasil diperbarui.';
  }

  Future<void> logout() async {
    try {
      await _send('POST', '/auth/logout');
    } catch (_) {
    } finally {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<Map<String, dynamic>> profile() async =>
      (await _send('GET', '/profile'))['user'] as Map<String, dynamic>;

  Future<void> updateProfile({
    required String name,
    required String email,
    required String username,
    required String phoneNumber,
    String? password,
  }) async {
    await _send('PUT', '/profile', body: {
      'name': name,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      if (password != null && password.isNotEmpty) 'password': password,
    });
  }

  Future<Map<String, dynamic>> dashboard({String? month}) async =>
      _send('GET', '/dashboard${month == null ? '' : '?month=$month'}');

  Future<List<Map<String, dynamic>>> transactions({String? month}) async {
    final result = await _send(
      'GET',
      '/transactions${month == null ? '' : '?month=$month'}',
    );
    return (result['transactions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> savings() async {
    final result = await _send('GET', '/savings');
    return (result['savings'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> saveBudget(double amount, String month) async {
    await _send('PUT', '/budget', body: {'amount': amount, 'month': month});
  }

  Future<void> createTransaction({
    required String type,
    required String category,
    required double amount,
    required String date,
    required String location,
    required String purpose,
    required String method,
  }) async {
    await _send('POST', '/transactions', body: {
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'location': location,
      'purpose': purpose,
      'method': method,
    });
  }

  Future<int> createSaving({
    required String name,
    required double target,
    required String note,
    required String category,
  }) async {
    final result = await _send('POST', '/savings', body: {
      'name': name,
      'target': target,
      'note': note,
      'category': category,
    });
    return (result['id'] as num).toInt();
  }

  Future<void> addSavingDeposit({
    required int savingId,
    required double amount,
  }) async {
    await _send('POST', '/savings/$savingId/deposits',
        body: {'amount': amount});
  }
}
