class ReceiptTextClassifier {
  const ReceiptTextClassifier._();

  static final RegExp _amountPattern = RegExp(
    r'(?:[$€£₹৳]|USD|BDT|EUR|GBP|INR)\s*\d[\d,]*(?:\.\d{1,2})?'
    r'|\d[\d,]*[.,]\d{2}\s*(?:USD|BDT|EUR|GBP|INR)?',
    caseSensitive: false,
  );
  static final RegExp _totalPattern = RegExp(
    r'\b(?:grand\s+total|sub\s*total|total|amount\s+due|net\s+amount)\b',
    caseSensitive: false,
  );
  static final RegExp _documentPattern = RegExp(
    r'\b(?:receipt|invoice|bill|order)\b',
    caseSensitive: false,
  );
  static final RegExp _taxPattern = RegExp(
    r'\b(?:tax|vat|gst|sales\s+tax)\b',
    caseSensitive: false,
  );
  static final RegExp _paymentPattern = RegExp(
    r'\b(?:cash|card|credit|debit|payment|paid|change|tender)\b',
    caseSensitive: false,
  );
  static final RegExp _itemPattern = RegExp(
    r'\b(?:qty|quantity|item|price|unit)\b',
    caseSensitive: false,
  );
  static final RegExp _datePattern = RegExp(
    r'\b(?:\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{4}[-/.]\d{1,2}[-/.]\d{1,2})\b',
  );

  static bool isLikelyReceipt(String recognizedText) {
    final text = recognizedText.trim();
    if (text.length < 12) return false;

    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final hasAmount = _amountPattern.hasMatch(text);
    final hasTotal = _totalPattern.hasMatch(text);
    var score = 0;

    if (hasAmount) score += 2;
    if (hasTotal) score += 2;
    if (_documentPattern.hasMatch(text)) score += 1;
    if (_taxPattern.hasMatch(text)) score += 1;
    if (_paymentPattern.hasMatch(text)) score += 1;
    if (_itemPattern.hasMatch(text)) score += 1;
    if (_datePattern.hasMatch(text)) score += 1;
    if (lines.length >= 4) score += 1;

    return score >= 4 && (hasAmount || hasTotal);
  }
}