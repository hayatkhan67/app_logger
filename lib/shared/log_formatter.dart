import 'dart:convert';

import 'json_fix_helper.dart';

Future<String> formatMessage(dynamic message) async {
  try {
    if (message is Map) return jsonEncode(message);
    if (message is String) {
      try {
        return jsonEncode(jsonDecode(message));
      } catch (_) {
        final fixed = await fixPseudoJson(message);
        return jsonEncode(jsonDecode(fixed));
      }
    }
    return jsonEncode(message);
  } catch (_) {
    return message.toString();
  }
}
