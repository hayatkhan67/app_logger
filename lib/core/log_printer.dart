import 'package:flutter/foundation.dart';

import '../domain/log_level.dart';
import '../domain/logger_config_entity.dart';

class LogPrinter {
  static void printLog(
      String? name, String message, LogLevel level, LoggerConfigEntity config) {
    final color = config.logColors[level] ?? '';
    const resetColor = '\x1B[0m';

    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print(
          '$color[$timestamp] [${level.name.toUpperCase()}] [$name] $message$resetColor');
    }
  }
}
