import 'dart:typed_data';
import 'package:flutter_firebase_project/pages/developing%20feature/store_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE store_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemName TEXT,
            cost INTEGER,
            priceInCents INTEGER,
            image BLOB
          )
        ''');
      },
    );
  }

  Future<int> insertItem(StoreItem item) async {
    final db = await database;
    return await db.insert(
      'store_items',
      {
        'itemName': item.itemName,
        'cost': item.cost,
        'priceInCents': item.priceInCents,
        'image': item.image, // Assuming image is Uint8List data
      },
    );
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('store_items');
  }
}
