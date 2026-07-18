import 'dart:async';

/// Global signal for when the backend rejects the session (401/403/deleted).
/// Used by network interceptors to notify the UI to force a logout.
class AuthSessionManager {
  static final AuthSessionManager _instance = AuthSessionManager._internal();
  static AuthSessionManager get instance => _instance;

  AuthSessionManager._internal();

  final _invalidatedController = StreamController<void>.broadcast();

  Stream<void> get onInvalidated => _invalidatedController.stream;

  void invalidate() => _invalidatedController.add(null);
}
