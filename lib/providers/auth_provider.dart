import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.post('/auth/login', {'email': email, 'password': password});
      if (data is Map && data.containsKey('token')) {
        await _saveToken(data['token']);
        _user = data.containsKey('user') ? data['user'] : null;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.post('/auth/register', {'name': name, 'email': email, 'password': password});
      if (data is Map && data.containsKey('token')) {
        await _saveToken(data['token']);
        _user = data.containsKey('user') ? data['user'] : null;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.post('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/auth/me'); 
      _user = data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (e) {
      print('fetchProfile fail: $e');
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }
}
