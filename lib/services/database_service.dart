import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/blocked_app_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_scheduler.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE blocked_apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT NOT NULL UNIQUE,
        appName TEXT NOT NULL,
        isBlocked INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ── TASKS ──────────────────────────────────────────
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel>> getTasksForDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'startTime ASC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'date ASC, startTime ASC');
    return maps.map(TaskModel.fromMap).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markTaskCompleted(int id, bool completed) async {
    final db = await database;
    return db.update(
      'tasks',
      {'isCompleted': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── BLOCKED APPS ───────────────────────────────────
  Future<int> upsertBlockedApp(BlockedAppModel app) async {
    final db = await database;
    return db.insert(
      'blocked_apps',
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BlockedAppModel>> getBlockedApps() async {
    final db = await database;
    final maps = await db.query('blocked_apps');
    return maps.map(BlockedAppModel.fromMap).toList();
  }

  Future<List<BlockedAppModel>> getAllSavedApps() async {
    final db = await database;
    final maps = await db.query('blocked_apps', orderBy: 'appName ASC');
    return maps.map(BlockedAppModel.fromMap).toList();
  }

  Future<int> updateBlockedStatus(String packageName, bool isBlocked) async {
    final db = await database;
    return db.update(
      'blocked_apps',
      {'isBlocked': isBlocked ? 1 : 0},
      where: 'packageName = ?',
      whereArgs: [packageName],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
