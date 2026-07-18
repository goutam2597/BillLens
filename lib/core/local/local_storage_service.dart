import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Centralized local preferences storage for app-wide settings,
/// onboarding state, and simple key-value persistence.
@singleton
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs) {
    // Initialize notifier with persisted value so that first listeners get correct currency
    final initial = _prefs.getString(_currency) ?? 'USD';
    _currencyNotifier.value = initial;
  }

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _onboardingComplete = 'onboarding_complete';
  static const _themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _currency = 'currency';
  static const _notificationsEnabled = 'notifications_enabled';
  static const _biometricEnabled = 'biometric_enabled';

  // Reactive notifier for currency changes — single source of truth for UI that
  // relies on SharedPreferences. All currency writes must go through setCurrency.
  static final ValueNotifier<String> _currencyNotifier =
      ValueNotifier<String>('USD');
  static ValueNotifier<String> get currencyNotifier => _currencyNotifier;

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

  String get currency => _prefs.getString(_currency) ?? _currencyNotifier.value;

  Future<void> setCurrency(String currency) async {
    final code = currency.toUpperCase().trim();
    if (code.isEmpty) return;
    await _prefs.setString(_currency, code);
    _currencyNotifier.value = code;
  }

  /// Sync without triggering extra persistence races — used internally when server is SOT
  Future<void> syncCurrencyFromServer(String currencyCode) async {
    final code = currencyCode.toUpperCase().trim();
    if (code.isEmpty) return;
    if (_prefs.getString(_currency) == code && _currencyNotifier.value == code) return;
    await _prefs.setString(_currency, code);
    _currencyNotifier.value = code;
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
