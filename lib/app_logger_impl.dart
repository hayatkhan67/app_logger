import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'core/device_info_helper.dart';
import 'core/log_printer.dart';
import 'data/logger_datasource.dart';
import 'domain/entities/logger_entity.dart';
import 'domain/repositories/logger_repository.dart';
import 'domain/value_objects/log_level.dart';
import 'shared/log_filter.dart';
import 'shared/log_formatter.dart';
import 'shared/logger_config_entity.dart';

class AppLogger {
  static bool _initialized = false;
  static late LoggerRepository _repository;
  static late LoggerConfigEntity _config;

  static final _settingCollection =
      FirebaseFirestore.instance.collection('app_logs_setting');

  static Map<String, dynamic>? _settings;

  // static Future<void> initialize({
  //   required FirebaseOptions firebaseOptions,
  //   LoggerConfigEntity? config,
  // }) async {
  //   if (_initialized) return;

  //   _config = config ?? LoggerConfigEntity();
  //   await Firebase.initializeApp(options: firebaseOptions);
  //   _repository = LoggerDatasource(FirebaseFirestore.instance);

  //   // 🔁 Realtime settings listener
  //   _settingCollection.doc('settings').snapshots().listen(
  //     (snapshot) {
  //       _settings = snapshot.data();
  //       LogPrinter.printLog(
  //         'AppLogger',
  //         "✅ Logger settings updated",
  //         LogLevel.commonLogs,
  //         _config,
  //       );
  //     },
  //     onError: (error) {
  //       LogPrinter.printLog(
  //         'AppLogger',
  //         "⚠️ Logger settings listener error: $error",
  //         LogLevel.commonLogs,
  //         _config,
  //       );
  //     },
  //   );

  //   _initialized = true;
  // }

  static Future<void> initialize({
    required FirebaseOptions firebaseOptions,
    LoggerConfigEntity? config,
  }) async {
    if (_initialized) return;

    _config = config ?? LoggerConfigEntity();
    await Firebase.initializeApp(options: firebaseOptions);
    _repository = LoggerDatasource(FirebaseFirestore.instance);

    final docRef = _settingCollection.doc('settings');

    // ✅ Check if 'settings' document exists
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'logOn': true,
        'allLogs': false,
        'commonLogs': true,
        'apiError': true,
        'apiResponse': false,
        'apiHeaders': false,
        'apiPayload': false,
        'apiEndpoint': false,
        'stackTrace': true,
      });

      LogPrinter.printLog(
        'AppLogger',
        "🆕 Logger settings document created in Firestore",
        LogLevel.commonLogs,
        _config,
      );
    }

    // 🔁 Realtime settings listener
    docRef.snapshots().listen(
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
    final formattedMessage = await formatMessage(message);
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
    final shouldLogSpecific = isAllowed(level, data);

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
}
