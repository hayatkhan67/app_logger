import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app_logger.dart';

class LoggerEntity {
  final String message;
  final LogLevel level;
  final DateTime time;
  final String device;
  final String platform;
  final String version;
  final String? name; // Optional name for the logger

  LoggerEntity({
    required this.message,
    required this.level,
    required this.time,
    required this.device,
    required this.platform,
    required this.version,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "message": message,
      "level": level.name,
      'time': FieldValue.serverTimestamp(),
      "device": device,
      "platform": platform,
      "version": version,
    };
  }
}
