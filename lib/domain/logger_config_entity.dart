
import 'log_level.dart';

class LoggerConfigEntity {
  final bool enableInDebug;
  final bool enableInRelease;
  final Map<LogLevel, String> logColors;

  LoggerConfigEntity({
    this.enableInDebug = true,
    this.enableInRelease = true,
    Map<LogLevel, String>? logColors,
  }) : logColors = logColors ?? {
    LogLevel.info: '\x1B[32m',
    LogLevel.warning: '\x1B[33m',
    LogLevel.error: '\x1B[31m',
    LogLevel.critical: '\x1B[35m',
  };
}