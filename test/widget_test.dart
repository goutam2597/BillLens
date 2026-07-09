// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:billlens/app.dart';

void main() {
  testWidgets('BillLens smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BillLensApp());
    // App should start without throwing
    expect(tester.takeException(), isNull);
  });
}
