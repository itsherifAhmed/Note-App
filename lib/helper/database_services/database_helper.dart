import 'dart:async';
import 'dart:io';

import 'package:newnote/model/Note_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance
  = DatabaseHelper._privateConstructor();

  static final _dbName = "notes.db";
  static final _dbVersion = 1;
  static final _tableName = "notes";

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) {
    return db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        dateTimeEdited TEXT NOT NULL,
        dateTimeCreated TEXT NOT NULL
      )
      ''');
  }

  // Add Note
  Future<int> addNote(Note note) async {
    Database db = await instance.database;
    return await db.insert(_tableName, note.toMap());
  }

  // Delete Note
  Future<int> deleteNote(Note note) async {
    Database db = await instance.database;
    return await db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  // Delete All Notes
  Future<int> deleteAllNotes() async {
    Database db = await instance.database;
    return await db.delete(_tableName);
  }

  // Update Note
  Future<int> updateNote(Note note) async {
    Database db = await instance.database;
    return await db.update(
      _tableName,
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> getNoteList() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(
      maps.length,
          (index) {
        return Note(
          id: maps[index]["id"],
          title: maps[index]["title"],
          content: maps[index]["content"],
          dateTimeEdited: maps[index]["dateTimeEdited"],
          dateTimeCreated: maps[index]["dateTimeCreated"],
        );
      },
    );
  }
}
