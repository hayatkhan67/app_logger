import 'logger_entity.dart';

abstract class LoggerRepository {
  Future<void> saveLog(LoggerEntity log);
}
