import 'package:logger/logger.dart';

/// Centralized application logger built on top of the `logger` package.
///
/// Prefer these static helpers over `print()` or `debugPrint()` so logs are
/// consistently formatted and easy to filter by severity.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    filter: DevelopmentFilter(),
  );

  /// Verbose / fine-grained debug information.
  static void v(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  /// General debug information useful during development.
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// Informational messages (network requests, lifecycle events, etc.).
  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// Warning messages for potentially harmful situations.
  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Error messages for failures that should be investigated.
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
