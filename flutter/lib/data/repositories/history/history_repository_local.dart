import 'dart:convert';

import 'package:scanit/data/repositories/core/repository.dart';
import 'package:scanit/data/services/database_service.dart';
import 'package:scanit/domain/models/history/history_local_model.dart';
import 'package:scanit/utils/result.dart';
import 'package:sqflite/sqflite.dart';

class HistoryRepositoryLocal implements LocalRepository<HistoryLocalModel> {
  const HistoryRepositoryLocal({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  final String tableName = 'history';

  final DatabaseService _databaseService;

  @override
  Future<Result<int>> delete(int id) async {
    final db = await _databaseService.database;
    return await db
        .delete(tableName, where: 'id = ?', whereArgs: [id])
        .then((value) {
          return Result.ok(value);
        })
        .catchError((error) {
          return Result<int>.error(error);
        });
  }

  @override
  Future<Result<List<HistoryLocalModel>>> getAll() async {
    final db = await _databaseService.database;
    return await db
        .query(tableName)
        .then((value) {
          final items = value
              .map((json) => HistoryLocalModel.fromJson(json))
              .toList();

          return Result.ok(items);
        })
        .catchError((error) {
          return Result<List<HistoryLocalModel>>.error(error);
        });
  }

  @override
  Future<Result<HistoryLocalModel>> getById(int id) async {
    final db = await _databaseService.database;
    return await db
        .query(tableName, where: 'id = ?', whereArgs: [id])
        .then((value) {
          return value.isNotEmpty
              ? Result.ok(HistoryLocalModel.fromJson(value.first))
              : Result<HistoryLocalModel>.error(
                  Exception('No item found with id: $id'),
                );
        })
        .catchError((error) {
          return Result<HistoryLocalModel>.error(error);
        });
  }

  @override
  Future<Result<int>> insertOrReplace(HistoryLocalModel item) async {
    final db = await _databaseService.database;
    return await db
        .insert(
          tableName,
          item.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        )
        .then((value) {
          return Result.ok(value);
        })
        .catchError((error) {
          return Result<int>.error(error);
        });
  }
}
