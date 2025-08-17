import 'package:path/path.dart';
import 'package:scanit/domain/models/core/local_model.dart';
import 'package:scanit/utils/result.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseService {
  Future<Database> get database;
}

class DatabaseServiceImpl implements DatabaseService {
  final String _databaseName = 'scanit_database.db';
  final int _databaseVersion = 1;

  static Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: _onCreate,
      version: _databaseVersion,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE history(id INTEGER PRIMARY KEY, title TEXT, scannedAtMillis INTEGER)',
    );
  }
}
