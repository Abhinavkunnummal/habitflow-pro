import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String _keyAuthToken = 'habitflow_auth_token_v1';
  static const String _keyAuthUser = 'habitflow_auth_user_v1';
  static const String _keyCustomBaseUrl = 'habitflow_custom_base_url_v1';

  final SharedPreferences _prefs;

  SessionStorage(this._prefs);

  static Future<SessionStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionStorage(prefs);
  }

  // --- Token Management ---
  String? getToken() {
    return _prefs.getString(_keyAuthToken);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  bool get hasToken => _prefs.containsKey(_keyAuthToken) && (_prefs.getString(_keyAuthToken)?.isNotEmpty ?? false);

  // --- Cached User Profile ---
  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(_keyAuthUser);
    if (userStr == null || userStr.isEmpty) return null;
    try {
      return json.decode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_keyAuthUser, json.encode(userMap));
  }

  Future<void> clearUser() async {
    await _prefs.remove(_keyAuthUser);
  }

  // --- Complete Session Teardown (Logout / Switch User) ---
  Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }

  // --- Dynamic Base URL (for testing physical phone on LAN or Cloud) ---
  String? getCustomBaseUrl() {
    return _prefs.getString(_keyCustomBaseUrl);
  }

  Future<void> setCustomBaseUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      await _prefs.remove(_keyCustomBaseUrl);
    } else {
      await _prefs.setString(_keyCustomBaseUrl, trimmed);
    }
  }
}
