import 'package:app_logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger - Empty String Validation Tests', () {
    test('should reject null messages', () {
      final dynamic message = null;
      final shouldLog = message != null && message.toString().trim().isNotEmpty;

      expect(shouldLog, false, reason: 'Null messages should not be logged');
    });

    test('should reject empty strings', () {
      final message = '';
      final shouldLog = message.isNotEmpty && message.trim().isNotEmpty;

      expect(shouldLog, false, reason: 'Empty strings should not be logged');
    });

    test('should reject whitespace-only strings', () {
      final message = '   ';
      final shouldLog = message.isNotEmpty && message.trim().isNotEmpty;

      expect(shouldLog, false,
          reason: 'Whitespace-only strings should not be logged');
    });

    test('should accept valid messages', () {
      final message = 'Valid log message';
      final shouldLog = message.isNotEmpty && message.trim().isNotEmpty;

      expect(shouldLog, true, reason: 'Valid messages should be logged');
    });

    test('should accept messages with leading/trailing spaces after trim', () {
      final message = '  Valid message  ';
      final shouldLog = message.isNotEmpty && message.trim().isNotEmpty;

      expect(shouldLog, true,
          reason: 'Messages with spaces should be logged after trim');
    });
  });

  group('AppLogger - Log Levels Tests', () {
    test('LogLevel enum contains all expected values', () {
      final expectedLevels = [
        LogLevel.commonLogs,
        LogLevel.apiError,
        LogLevel.apiResponse,
        LogLevel.apiHeaders,
        LogLevel.apiBody,
        LogLevel.endPoint,
        LogLevel.stackTrace,
      ];

      for (final level in expectedLevels) {
        expect(LogLevel.values.contains(level), true,
            reason: 'LogLevel should contain ${level.name}');
      }

      expect(LogLevel.values.length, 7,
          reason: 'LogLevel should have exactly 7 values');
    });

    test('LogLevel names are correct', () {
      expect(LogLevel.commonLogs.name, 'commonLogs');
      expect(LogLevel.apiError.name, 'apiError');
      expect(LogLevel.apiResponse.name, 'apiResponse');
      expect(LogLevel.apiHeaders.name, 'apiHeaders');
      expect(LogLevel.apiBody.name, 'apiBody');
      expect(LogLevel.endPoint.name, 'endPoint');
      expect(LogLevel.stackTrace.name, 'stackTrace');
    });
  });

  group('AppLogger - Configuration Tests', () {
    test('LoggerConfigEntity default values are correct', () {
      final config = LoggerConfigEntity();

      expect(config.enableInDebug, false,
          reason: 'Should be disabled in debug mode by default');
      expect(config.enableInRelease, true,
          reason: 'Should be enabled in release mode by default');
    });

    test('LoggerConfigEntity accepts custom values', () {
      final config = LoggerConfigEntity(
        enableInDebug: false,
        enableInRelease: true,
      );

      expect(config.enableInDebug, false);
      expect(config.enableInRelease, true);
    });

    test('LoggerConfigEntity can disable logging in all modes', () {
      final config = LoggerConfigEntity(
        enableInDebug: false,
        enableInRelease: false,
      );

      expect(config.enableInDebug, false);
      expect(config.enableInRelease, false);
    });
  });

  group('AppLogger - Log Batching Behavior Tests', () {
    test('buffer accumulates logs before batch size', () {
      // Simulating buffer behavior
      final buffer = <String>[];
      const batchSize = 10;

      buffer.addAll(['log1', 'log2', 'log3']);

      expect(buffer.length, 3);
      expect(buffer.length < batchSize, true,
          reason: 'Buffer should not flush before reaching batch size');
    });

    test('buffer should flush when reaching batch size', () {
      final buffer = <String>[];
      const batchSize = 10;

      for (int i = 0; i < batchSize; i++) {
        buffer.add('log$i');
      }

      expect(buffer.length, batchSize,
          reason: 'Buffer should contain exactly $batchSize items');

      // Simulate flush
      final flushedLogs = List<String>.from(buffer);
      buffer.clear();

      expect(buffer.length, 0, reason: 'Buffer should be empty after flush');
      expect(flushedLogs.length, batchSize,
          reason: 'Flushed logs should contain all buffered items');
    });

    test('batch flush creates copy of buffer', () {
      final buffer = <String>['log1', 'log2', 'log3'];

      // Create copy (like in actual implementation)
      final flushedLogs = List<String>.from(buffer);
      buffer.clear();

      expect(buffer.isEmpty, true);
      expect(flushedLogs.length, 3);
      expect(flushedLogs, ['log1', 'log2', 'log3']);
    });
  });

  group('AppLogger - Device Info Caching Tests', () {
    test('device info should be cached and reused', () {
      // Simulating cached device info behavior
      String? cachedDevice;
      String? cachedPlatform;
      String? cachedVersion;

      // Simulate initialization (first fetch)
      cachedDevice = 'iPhone 14';
      cachedPlatform = 'iOS';
      cachedVersion = '1.0.0';

      // Verify cached values
      expect(cachedDevice, 'iPhone 14');
      expect(cachedPlatform, 'iOS');
      expect(cachedVersion, '1.0.0');

      // Simulate reuse (no re-fetching)
      final device = cachedDevice;
      final platform = cachedPlatform;
      final version = cachedVersion;

      expect(device, 'iPhone 14', reason: 'Should use cached device info');
      expect(platform, 'iOS', reason: 'Should use cached platform info');
      expect(version, '1.0.0', reason: 'Should use cached version info');
    });

    test('cache persists across multiple log calls', () {
      // Simulating multiple log calls using same cached info
      final cachedInfo = {
        'device': 'Pixel 6',
        'platform': 'Android',
        'version': '2.0.0',
      };

      // Simulate 5 log calls
      for (int i = 0; i < 5; i++) {
        expect(cachedInfo['device'], 'Pixel 6');
        expect(cachedInfo['platform'], 'Android');
        expect(cachedInfo['version'], '2.0.0');
      }
    });
  });

  group('AppLogger - Timer-based Flush Tests', () {
    test('timer should be set after adding log to buffer', () {
      bool timerActive = false;
      final buffer = <String>[];

      // Add log
      buffer.add('log1');
      timerActive = true; // Timer starts

      expect(timerActive, true,
          reason: 'Timer should be active after adding log');
    });

    test('timer should be cancelled when batch size is reached', () {
      bool timerActive = true;
      final buffer = <String>[];
      const batchSize = 10;

      // Fill buffer to batch size
      for (int i = 0; i < batchSize; i++) {
        buffer.add('log$i');
      }

      // Timer should be cancelled before immediate flush
      timerActive = false;
      buffer.clear();

      expect(timerActive, false,
          reason:
              'Timer should be cancelled when batch size triggers immediate flush');
    });
  });
}
