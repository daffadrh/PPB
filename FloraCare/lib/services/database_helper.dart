import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant.dart';

class DatabaseHelper {
  static const _databaseName = "FloraCare.db";
  static const _databaseVersion = 1;
  static const table = 'plants';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            species TEXT NOT NULL,
            waterFrequencyDays INTEGER NOT NULL,
            imagePath TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Plant plant) async {
    Database db = await instance.database;
    return await db.insert(table, plant.toMap());
  }

  Future<List<Plant>> queryAllPlants() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Plant.fromMap(maps[i]);
    });
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}