import 'package:billlens/features/receipt_scanner/domain/services/receipt_text_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptTextClassifier', () {
    test('accepts receipt text with total and transaction signals', () {
      const text = '''
Corner Market
2026-07-10
Milk 2.50
Bread 3.25
Subtotal 5.75
Tax 0.46
Total USD 6.21
Paid by card
''';

      expect(ReceiptTextClassifier.isLikelyReceipt(text), isTrue);
    });

    test('rejects empty OCR output', () {
      expect(ReceiptTextClassifier.isLikelyReceipt(''), isFalse);
    });

    test('rejects ordinary text containing an isolated price', () {
      const text = '''
SUMMER SALE
New styles have arrived
Starting from 50.00
Visit our website today
''';

      expect(ReceiptTextClassifier.isLikelyReceipt(text), isFalse);
    });
  });
}
