import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  // B7: Database version management
  static const int _databaseVersion = 1;
  static const String _databaseName = 'mind_house.db';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // B10: Database error handling and logging
      print('Database initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    try {
      // B4: Create information table schema
      await db.execute('''
        CREATE TABLE information (
          id TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // B5: Create tags table schema with color field
      await db.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL,
          color TEXT,
          usage_count INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL
        )
      ''');

      // B6: Create information_tags junction table schema
      await db.execute('''
        CREATE TABLE information_tags (
          information_id TEXT NOT NULL,
          tag_id INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          PRIMARY KEY (information_id, tag_id),
          FOREIGN KEY (information_id) REFERENCES information (id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
        )
      ''');

      // B8: Create database indexes for performance
      await db.execute('CREATE INDEX idx_information_created_at ON information (created_at)');
      await db.execute('CREATE INDEX idx_tags_name ON tags (name)');
      await db.execute('CREATE INDEX idx_tags_usage_count ON tags (usage_count)');
      await db.execute('CREATE INDEX idx_information_tags_information_id ON information_tags (information_id)');
      await db.execute('CREATE INDEX idx_information_tags_tag_id ON information_tags (tag_id)');
      
      print('Database tables created successfully');
    } catch (e) {
      // B10: Database error handling and logging
      print('Table creation failed: $e');
      rethrow;
    }
  }

  // B9: Implement database upgrade/migration logic
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // Future migration logic will be added here
      // For now, we only have version 1
      if (oldVersion < newVersion) {
        // Apply migrations sequentially
        for (int version = oldVersion + 1; version <= newVersion; version++) {
          await _performMigration(db, version);
        }
      }
    } catch (e) {
      // B10: Database error handling and logging
      print('Database upgrade failed: $e');
      rethrow;
    }
  }

  Future<void> _performMigration(Database db, int version) async {
    switch (version) {
      case 1:
        // Initial version - no migration needed
        break;
      // Future versions will add migration logic here
      default:
        print('Unknown database version: $version');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}