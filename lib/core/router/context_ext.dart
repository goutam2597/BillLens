import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SafePopExtension on BuildContext {
  /// Pops the current route if there is a route below it; otherwise navigates
  /// to [fallbackLocation]. This prevents "There is nothing to pop" crashes
  /// when a page is reached via `context.go` rather than `context.push`.
  void safePop(String fallbackLocation) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackLocation);
    }
  }
}
