import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [Listenable] that notifies [GoRouter] to re-run its redirect whenever the
/// supplied [Stream] (typically a BLoC's state stream) emits a new value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
