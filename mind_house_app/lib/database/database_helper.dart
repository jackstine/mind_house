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
      
      // Will be implemented as needed for future schema changes
      if (oldVersion < newVersion) {
        // Handle migrations here
        // Example: if (oldVersion < 2) { ... }
        print('DatabaseHelper: Migration logic not yet implemented');
      }
      
      print('DatabaseHelper: Database upgrade completed');
    } catch (e) {
      print('DatabaseHelper: Error upgrading database: $e');
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

  /// Create information table
  Future<void> _createInformationTable(Database db) async {
    // Implementation will be added in B4
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

  /// Get database path
  Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}