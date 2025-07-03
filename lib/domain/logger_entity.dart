import 'log_level.dart';

class LoggerEntity {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String device;
  final String platform;
  final String appVersion;
  final Map<String, dynamic> extra;

  LoggerEntity({
    required this.message,
    required this.level,
    required this.timestamp,
    required this.device,
    required this.platform,
    required this.appVersion,
    this.extra = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      "log": message,
      "level": level.name,
      "timestamp": timestamp.toUtc().toIso8601String(),
      "device": device,
      "platform": platform,
      "appVersion": appVersion,
      "extra": extra,
    };
  }
}
