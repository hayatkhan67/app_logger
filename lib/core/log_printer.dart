import 'package:flutter/foundation.dart';

import '../domain/log_level.dart';
import '../domain/logger_config_entity.dart';

class LogPrinter {
  static void printLog(String message, LogLevel level, LoggerConfigEntity config) {
    final color = config.logColors[level] ?? '';
    const resetColor = '\x1B[0m';

    if (kDebugMode) {
      print('$color[${level.name.toUpperCase()}] $message$resetColor');
    }
  }
}
