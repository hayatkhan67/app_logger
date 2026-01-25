import 'package:flutter/foundation.dart';

import '../domain/value_objects/log_level.dart';
import '../shared/logger_config_entity.dart';

class LogPrinter {
  static void printLog(
    String? name,
    String message,
    LogLevel level,
    LoggerConfigEntity config,
  ) {
    final String logName = (name?.isNotEmpty ?? false) ? name! : '';
    final color = config.logColors[level] ?? '';
    const resetColor = '\x1B[0m';

    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final levelLabel = level.name.toUpperCase();

      final prefixParts = [
        '$color[$timestamp]',
        '[$levelLabel]',
        if (logName.isNotEmpty) '[$logName]',
      ];
      final prefix = prefixParts.join(' ');

      // Use debugPrint which handles large messages better
      debugPrint(
        '$prefix $message$resetColor',
        wrapWidth: 1024, // Adjust as needed
      );
    }
  }
}
