import 'package:path/path.dart';
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
      'CREATE TABLE history(uuid TEXT PRIMARY KEY, barcodeData TEXT, scannedAtMillis INTEGER)',
    );
  }
}
