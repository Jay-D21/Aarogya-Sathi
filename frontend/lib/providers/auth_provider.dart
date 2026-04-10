import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoading      => _isLoading;
  bool get isLoggedIn     => _isLoggedIn;
  bool get isGuest        => _isGuest;
  String? get error       => _error;
  Map<String, dynamic>? get user => _user;

  /// True when a guest user hasn't completed onboarding yet.
  /// Used by splash to route incomplete profiles back to /onboarding.
  bool get needsOnboarding {
    if (!_isGuest) return false;
    final name = _user?['first_name'] as String?;
    return name == null || name.isEmpty || name == 'Guest' ||
        _user?['height_cm'] == null;
  }

  /// Initiate guest login
  Future<void> skipLogin() async {
    _isGuest = true;
    _isLoggedIn = true;
    
    // Attempt to load existing guest profile
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('guest_profile');
    if (profileStr != null) {
      _user = jsonDecode(profileStr);
    } else {
      _user = {
        'id': 'guest',
        'first_name': 'Guest',
        'email': 'guest@aarogyasathi.in',
      };
    }
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _user = {...?_user, ...data};
    if (_isGuest) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_profile', jsonEncode(_user));
    } else {
      // Note: PUT /auth/me for real users
    }
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Restore guest session if previously active
    if (prefs.getString('guest_profile') != null) {
      await skipLogin();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final resp = await ApiService.get('/auth/me');
        _user = resp['data'] as Map<String, dynamic>?;
        _isLoggedIn = true;
      } catch (_) {
        // Token expired or backend unreachable — stay logged out
        await ApiService.clearToken();
        _isLoggedIn = false;
      }
    }

    _isLoading = false;
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
      final Map<String, dynamic> data = {
        'email': email,
        'phone': phone,
        'password': password,
        'first_name': firstName,
      };
      if (lastName != null) data['last_name'] = lastName;
      if (city != null) data['preferred_city'] = city;
      await ApiService.post('/auth/register', data);
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
