import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/logger_entity.dart';
import '../domain/repositories/logger_repository.dart';

class LoggerDatasource implements LoggerRepository {
  final FirebaseFirestore _firestore;

  const LoggerDatasource(this._firestore);

  @override
  Future<void> saveLog(LoggerEntity log) async {
    await _firestore.collection("logs").add(log.toMap());
  }
}
