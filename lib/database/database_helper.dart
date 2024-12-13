import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }


  Future<void> _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');
    // Create events table
    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      userId TEXT NOT NULL  -- New column for the event owner's Firebase ID
    )
    ''');

    // Create gifts table
    await db.execute('''
    CREATE TABLE gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      price TEXT NOT NULL,
      description TEXT NOT NULL,
      isPledged INTEGER NOT NULL,
      event_id INTEGER NOT NULL,
      FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
    )
  ''');
  }



  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
