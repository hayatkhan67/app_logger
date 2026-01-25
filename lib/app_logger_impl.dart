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

  // Cached device info (avoid repeated async calls)
  static String _cachedDevice = '';
  static String _cachedPlatform = '';
  static String _cachedAppVersion = '';

  // Log batching
  static final List<LoggerEntity> _buffer = [];
  static Timer? _flushTimer;
  static const _batchSize = 10;
  static const _flushInterval = Duration(seconds: 5);

  static Future<void> initialize({
    required FirebaseOptions firebaseOptions,
    LoggerConfigEntity? config,
  }) async {
    if (_initialized) return;

    _config = config ?? LoggerConfigEntity();
    await Firebase.initializeApp(options: firebaseOptions);
    _repository = LoggerDatasource(FirebaseFirestore.instance);

    // Cache device info once
    _cachedDevice = await DeviceInfoHelper.getDeviceModel();
    _cachedPlatform = await DeviceInfoHelper.getPlatform();
    _cachedAppVersion = await DeviceInfoHelper.getAppVersion();

    final docRef = _settingCollection.doc('settings');

    // Check if 'settings' document exists
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'logOn': true,
        'allLogs': false,
        'commonLogs': false,
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

    // Realtime settings listener
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
    // Skip null/empty messages
    if (message == null) return;
    final msgStr = message.toString().trim();
    if (msgStr.isEmpty) return;

    // Fail fast if not initialized
    assert(_initialized,
        'AppLogger has not been initialized. Call AppLogger.initialize() first.');
    if (!_initialized) {
      throw StateError(
        'AppLogger has not been initialized. Call AppLogger.initialize() before logging.',
      );
    }

    final formattedMessage = await formatMessage(message);
    LogPrinter.printLog(name, formattedMessage, level, _config);

    if (_settings == null) return;

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
      final String logName = (name?.isNotEmpty ?? false) ? name! : '';
      final logEntity = LoggerEntity(
        message: formattedMessage,
        level: level,
        name: logName,
        time: DateTime.now(),
        device: _cachedDevice,
        platform: _cachedPlatform,
        version: _cachedAppVersion,
      );

      await _addToBuffer(logEntity);
    }
  }

  /// Add log to buffer and flush when ready
  static Future<void> _addToBuffer(LoggerEntity log) async {
    _buffer.add(log);

    if (_buffer.length >= _batchSize) {
      await _flush();
    } else {
      _flushTimer?.cancel();
      _flushTimer = Timer(_flushInterval, _flush);
    }
  }

  /// Flush buffered logs to Firestore
  static Future<void> _flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_buffer.isEmpty) return;

    final logsToFlush = List<LoggerEntity>.from(_buffer);
    _buffer.clear();
    await _repository.saveLogs(logsToFlush);
  }

  /// Force flush remaining logs (call on app dispose)
  static Future<void> dispose() async {
    await _flush();
  }
}
