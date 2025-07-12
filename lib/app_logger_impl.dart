import 'dart:async';
import 'dart:convert';

import 'package:app_logger/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'data/logger_datasource.dart';
import 'domain/repositories/logger_repository.dart';

class AppLogger {
  static bool _initialized = false;
  static late LoggerRepository _repository;
  static late LoggerConfigEntity _config;

  static final _settingCollection =
      FirebaseFirestore.instance.collection('app_logs_setting');

  static Map<String, dynamic>? _settings;

  static Future<void> initialize({
    required FirebaseOptions firebaseOptions,
    LoggerConfigEntity? config,
  }) async {
    if (_initialized) return;

    _config = config ?? LoggerConfigEntity();
    await Firebase.initializeApp(options: firebaseOptions);
    _repository = LoggerDatasource(FirebaseFirestore.instance);

    // 🔁 Realtime settings listener
    _settingCollection.doc('settings').snapshots().listen(
      (snapshot) {
        _settings = snapshot.data();
        LogPrinter.printLog(
          'AppLogger',
          "✅ Logger settings updated",
          LogLevel.commonLogs,
          _config,
        );
      },
      onError: (error) {
        LogPrinter.printLog(
          'AppLogger',
          "⚠️ Logger settings listener error: $error",
          LogLevel.commonLogs,
          _config,
        );
      },
    );

    _initialized = true;
  }

  static Future<void> log(
    dynamic message, {
    String? name,
    LogLevel level = LogLevel.commonLogs,
  }) async {
    final formattedMessage = _formatMessage(message);
    LogPrinter.printLog(name, formattedMessage, level, _config);

    if (!_initialized || _settings == null) return;

    final isDebug = kDebugMode;
    final isRelease = kReleaseMode;

    if ((isDebug && !_config.enableInDebug) ||
        (isRelease && !_config.enableInRelease)) {
      return;
    }

    final data = _settings!;
    if (data['logOn'] != true) return;

    final shouldLogAll = data['allLogs'] == true;
    final shouldLogSpecific = _isAllowed(level, data);

    if (shouldLogAll || shouldLogSpecific) {
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

  static String _formatMessage(dynamic message) {
    try {
      if (message is Map) {
        return jsonEncode(message);
      }

      if (message is String) {
        try {
          final parsed = jsonDecode(message);
          return jsonEncode(parsed); // valid JSON string
        } catch (_) {
          final fixed = _fixPseudoJson(message);
          final parsed = jsonDecode(fixed);
          return jsonEncode(parsed);
        }
      }

      return jsonEncode(message);
    } catch (_) {
      return message.toString();
    }
  }

  static String _fixPseudoJson(String input) {
    final now = DateTime.now().toIso8601String();

    input = input.replaceAllMapped(
      RegExp(r'DateTime\.now\(\)\.toIso8601String\(\)'),
      (_) => '"$now"',
    );

    input = input.replaceAllMapped(
      RegExp(r'(\w+)\s*:\s*([^,{}]+)'),
      (match) {
        final key = match.group(1)?.trim();
        var value = match.group(2)?.trim();

        final isQuoted = value!.startsWith('"') ||
            value.startsWith("'") ||
            num.tryParse(value) != null;
        if (!isQuoted &&
            value != 'true' &&
            value != 'false' &&
            value != 'null') {
          value = '"$value"';
        }

        return '"$key": $value';
      },
    );

    input = input.replaceAll(RegExp(r',\s*}'), '}');

    return input;
  }
}
