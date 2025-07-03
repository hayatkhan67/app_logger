import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class DeviceInfoHelper {
  static Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return "Unknown";
  }

  static Future<String> getPlatform() async {
    return Platform.operatingSystem;
  }

  static Future<String> getAppVersion() async {
    final appInfo = await PackageInfo.fromPlatform();
    return appInfo.version;
  }
}
