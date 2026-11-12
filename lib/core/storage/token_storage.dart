import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_model.dart';

/// Persists authentication tokens, user profile, and Remember Me preferences.
class TokenStorage {
  static const String _keyJwt = 'auth_jwt';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserJson = 'auth_user_json';
  static const String _keyRememberMe = 'auth_remember_me';
  static const String _keySavedEmail = 'auth_saved_email';

  Future<void> saveSession({
    required String jwt,
    required String refreshToken,
    required UserModel user,
    required bool rememberMe,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJwt, jwt);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyUserJson, jsonEncode(user.toJson()));
    await prefs.setBool(_keyRememberMe, rememberMe);
    if (rememberMe) {
      await prefs.setString(_keySavedEmail, email);
    } else {
      await prefs.remove(_keySavedEmail);
    }
  }

  Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyJwt);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySavedEmail);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJwt);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserJson);
  }
}
