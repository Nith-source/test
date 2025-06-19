import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/taskes.dart';

class DataBaseService {
  static final DataBaseService instance = DataBaseService._constructor();
  static Database? _db;

  DataBaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {

        db.execute('''
          CREATE TABLE ${Task.tableName} (
            ${Task.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Task.contentColumn} TEXT NOT NULL,
            ${Task.statusColumn} INTEGER NOT NULL
          )
          ''');
      },
    );
    return database;
  }


  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(Task.tableName, {
      Task.contentColumn: content,
      Task.statusColumn: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(Task.tableName, orderBy: '${Task.idColumn} DESC');
    List<Task> tasks = data.map((e) => Task.fromMap(e)).toList();
    return tasks;
  }

  Future<void> updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      Task.tableName,
      {Task.statusColumn: status},
      where: '${Task.idColumn} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      Task.tableName,
      where: '${Task.idColumn} = ?',
      whereArgs: [id],
    );
  }
}