import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        priority TEXT,
        timerDuration INTEGER,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'todolist.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String description, String priority, int timerDuration) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
      'priority': priority,
      'timerDuration': timerDuration
    };
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems({String? priority}) async {
    final db = await SqlHelper.db();
    if (priority != null && priority.isNotEmpty && priority != 'All') {
      return db.query('items', where: "priority = ?", whereArgs: [priority], orderBy: "id DESC");
    } else {
      return db.query('items', orderBy: "id DESC");
    }
  }

  static Future<int> updateItem(int id, String title, String description, String priority, int timerDuration) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
      'priority': priority,
      'timerDuration': timerDuration,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}