import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/device_info_helper.dart';
import 'core/log_printer.dart';
import 'core/logger_config.dart';
import 'domain/logger_entity.dart';
import 'domain/logger_repository.dart';
import 'domain/log_level.dart';
import 'domain/logger_config_entity.dart';
import 'data/logger_datasource.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static bool _initialized = false;
  static late LoggerRepository _repository;

  static Future<void> initialize({
    required FirebaseOptions firebaseOptions,
    LoggerConfigEntity? config,
  }) async {
    if (_initialized) return;
    LoggerConfig.config = config ?? LoggerConfigEntity();

    await Firebase.initializeApp(options: firebaseOptions);
    _repository = LoggerDatasource(FirebaseFirestore.instance);
    _initialized = true;
  }

  static Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    final isDebug = kDebugMode;
    final isRelease = kReleaseMode;

    LogPrinter.printLog(message, level, LoggerConfig.config);

    if (!_initialized) return;

    if ((isDebug && !LoggerConfig.config.enableInDebug) ||
        (isRelease && !LoggerConfig.config.enableInRelease)) {
      return;
    }

    final device = await DeviceInfoHelper.getDeviceModel();
    final platform = await DeviceInfoHelper.getPlatform();
    final appVersion = await DeviceInfoHelper.getAppVersion();

    final logEntity = LoggerEntity(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      device: device,
      platform: platform,
      appVersion: appVersion,
      extra: extra ?? {},
    );

    await _repository.saveLog(logEntity);
  }
}
