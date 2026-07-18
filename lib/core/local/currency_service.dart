import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_storage_service.dart';
import '../di/injection.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

/// Single Source of Truth helper for currency across the app.
///
/// Server user currency > local prefs > USD.
/// Keeps ValueNotifier in sync so UI rebuilds instantly.
@singleton
class CurrencyService {
  CurrencyService(this._storage, this._authLocal) {
    // Initialize from persisted value
    final init = _storage.currency.trim().toUpperCase();
    _notifier.value = init.isNotEmpty ? init : 'USD';
    // Re-resolve from secure cache async
    _resolve().then((c) => _notifier.value = c);
    // Keep in sync when LocalStorage currency changes
    LocalStorageService.currencyNotifier.addListener(() {
      final v = LocalStorageService.currencyNotifier.value;
      if (v.isNotEmpty) {
        _notifier.value = v.toUpperCase();
      }
    });
  }

  final LocalStorageService _storage;
  final AuthLocalDataSource _authLocal;

  static final ValueNotifier<String> _notifier = ValueNotifier<String>('USD');
  static ValueNotifier<String> get notifier => _notifier;
  static String get current => _notifier.value;

  Future<String> _resolve() async {
    try {
      final cached = await _authLocal.getCachedUser();
      final uc = cached?.currency.trim().toUpperCase();
      if (uc != null && uc.isNotEmpty) return uc;
    } catch (_) {}
    final local = _storage.currency.trim().toUpperCase();
    if (local.isNotEmpty) return local;
    return 'USD';
  }

  static String resolveSync([String? explicit]) {
    if (explicit != null && explicit.trim().isNotEmpty) {
      return explicit.trim().toUpperCase();
    }
    final n = _notifier.value.trim().toUpperCase();
    if (n.isNotEmpty) return n;
    try {
      if (getIt.isRegistered<LocalStorageService>()) {
        final l = getIt<LocalStorageService>().currency.trim().toUpperCase();
        if (l.isNotEmpty) return l;
      }
    } catch (_) {}
    return 'USD';
  }

  Future<String> resolveCurrencyAsync([String? explicit]) async {
    if (explicit != null && explicit.trim().isNotEmpty) {
      return explicit.trim().toUpperCase();
    }
    final code = await _resolve();
    _notifier.value = code;
    return code;
  }

  Future<void> syncFromServer(String serverCurrency) async {
    final code = serverCurrency.trim().toUpperCase();
    if (code.isEmpty) return;
    await _storage.syncCurrencyFromServer(code);
    _notifier.value = code;
  }

  Future<void> confirmChange(String code) async {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return;
    await _storage.setCurrency(c);
    _notifier.value = c;
  }
}
