import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('station.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          station TEXT NOT NULL,
          memo TEXT,
          imagePath TEXT
          latitude REAL,
          longitude REAL
          )
        ''');
      },
    );
  }

  Future<int> insertStation(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('stations', row);
  }

  Future<List<Map<String, dynamic>>> queryAllStations() async {
    final db = await instance.database;
    return await db.query('stations');
  }

  Future<int> deleteStation(int id) async {
    final db = await instance.database;
    return await db.delete('stations', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getStationCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM stations'),
        ) ??
        0;
  }
}
