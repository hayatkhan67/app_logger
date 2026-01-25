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

  @override
  Future<void> saveLogs(List<LoggerEntity> logs) async {
    if (logs.isEmpty) return;
    final batch = _firestore.batch();
    final collection = _firestore.collection("logs");
    for (final log in logs) {
      batch.set(collection.doc(), log.toMap());
    }
    await batch.commit();
  }
}
