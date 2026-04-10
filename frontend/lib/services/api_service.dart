import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static String? _token;

  static Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'access_token');
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Map<String, String> _headers() {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  static Future<http.Response> _sendRequest(Future<http.Response> Function() reqFunc) async {
    http.Response resp = await reqFunc();

    if (resp.statusCode == 401) {
      final rfToken = await getRefreshToken();
      if (rfToken != null) {
        try {
          final refreshResp = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': rfToken}),
          ).timeout(ApiConfig.receiveTimeout);

          if (refreshResp.statusCode == 200) {
            final data = jsonDecode(refreshResp.body)['data'];
            await setToken(data['access_token']);
            if (data['refresh_token'] != null) {
              await setRefreshToken(data['refresh_token']);
            }
            _token = data['access_token'];
            resp = await reqFunc(); // retry original request
          } else {
            await clearToken();
          }
        } catch (_) {
          await clearToken();
        }
      }
    }
    return resp;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final token = await getToken();
    if (token != null) _token = token;
    final resp = await _sendRequest(() => http
        .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers())
        .timeout(ApiConfig.receiveTimeout));
    return _handleResponse(resp);
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token != null) _token = token;
    final resp = await _sendRequest(() => http
        .post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(), body: jsonEncode(body))
        .timeout(ApiConfig.receiveTimeout));
    return _handleResponse(resp);
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token != null) _token = token;
    final resp = await _sendRequest(() => http
        .put(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(), body: jsonEncode(body))
        .timeout(ApiConfig.receiveTimeout));
    return _handleResponse(resp);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final token = await getToken();
    if (token != null) _token = token;
    final resp = await _sendRequest(() => http
        .delete(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers())
        .timeout(ApiConfig.receiveTimeout));
    return _handleResponse(resp);
  }

  static Map<String, dynamic> _handleResponse(http.Response resp) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return body;
    }
    throw ApiException(resp.statusCode, body['detail']?.toString() ?? body['message']?.toString() ?? 'Unknown error');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
