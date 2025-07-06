import 'dart:async';
import 'dart:convert';
import 'package:app_logger/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'data/logger_datasource.dart';
import 'domain/logger_repository.dart';

class AppLogger {
  static bool _initialized = false;
  static late LoggerRepository _repository;
  static late LoggerConfigEntity _config;

  static final _settingCollection =
      FirebaseFirestore.instance.collection('app_logs_setting');

  static Future<void> initialize({
    required FirebaseOptions firebaseOptions,
    LoggerConfigEntity? config,
  }) async {
    if (_initialized) return;

    _config = config ?? LoggerConfigEntity();
    await Firebase.initializeApp(options: firebaseOptions);
    _repository = LoggerDatasource(FirebaseFirestore.instance);
    _initialized = true;
  }

  static Future<void> log(
    dynamic message, {
    ///preffer to set name to identify the log source
    String? name,
    LogLevel level = LogLevel.commonLogs,
  }) async {
    final formattedMessage = _formatMessage(message);

    LogPrinter.printLog(name, formattedMessage, level, _config);

    if (!_initialized) return;

    final isDebug = kDebugMode;
    final isRelease = kReleaseMode;

    if ((isDebug && !_config.enableInDebug) ||
        (isRelease && !_config.enableInRelease)) {
      return;
    }

    try {
      final res = await _settingCollection
          .doc('settings')
          .get()
          .timeout(const Duration(seconds: 5));

      final data = res.data();

      if (data == null) return;

      final logAll = data['allLogs'] == true;

      if (logAll || _isAllowed(level, data)) {
        final device = await DeviceInfoHelper.getDeviceModel();
        final platform = await DeviceInfoHelper.getPlatform();
        final appVersion = await DeviceInfoHelper.getAppVersion();

        final logEntity = LoggerEntity(
          message: formattedMessage,
          level: level,
          name: name ?? 'AppLogger',
          time: DateTime.now(),
          device: device,
          platform: platform,
          version: appVersion,
        );

        await _repository.saveLog(logEntity);
      }
    } on TimeoutException {
      LogPrinter.printLog(
        name,
        "⚠️ Log settings fetch timed out",
        LogLevel.commonLogs,
        _config,
      );
    } catch (e) {
      LogPrinter.printLog(
        name,
        "⚠️ Error fetching log settings: $e",
        LogLevel.commonLogs,
        _config,
      );
    }
  }

  static bool _isAllowed(LogLevel level, Map<String, dynamic> data) {
    switch (level) {
      case LogLevel.apiError:
        return data['apiError'] == true;
      case LogLevel.apiResponse:
        return data['apiResponse'] == true;
      case LogLevel.apiHeaders:
        return data['apiHeaders'] == true;
      case LogLevel.apiBody:
        return data['apiPayload'] == true;
      case LogLevel.endPoint:
        return data['apiEndpoint'] == true;
      case LogLevel.stackTrace:
        return data['stackTrace'] == true;
      case LogLevel.commonLogs:
      default:
        return data['commonLogs'] == true;
    }
  }

  /// Converts message to proper JSON-safe String
  static String _formatMessage(dynamic message) {
    try {
      if (message is String) {
        return message; // Direct string return, extra quotes avoid
      }
      return jsonEncode(message);
    } catch (_) {
      return message.toString();
    }
  }
}
