import '../app_logger.dart';

class LoggerConfigEntity {
  final bool enableInDebug;
  final bool enableInRelease;
  final Map<LogLevel, String> logColors;

  LoggerConfigEntity({
    this.enableInDebug = true,
    this.enableInRelease = true,
    Map<LogLevel, String>? logColors,
  }) : logColors =
           logColors ??
           {
             LogLevel.apiError: '\x1B[31m',
             LogLevel.apiResponse: '\x1B[32m',
             LogLevel.apiHeaders: '\x1B[33m',
             LogLevel.apiBody: '\x1B[34m',
             LogLevel.apiUrl: '\x1B[35m',
             LogLevel.stackTrace: '\x1B[36m',
             LogLevel.unkown: '\x1B[37m',
           };
}
