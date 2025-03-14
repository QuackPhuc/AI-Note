import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Thêm import này để sử dụng debugPrint

import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'note_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        summary TEXT,
        tags TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add tags column in version 2
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT DEFAULT ""');
    }
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<List<Note>> getNotesByTag(String tag) async {
    final allNotes = await getNotes();
    return allNotes.where((note) => note.tags.contains(tag)).toList();
  }

  Future<List<String>> getAllTags() async {
    final allNotes = await getNotes();
    final Set<String> tagsSet = {};
    
    for (var note in allNotes) {
      tagsSet.addAll(note.tags);
    }
    
    return tagsSet.toList()..sort();
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Create backup of database
  Future<String> backupDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'note_database.db');
    final appDir = await getApplicationDocumentsDirectory();
    final backupPath = join(appDir.path, 'note_database_backup.db');
    
    try {
      // Make sure the database is closed before copying
      await _database?.close();
      _database = null;
      
      // Copy the file
      File dbFile = File(dbPath);
      await dbFile.copy(backupPath);
      
      return backupPath;
    } catch (e) {
      return '';
    } finally {
      // Reopen the database
      _database = await _initDatabase();
    }
  }

  // Restore database from backup
  Future<bool> restoreDatabase(String backupPath) async {
    final dbPath = join(await getDatabasesPath(), 'note_database.db');
    
    try {
      // Kiểm tra file backup có tồn tại không
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        debugPrint('Backup file not found at $backupPath');
        return false;
      }
      
      // Make sure the database is closed before restoring
      await _database?.close();
      _database = null;
      
      // Copy the backup file over the current database
      await backupFile.copy(dbPath);
      
      // Reopen the database
      _database = await _initDatabase();
      return true;
    } catch (e) {
      debugPrint('Error restoring database: $e');
      // Reopen the database even if restoration fails
      _database = await _initDatabase();
      return false;
    }
  }
}
