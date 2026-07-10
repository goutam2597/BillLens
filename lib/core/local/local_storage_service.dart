import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Centralized local preferences storage for app-wide settings,
/// onboarding state, and simple key-value persistence.
@singleton
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _onboardingComplete = 'onboarding_complete';
  static const _themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _currency = 'currency';
  static const _notificationsEnabled = 'notifications_enabled';
  static const _biometricEnabled = 'biometric_enabled';

  // ── Onboarding ────────────────────────────────────────────────────────────

  bool get onboardingComplete => _prefs.getBool(_onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingComplete, value);
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  String get themeMode => _prefs.getString(_themeMode) ?? 'light';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeMode, mode);
  }

  // ── Currency ──────────────────────────────────────────────────────────────

  String get currency => _prefs.getString(_currency) ?? 'USD';

  Future<void> setCurrency(String currency) async {
    await _prefs.setString(_currency, currency);
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  bool get notificationsEnabled => _prefs.getBool(_notificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsEnabled, value);
  }

  // ── Biometric ─────────────────────────────────────────────────────────────

  bool get biometricEnabled => _prefs.getBool(_biometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(_biometricEnabled, value);
  }

  // ── Generic ───────────────────────────────────────────────────────────────

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
