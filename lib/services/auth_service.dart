// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  /// Base da API vindo do --dart-define=API_BASE
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:3000',
  );

  // ====== Armazenamento de token (seguro no mobile, prefs no web) ======

  static const _tokenKey = 'auth_token';

  Future<void> _storeToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } else {
      const storage = FlutterSecureStorage();
      return await storage.read(key: _tokenKey);
    }
  }

  Future<void> clearToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: _tokenKey);
    }
  }

  // Opcionalmente útil se você precisar setar manualmente (ex.: deep link)
  Future<void> setToken(String token) => _storeToken(token);

  // ====== Helpers HTTP ======

  Uri _uri(String path) {
    // Garante que não duplique barras
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Map<String, String> _headers({String? authToken}) {
    return {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };
  }

  dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return {};
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return {};
    }
  }

  Never _throwHttpError(http.Response res, dynamic data) {
    final msg = (data is Map && data['error'] is String)
        ? data['error'] as String
        : 'HTTP ${res.statusCode}';
    throw Exception(msg);
  }

  // ====== Endpoints de autenticação ======

  /// POST /auth/register
  /// Retorna { user: {...}, token: '...' }
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final uri = _uri('/auth/register');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        if (nickname != null && nickname.trim().isNotEmpty) 'nickname': nickname.trim(),
      }),
    );

    final data = _decode(res);
    if (res.statusCode >= 400) _throwHttpError(res, data);

    // guarda token
    final token = (data is Map) ? data['token'] as String? : null;
    if (token != null) await _storeToken(token);

    return Map<String, dynamic>.from(data as Map);
    // Ex.: { user: {id, email, ...}, token: '...' }
  }

  /// POST /auth/login
  /// Retorna { user: {...}, token: '...' }
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final uri = _uri('/auth/login');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = _decode(res);
    if (res.statusCode >= 400) _throwHttpError(res, data);

    // guarda token
    final token = (data is Map) ? data['token'] as String? : null;
    if (token != null) await _storeToken(token);

    return Map<String, dynamic>.from(data as Map);
  }

  /// GET /auth/me
  /// Retorna { user: {...} }
  Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Não autenticado');
    }

    final uri = _uri('/auth/me');
    final res = await http.get(uri, headers: _headers(authToken: token));
    final data = _decode(res);
    if (res.statusCode >= 400) _throwHttpError(res, data);

    // data esperado: { user: {...} }
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> logout() => clearToken();

  Future<bool> isLoggedIn() async => (await getToken())?.isNotEmpty == true;

  /// Conveniência para descobrir se o usuário atual é admin
  Future<bool> isAdmin() async {
    try {
      final me = await getMe(); // { user: {...} }
      final user = me['user'];
      if (user is Map && user['is_admin'] == true) return true;
      return false;
    } catch (_) {
      return false;
    }
  }
}
