import 'dart:async';

import 'package:injectable/injectable.dart';

/// Type of change for cross-screen expense notifications.
enum ExpenseChangeType {
  created,
  updated,
  deleted,
  synced,
}

class ExpenseChangeEvent {
  final ExpenseChangeType type;
  final String? id;

  const ExpenseChangeEvent({
    required this.type,
    this.id,
  });
}

/// Broadcasts expense changes so that Dashboard, Analytics, Details and List
/// screens can react without each screen knowing about the others' BLoCs.
@singleton
class ExpenseChangeNotifier {
  final _controller = StreamController<ExpenseChangeEvent>.broadcast();

  Stream<ExpenseChangeEvent> get stream => _controller.stream;

  void notify(ExpenseChangeType type, {String? id}) {
    if (_controller.isClosed) return;
    _controller.add(ExpenseChangeEvent(type: type, id: id));
  }

  void dispose() {
    _controller.close();
  }
}
