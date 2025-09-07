import 'package:scanit/data/repositories/core/repository.dart';
import 'package:scanit/data/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/barcode/barcode_local_model.dart';

class BarcodeRepositoryLocal implements LocalRepository<BarcodeLocalModel> {
  const BarcodeRepositoryLocal({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  final String tableName = 'barcode';

  final DatabaseService _databaseService;

  @override
  Future<int> delete(UuidValue uuid) async {
    final db = await _databaseService.database;
    return await db.delete(
      tableName,
      where: 'uuid = ?',
      whereArgs: [uuid.toString()],
    );
  }

  @override
  Future<List<BarcodeLocalModel>> getAll() async {
    final db = await _databaseService.database;
    return await db.query(tableName).then((value) {
      return value.map((json) => BarcodeLocalModel.fromJson(json)).toList();
    });
  }

  @override
  Future<BarcodeLocalModel?> getById(UuidValue uuid) async {
    final db = await _databaseService.database;
    return await db
        .query(tableName, where: 'uuid = ?', whereArgs: [uuid.toString()])
        .then((value) {
          if (value.isEmpty) {
            return null;
          }

          return BarcodeLocalModel.fromJson(value.first);
        });
  }

  @override
  Future<int> insertOrReplace(BarcodeLocalModel item) async {
    final db = await _databaseService.database;
    return await db.insert(
      tableName,
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
