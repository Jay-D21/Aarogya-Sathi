import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final resp = await ApiService.get('/auth/me');
        _user = resp['data'] as Map<String, dynamic>?;
        _isLoggedIn = true;
      } catch (_) {
        await ApiService.clearToken();
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    String? lastName,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.post('/auth/register', {
        'email': email,
        'phone': phone,
        'password': password,
        'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (city != null) 'preferred_city': city,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final data = resp['data'] as Map<String, dynamic>;
      await ApiService.setToken(data['access_token']);
      await ApiService.setRefreshToken(data['refresh_token']);
      _isLoggedIn = true;
      // Fetch profile
      final profile = await ApiService.get('/auth/me');
      _user = profile['data'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    await ApiService.clearToken();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
