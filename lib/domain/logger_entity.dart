import '../app_logger.dart';

class LoggerEntity {
  final String message;
  final LogLevel level;
  final DateTime time;
  final String device;
  final String platform;
  final String version;

  LoggerEntity({
    required this.message,
    required this.level,
    required this.time,
    required this.device,
    required this.platform,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "level": level.name,
      "time": time.toUtc().toIso8601String(),
      "device": device,
      "platform": platform,
      "version": version,
    };
  }
}
