class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class LimitExceededException implements Exception {
  final String message;
  final String code; // SCAN_LIMIT_EXCEEDED / MANUAL_LIMIT_EXCEEDED
  final Map<String, dynamic>? usage;

  LimitExceededException(
    this.message, {
    required this.code,
    this.usage,
  });
}

class DuplicateException implements Exception {
  final String message;
  final Map<String, dynamic>? existingExpense;

  DuplicateException(this.message, {this.existingExpense});
}
