import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService instance = DBService._internal();
  DBService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'studyai.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        colorHex TEXT NOT NULL,
        icon TEXT NOT NULL,
        isPinned INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        question TEXT NOT NULL,
        marks INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        tags TEXT,
        isPinned INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        questionText TEXT NOT NULL,
        answer TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationMinutes INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE timetable (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        subjectName TEXT NOT NULL,
        day TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        room TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE exams (
        id TEXT PRIMARY KEY,
        subjectId TEXT NOT NULL,
        subjectName TEXT NOT NULL,
        examDate TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }
}