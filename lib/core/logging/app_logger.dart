import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void error(String message, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message (${error.runtimeType})');
    }
  }
}
