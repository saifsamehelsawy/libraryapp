import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/user.dart';

class LocalUserService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _languageKey = 'app_language';

  final SharedPreferences _prefs;

  LocalUserService(this._prefs);

  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  User? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> setHasSeenOnboarding(bool hasSeen) async {
    await _prefs.setBool(_onboardingKey, hasSeen);
  }

  bool hasSeenOnboarding() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
