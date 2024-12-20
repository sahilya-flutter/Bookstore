import 'dart:async';
import 'package:book_store/bookhome.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

 

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        price REAL NOT NULL,
        discountedPrice REAL NOT NULL
      )
    ''');
  }

  Future<void> insertBook(Book book) async {
    final db = await instance.database;

    await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> fetchBooks() async {
    final db = await instance.database;

    final result = await db.query('books');

    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<void> deleteAllBooks() async {
    final db = await instance.database;
    await db.delete('books');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
