import 'package:scanit/data/repositories/core/repository.dart';
import 'package:scanit/data/services/database_service.dart';
import 'package:scanit/domain/models/history/history_local_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class HistoryRepositoryLocal implements LocalRepository<HistoryLocalModel> {
  const HistoryRepositoryLocal({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  final String tableName = 'history';

  final DatabaseService _databaseService;

  @override
  Future<int> delete(UuidValue uuid) async {
    final db = await _databaseService.database;
    return await db.delete(tableName, where: 'uuid = ?', whereArgs: [uuid.toString()]);
  }

  @override
  Future<List<HistoryLocalModel>> getAll() async {
    final db = await _databaseService.database;
    return await db.query(tableName).then((value) {
      return value.map((json) => HistoryLocalModel.fromJson(json)).toList();
    });
  }

  @override
  Future<HistoryLocalModel?> getById(UuidValue uuid) async {
    final db = await _databaseService.database;
    return await db
        .query(tableName, where: 'uuid = ?', whereArgs: [uuid.toString()])
        .then((value) {
          if (value.isEmpty) {
            return null;
          }

          return HistoryLocalModel.fromJson(value.first);
        });
  }

  @override
  Future<int> insertOrReplace(HistoryLocalModel item) async {
    final db = await _databaseService.database;
    return await db.insert(
      tableName,
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
