import '../domain/value_objects/log_level.dart';

bool isAllowed(LogLevel level, Map<String, dynamic> data) {
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
