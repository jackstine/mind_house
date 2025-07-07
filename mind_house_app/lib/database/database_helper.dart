import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Database helper class for managing SQLite operations
/// Handles database creation, versioning, and migrations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'mind_house.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String informationTable = 'information';
  static const String tagsTable = 'tags';
  static const String informationTagsTable = 'information_tags';

  // Information table columns
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colType = 'type';
  static const String colSource = 'source';
  static const String colUrl = 'url';
  static const String colImportance = 'importance';
  static const String colIsFavorite = 'is_favorite';
  static const String colIsArchived = 'is_archived';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colAccessedAt = 'accessed_at';
  static const String colMetadata = 'metadata';

  // Singleton pattern
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      // Get the documents directory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);

      // Ensure the directory exists
      if (!await documentsDirectory.exists()) {
        await documentsDirectory.create(recursive: true);
      }

      print('DatabaseHelper: Initializing database at path: $path');

      // Open the database
      final database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
        onOpen: _onOpen,
      );

      print('DatabaseHelper: Database initialized successfully');
      return database;
    } catch (e) {
      print('DatabaseHelper: Error initializing database: $e');
      rethrow;
    }
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    try {
      print('DatabaseHelper: Configuring database settings');
      // Enable foreign key constraints
      await db.execute('PRAGMA foreign_keys = ON');
      
      // Optimize database performance
      await db.execute('PRAGMA journal_mode = WAL');
      await db.execute('PRAGMA synchronous = NORMAL');
      await db.execute('PRAGMA cache_size = 10000');
      
      print('DatabaseHelper: Database configuration completed');
    } catch (e) {
      print('DatabaseHelper: Error configuring database: $e');
      rethrow;
    }
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    try {
      print('DatabaseHelper: Database opened successfully');
      // Verify foreign keys are enabled
      final result = await db.rawQuery('PRAGMA foreign_keys');
      print('DatabaseHelper: Foreign keys enabled: ${result.first['foreign_keys']}');
    } catch (e) {
      print('DatabaseHelper: Error in onOpen: $e');
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      print('DatabaseHelper: Creating database tables (version $version)');
      
      // Will be implemented in B4, B5, B6
      await _createInformationTable(db);
      await _createTagsTable(db);
      await _createInformationTagsTable(db);
      
      print('DatabaseHelper: All tables created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades/migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      print('DatabaseHelper: Upgrading database from version $oldVersion to $newVersion');
      
      // Handle migrations step by step
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _migrateToVersion(db, version);
      }
      
      print('DatabaseHelper: Database upgrade completed');
    } catch (e) {
      print('DatabaseHelper: Error upgrading database: $e');
      rethrow;
    }
  }

  /// Migrate to specific version
  Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 1:
        // Initial database creation - handled by onCreate
        break;
      case 2:
        // Future migration example
        await _migrateInformationTableToV2(db);
        break;
      default:
        print('DatabaseHelper: No migration needed for version $version');
    }
  }

  /// Example migration for information table (version 2)
  Future<void> _migrateInformationTableToV2(Database db) async {
    try {
      print('DatabaseHelper: Migrating information table to version 2');
      
      // Example: Add new column
      await db.execute('''
        ALTER TABLE $informationTable 
        ADD COLUMN reading_time INTEGER DEFAULT 0
      ''');
      
      // Example: Create new index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_reading_time 
        ON $informationTable (reading_time)
      ''');
      
      print('DatabaseHelper: Information table migration to v2 completed');
    } catch (e) {
      print('DatabaseHelper: Error migrating information table to v2: $e');
      rethrow;
    }
  }

  /// Initialize database manually (useful for testing)
  Future<void> initializeDatabase() async {
    try {
      print('DatabaseHelper: Manual database initialization requested');
      final db = await database;
      print('DatabaseHelper: Manual initialization completed. Database ready.');
    } catch (e) {
      print('DatabaseHelper: Error during manual initialization: $e');
      rethrow;
    }
  }

  /// Check database health and connectivity
  Future<bool> isDatabaseHealthy() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      print('DatabaseHelper: Database health check failed: $e');
      return false;
    }
  }

  /// Verify information table exists and has correct schema
  Future<bool> verifyInformationTableSchema() async {
    try {
      final db = await database;
      
      // Check if table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='$informationTable'
      ''');
      
      if (tableExists.isEmpty) {
        print('DatabaseHelper: Information table does not exist');
        return false;
      }
      
      // Check table schema
      final tableInfo = await db.rawQuery('PRAGMA table_info($informationTable)');
      
      // Expected columns
      final expectedColumns = [
        colId, colTitle, colContent, colType, colSource, colUrl, 
        colImportance, colIsFavorite, colIsArchived, 
        colCreatedAt, colUpdatedAt, colAccessedAt, colMetadata
      ];
      
      final actualColumns = tableInfo.map((row) => row['name'] as String).toList();
      
      for (final expectedColumn in expectedColumns) {
        if (!actualColumns.contains(expectedColumn)) {
          print('DatabaseHelper: Missing column: $expectedColumn');
          return false;
        }
      }
      
      print('DatabaseHelper: Information table schema verified');
      return true;
    } catch (e) {
      print('DatabaseHelper: Error verifying information table schema: $e');
      return false;
    }
  }

  /// Get information table column names
  Future<List<String>> getInformationTableColumns() async {
    try {
      final db = await database;
      final tableInfo = await db.rawQuery('PRAGMA table_info($informationTable)');
      return tableInfo.map((row) => row['name'] as String).toList();
    } catch (e) {
      print('DatabaseHelper: Error getting information table columns: $e');
      return [];
    }
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      return join(documentsDirectory.path, _databaseName);
    } catch (e) {
      print('DatabaseHelper: Error getting database path: $e');
      return '';
    }
  }

  /// Create information table
  Future<void> _createInformationTable(Database db) async {
    try {
      print('DatabaseHelper: Creating information table');
      
      const String createInformationTableSQL = '''
        CREATE TABLE $informationTable (
          $colId TEXT PRIMARY KEY,
          $colTitle TEXT NOT NULL,
          $colContent TEXT NOT NULL,
          $colType TEXT NOT NULL DEFAULT 'note',
          $colSource TEXT,
          $colUrl TEXT,
          $colImportance INTEGER DEFAULT 0,
          $colIsFavorite INTEGER DEFAULT 0,
          $colIsArchived INTEGER DEFAULT 0,
          $colCreatedAt TEXT NOT NULL,
          $colUpdatedAt TEXT NOT NULL,
          $colAccessedAt TEXT,
          $colMetadata TEXT
        )
      ''';
      
      await db.execute(createInformationTableSQL);
      
      // Create indexes for better performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_title 
        ON $informationTable ($colTitle)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_type 
        ON $informationTable ($colType)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_created_at 
        ON $informationTable ($colCreatedAt)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_importance 
        ON $informationTable ($colImportance)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_favorite 
        ON $informationTable ($colIsFavorite)
      ''');
      
      print('DatabaseHelper: Information table created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating information table: $e');
      rethrow;
    }
  }

  /// Create tags table
  Future<void> _createTagsTable(Database db) async {
    // Implementation will be added in B5
  }

  /// Create information_tags junction table
  Future<void> _createInformationTagsTable(Database db) async {
    // Implementation will be added in B6
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing purposes)
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await databaseFactory.databaseExists(path);
  }

}