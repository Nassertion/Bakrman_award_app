import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final SharedPreferences _prefs;

  AuthStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_userKey, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final rawJson = _prefs.getString(_userKey);
    if (rawJson == null) return null;
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  bool isAuthenticated() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
