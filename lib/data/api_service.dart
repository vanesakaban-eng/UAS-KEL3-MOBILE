import 'dart:convert';
import 'dart:io';

/// Service untuk menghubungkan Flutter Frontend UKu dengan Backend API di D:\UKU_APP\BE
class UkuApiService {
  UkuApiService._();
  static final UkuApiService instance = UkuApiService._();

  /// URL dasar Backend:
  /// - Windows Desktop: http://localhost:5000/api
  /// - Android Emulator: http://10.0.2.2:5000/api
  /// - HP Fisik: http://<IP_KOMPUTER>:5000/api (misal: http://192.168.1.10:5000/api)
  static String baseUrl = 'http://localhost:5000/api';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  final HttpClient _client = HttpClient();

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _send(String method, String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = await _client.openUrl(method, uri);

    _buildHeaders().forEach((key, value) {
      request.headers.set(key, value);
    });

    if (body != null) {
      final jsonBody = utf8.encode(jsonEncode(body));
      request.add(jsonBody);
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw HttpException(
        decoded['message'] as String? ?? 'Terjadi kesalahan pada server (${response.statusCode})',
      );
    }

    return decoded;
  }

  // --- 1. Autentikasi ---
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    final res = await _send('POST', '/auth/login', body: {
      'identifier': emailOrUsername,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> demoLogin() async {
    final res = await _send('POST', '/auth/demo');
    final data = res['data'] as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    final res = await _send('POST', '/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'username': username,
      'phone_number': phoneNumber,
    });
    final data = res['data'] as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _send('GET', '/auth/profile');
    return res['data'] as Map<String, dynamic>;
  }

  // --- 2. Ringkasan Beranda ---
  Future<Map<String, dynamic>> getHomeOverview() async {
    final res = await _send('GET', '/activities/home');
    return res['data'] as Map<String, dynamic>;
  }

  // --- 3. Pengeluaran (Expenses) ---
  Future<Map<String, dynamic>> getExpenses({String? month, String? category}) async {
    final query = <String>[];
    if (month != null) query.add('month=$month');
    if (category != null) query.add('category=${Uri.encodeComponent(category)}');
    final queryString = query.isNotEmpty ? '?${query.join('&')}' : '';
    final res = await _send('GET', '/expenses$queryString');
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addExpense({
    required String category,
    required double amount,
    DateTime? date,
    String? location,
    String? purpose,
    String method = 'Tunai',
  }) async {
    final res = await _send('POST', '/expenses', body: {
      'category': category,
      'amount': amount,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'location': location ?? '',
      'purpose': purpose ?? '',
      'method': method,
    });
    return res['data'] as Map<String, dynamic>;
  }

  // --- 4. Budget ---
  Future<Map<String, dynamic>> getBudget({String? month}) async {
    final queryString = month != null ? '?month=$month' : '';
    final res = await _send('GET', '/budget$queryString');
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setBudget(double amount, {String? month}) async {
    final res = await _send('POST', '/budget', body: {
      'amount': amount,
      if (month != null) 'month': month,
    });
    return res['data'] as Map<String, dynamic>;
  }

  // --- 5. Tabungan (Savings) ---
  Future<List<dynamic>> getSavings() async {
    final res = await _send('GET', '/savings');
    return res['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> addSaving({
    required String name,
    required double target,
    String? note,
    String category = 'Lainnya',
  }) async {
    final res = await _send('POST', '/savings', body: {
      'name': name,
      'target': target,
      'note': note ?? '',
      'category': category,
    });
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> depositSaving(String savingId, double amount, {String? note}) async {
    final res = await _send('POST', '/savings/$savingId/deposit', body: {
      'amount': amount,
      if (note != null) 'note': note,
    });
    return res['data'] as Map<String, dynamic>;
  }

  // --- 6. Rekap & Riwayat Transaksi ---
  Future<Map<String, dynamic>> getRecap({String? month}) async {
    final queryString = month != null ? '?month=$month' : '';
    final res = await _send('GET', '/activities/recap$queryString');
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTransactions({String? type, String? category, String? month}) async {
    final query = <String>[];
    if (type != null) query.add('type=$type');
    if (category != null) query.add('category=${Uri.encodeComponent(category)}');
    if (month != null) query.add('month=$month');
    final queryString = query.isNotEmpty ? '?${query.join('&')}' : '';
    final res = await _send('GET', '/activities/transactions$queryString');
    return res['data'] as Map<String, dynamic>;
  }

  // --- 7. AIKu Chatbot ---
  Future<String> askAI(String question) async {
    final res = await _send('POST', '/ai/chat', body: {
      'question': question,
    });
    final data = res['data'] as Map<String, dynamic>;
    return data['reply'] as String? ?? 'Maaf, saya tidak dapat memproses jawaban.';
  }
}
