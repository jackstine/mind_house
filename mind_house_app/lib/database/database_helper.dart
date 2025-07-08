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
  
  // Version management
  static const String _versionTableName = 'database_version_history';
  static const int _minimumSupportedVersion = 1;
  static const int _maximumSupportedVersion = 10;
  
  // Version history table columns
  static const String colVersionId = 'id';
  static const String colVersionNumber = 'version_number';
  static const String colVersionName = 'version_name';
  static const String colMigrationDate = 'migration_date';
  static const String colMigrationDuration = 'migration_duration_ms';
  static const String colMigrationNotes = 'migration_notes';
  static const String colAppVersion = 'app_version';

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

  // Tags table columns
  static const String colTagId = 'id';
  static const String colTagName = 'name';
  static const String colTagColor = 'color';
  static const String colTagDescription = 'description';
  static const String colTagUsageCount = 'usage_count';
  static const String colTagCreatedAt = 'created_at';
  static const String colTagUpdatedAt = 'updated_at';

  // Information_tags junction table columns
  static const String colInformationId = 'information_id';
  static const String colJunctionTagId = 'tag_id';
  static const String colAssignedAt = 'assigned_at';
  static const String colAssignedBy = 'assigned_by';

  // Predefined tag colors (Material Design palette)
  static const List<String> predefinedTagColors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#E91E63', // Pink
    '#009688', // Teal
    '#FFC107', // Amber
    '#3F51B5', // Indigo
    '#8BC34A', // Light Green
  ];

  // Database version information
  static const Map<int, String> versionNames = {
    1: 'Initial Schema',
    2: 'Enhanced Information Table',
    3: 'Tag Categories',
    4: 'Junction Table Enhancements',
    5: 'Full-Text Search',
    6: 'Performance Optimizations',
    7: 'Security Enhancements',
    8: 'Analytics Features',
    9: 'Cloud Sync Support',
    10: 'Advanced Features',
  };

  static const Map<int, String> versionDescriptions = {
    1: 'Basic information, tags, and junction tables with core functionality',
    2: 'Added reading time tracking and enhanced metadata support',
    3: 'Introduced tag categorization and improved organization',
    4: 'Enhanced many-to-many relationships with priority support',
    5: 'Full-text search capabilities across all content',
    6: 'Database performance optimizations and indexing improvements',
    7: 'Enhanced security features and data encryption',
    8: 'Analytics and usage tracking capabilities',
    9: 'Cloud synchronization and backup features',
    10: 'Advanced AI features and smart recommendations',
  };

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
    final stopwatch = Stopwatch()..start();
    
    try {
      print('DatabaseHelper: Creating database tables (version $version)');
      
      // Create version history table first
      await _createVersionHistoryTable(db);
      
      // Create main tables
      await _createInformationTable(db);
      await _createTagsTable(db);
      await _createInformationTagsTable(db);
      
      stopwatch.stop();
      
      // Record initial version in history
      await _recordVersionHistory(
        db,
        version,
        stopwatch.elapsedMilliseconds,
        'Initial database creation',
      );
      
      print('DatabaseHelper: All tables created successfully in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('DatabaseHelper: Error creating tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades/migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final upgradeStopwatch = Stopwatch()..start();
    
    try {
      print('DatabaseHelper: Upgrading database from version $oldVersion to $newVersion');
      
      // Validate version compatibility
      if (!_isVersionSupported(newVersion)) {
        throw Exception('Database version $newVersion is not supported. Supported range: $_minimumSupportedVersion - $_maximumSupportedVersion');
      }
      
      if (oldVersion > newVersion) {
        throw Exception('Cannot downgrade database from version $oldVersion to $newVersion');
      }
      
      // Create version history table if it doesn't exist (for older databases)
      await _ensureVersionHistoryTableExists(db);
      
      // Handle migrations step by step
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        final migrationStopwatch = Stopwatch()..start();
        
        print('DatabaseHelper: Migrating to version $version (${versionNames[version] ?? 'Unknown'})');
        await _migrateToVersion(db, version);
        
        migrationStopwatch.stop();
        
        // Record each migration in history
        await _recordVersionHistory(
          db,
          version,
          migrationStopwatch.elapsedMilliseconds,
          'Migration from version ${version - 1}',
        );
      }
      
      upgradeStopwatch.stop();
      print('DatabaseHelper: Database upgrade completed in ${upgradeStopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('DatabaseHelper: Error upgrading database: $e');
      rethrow;
    }
  }

  /// Migrate to specific version with comprehensive validation
  Future<void> _migrateToVersion(Database db, int version) async {
    final migrationStopwatch = Stopwatch()..start();
    
    try {
      print('DatabaseHelper: Starting migration to version $version');
      
      // Pre-migration validation
      await _preMigrationValidation(db, version);
      
      // Backup critical data if needed
      await _backupDataForMigration(db, version);
      
      // Execute the actual migration
      await _executeMigration(db, version);
      
      // Post-migration validation
      await _postMigrationValidation(db, version);
      
      migrationStopwatch.stop();
      print('DatabaseHelper: Migration to version $version completed in ${migrationStopwatch.elapsedMilliseconds}ms');
      
    } catch (e) {
      migrationStopwatch.stop();
      print('DatabaseHelper: Migration to version $version failed after ${migrationStopwatch.elapsedMilliseconds}ms: $e');
      
      // Attempt rollback if possible
      await _attemptMigrationRollback(db, version, e);
      rethrow;
    }
  }

  /// Execute the actual migration for a specific version
  Future<void> _executeMigration(Database db, int version) async {
    switch (version) {
      case 1:
        // Initial database creation - handled by onCreate
        break;
      case 2:
        // Enhanced information table with reading time
        await _migrateInformationTableToV2(db);
        break;
      case 3:
        // Tag categories support
        await _migrateTagsTableToV3(db);
        break;
      case 4:
        // Junction table enhancements with priority
        await _migrateInformationTagsTableToV4(db);
        break;
      case 5:
        // Full-text search capabilities
        await _migrateToFullTextSearchV5(db);
        break;
      case 6:
        // Performance optimizations
        await _migratePerformanceOptimizationsV6(db);
        break;
      default:
        print('DatabaseHelper: No migration needed for version $version');
    }
  }

  /// Pre-migration validation
  Future<void> _preMigrationValidation(Database db, int version) async {
    try {
      print('DatabaseHelper: Running pre-migration validation for version $version');
      
      // Check database integrity
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      if (integrityResult.first['integrity_check'] != 'ok') {
        throw Exception('Database integrity check failed before migration');
      }
      
      // Check foreign key constraints
      final foreignKeyResult = await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeyResult.isNotEmpty) {
        throw Exception('Foreign key constraint violations detected before migration');
      }
      
      // Verify required tables exist for the migration
      await _verifyRequiredTablesForMigration(db, version);
      
      print('DatabaseHelper: Pre-migration validation passed');
    } catch (e) {
      print('DatabaseHelper: Pre-migration validation failed: $e');
      rethrow;
    }
  }

  /// Post-migration validation
  Future<void> _postMigrationValidation(Database db, int version) async {
    try {
      print('DatabaseHelper: Running post-migration validation for version $version');
      
      // Check database integrity after migration
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      if (integrityResult.first['integrity_check'] != 'ok') {
        throw Exception('Database integrity check failed after migration');
      }
      
      // Verify schema changes were applied correctly
      await _verifySchemaChanges(db, version);
      
      // Check that all expected indexes exist
      await _verifyIndexesAfterMigration(db, version);
      
      print('DatabaseHelper: Post-migration validation passed');
    } catch (e) {
      print('DatabaseHelper: Post-migration validation failed: $e');
      rethrow;
    }
  }

  /// Backup data before migration (for critical migrations)
  Future<void> _backupDataForMigration(Database db, int version) async {
    try {
      // Only backup for critical migrations that could cause data loss
      final criticalMigrations = [3, 5, 6]; // Example critical versions
      
      if (!criticalMigrations.contains(version)) {
        return;
      }
      
      print('DatabaseHelper: Creating data backup before migration to version $version');
      
      // Create backup tables with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Backup information table
      await db.execute('''
        CREATE TABLE information_backup_$timestamp AS 
        SELECT * FROM $informationTable
      ''');
      
      // Backup tags table
      await db.execute('''
        CREATE TABLE tags_backup_$timestamp AS 
        SELECT * FROM $tagsTable
      ''');
      
      // Backup junction table
      await db.execute('''
        CREATE TABLE information_tags_backup_$timestamp AS 
        SELECT * FROM $informationTagsTable
      ''');
      
      print('DatabaseHelper: Data backup completed');
    } catch (e) {
      print('DatabaseHelper: Data backup failed: $e');
      rethrow;
    }
  }

  /// Attempt migration rollback
  Future<void> _attemptMigrationRollback(Database db, int version, dynamic error) async {
    try {
      print('DatabaseHelper: Attempting rollback for failed migration to version $version');
      
      // Implementation would depend on specific migration
      // For now, just log the attempt
      print('DatabaseHelper: Rollback not implemented for version $version');
      print('DatabaseHelper: Original error: $error');
      
    } catch (rollbackError) {
      print('DatabaseHelper: Rollback failed: $rollbackError');
    }
  }

  /// Verify required tables exist for migration
  Future<void> _verifyRequiredTablesForMigration(Database db, int version) async {
    final requiredTables = <String>[];
    
    switch (version) {
      case 2:
        requiredTables.addAll([informationTable]);
        break;
      case 3:
        requiredTables.addAll([tagsTable]);
        break;
      case 4:
        requiredTables.addAll([informationTagsTable]);
        break;
      case 5:
        requiredTables.addAll([informationTable, tagsTable]);
        break;
      case 6:
        requiredTables.addAll([informationTable, tagsTable, informationTagsTable]);
        break;
    }
    
    for (final table in requiredTables) {
      final result = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='$table'
      ''');
      
      if (result.isEmpty) {
        throw Exception('Required table $table does not exist for migration to version $version');
      }
    }
  }

  /// Verify schema changes were applied correctly
  Future<void> _verifySchemaChanges(Database db, int version) async {
    switch (version) {
      case 2:
        // Verify reading_time column was added
        final infoColumns = await db.rawQuery('PRAGMA table_info($informationTable)');
        final hasReadingTime = infoColumns.any((col) => col['name'] == 'reading_time');
        if (!hasReadingTime) {
          throw Exception('reading_time column was not added to information table');
        }
        break;
      case 3:
        // Verify category column was added to tags
        final tagColumns = await db.rawQuery('PRAGMA table_info($tagsTable)');
        final hasCategory = tagColumns.any((col) => col['name'] == 'category');
        if (!hasCategory) {
          throw Exception('category column was not added to tags table');
        }
        break;
      case 4:
        // Verify priority column was added to junction table
        final junctionColumns = await db.rawQuery('PRAGMA table_info($informationTagsTable)');
        final hasPriority = junctionColumns.any((col) => col['name'] == 'priority');
        if (!hasPriority) {
          throw Exception('priority column was not added to information_tags table');
        }
        break;
    }
  }

  /// Verify indexes exist after migration
  Future<void> _verifyIndexesAfterMigration(Database db, int version) async {
    switch (version) {
      case 2:
        // Verify reading_time index exists
        final indexes = await db.rawQuery('''
          SELECT name FROM sqlite_master 
          WHERE type='index' AND name='idx_information_reading_time'
        ''');
        if (indexes.isEmpty) {
          throw Exception('idx_information_reading_time index was not created');
        }
        break;
      case 3:
        // Verify category index exists
        final indexes = await db.rawQuery('''
          SELECT name FROM sqlite_master 
          WHERE type='index' AND name='idx_tags_category'
        ''');
        if (indexes.isEmpty) {
          throw Exception('idx_tags_category index was not created');
        }
        break;
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

  /// Example migration for tags table (version 3)
  Future<void> _migrateTagsTableToV3(Database db) async {
    try {
      print('DatabaseHelper: Migrating tags table to version 3');
      
      // Example: Add new column for tag categories
      await db.execute('''
        ALTER TABLE $tagsTable 
        ADD COLUMN category TEXT DEFAULT 'general'
      ''');
      
      // Example: Create new index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_category 
        ON $tagsTable (category)
      ''');
      
      print('DatabaseHelper: Tags table migration to v3 completed');
    } catch (e) {
      print('DatabaseHelper: Error migrating tags table to v3: $e');
      rethrow;
    }
  }

  /// Example migration for information_tags junction table (version 4)
  Future<void> _migrateInformationTagsTableToV4(Database db) async {
    try {
      print('DatabaseHelper: Migrating information_tags junction table to version 4');
      
      // Example: Add new column for assignment priority
      await db.execute('''
        ALTER TABLE $informationTagsTable 
        ADD COLUMN priority INTEGER DEFAULT 0
      ''');
      
      // Example: Create new index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_priority 
        ON $informationTagsTable (priority)
      ''');
      
      print('DatabaseHelper: Information_tags junction table migration to v4 completed');
    } catch (e) {
      print('DatabaseHelper: Error migrating information_tags junction table to v4: $e');
      rethrow;
    }
  }

  /// Full-text search migration (version 5)
  Future<void> _migrateToFullTextSearchV5(Database db) async {
    try {
      print('DatabaseHelper: Migrating to full-text search version 5');
      
      // Create FTS virtual table for information content
      await db.execute('''
        CREATE VIRTUAL TABLE information_fts USING fts5(
          title, content, source, 
          content='$informationTable', 
          content_rowid='rowid'
        )
      ''');
      
      // Populate FTS table with existing data
      await db.execute('''
        INSERT INTO information_fts(rowid, title, content, source)
        SELECT rowid, $colTitle, $colContent, $colSource 
        FROM $informationTable
      ''');
      
      // Create triggers to keep FTS table in sync
      await db.execute('''
        CREATE TRIGGER information_fts_insert AFTER INSERT ON $informationTable BEGIN
          INSERT INTO information_fts(rowid, title, content, source) 
          VALUES (new.rowid, new.$colTitle, new.$colContent, new.$colSource);
        END
      ''');
      
      await db.execute('''
        CREATE TRIGGER information_fts_delete AFTER DELETE ON $informationTable BEGIN
          INSERT INTO information_fts(information_fts, rowid, title, content, source) 
          VALUES('delete', old.rowid, old.$colTitle, old.$colContent, old.$colSource);
        END
      ''');
      
      await db.execute('''
        CREATE TRIGGER information_fts_update AFTER UPDATE ON $informationTable BEGIN
          INSERT INTO information_fts(information_fts, rowid, title, content, source) 
          VALUES('delete', old.rowid, old.$colTitle, old.$colContent, old.$colSource);
          INSERT INTO information_fts(rowid, title, content, source) 
          VALUES (new.rowid, new.$colTitle, new.$colContent, new.$colSource);
        END
      ''');
      
      print('DatabaseHelper: Full-text search migration to v5 completed');
    } catch (e) {
      print('DatabaseHelper: Error migrating to full-text search v5: $e');
      rethrow;
    }
  }

  /// Performance optimizations migration (version 6)
  Future<void> _migratePerformanceOptimizationsV6(Database db) async {
    try {
      print('DatabaseHelper: Migrating performance optimizations version 6');
      
      // Add materialized view for tag statistics
      await db.execute('''
        CREATE TABLE tag_statistics (
          tag_id TEXT PRIMARY KEY,
          usage_count INTEGER NOT NULL DEFAULT 0,
          last_used TEXT,
          avg_importance REAL DEFAULT 0.0,
          FOREIGN KEY (tag_id) REFERENCES $tagsTable ($colTagId) ON DELETE CASCADE
        )
      ''');
      
      // Populate tag statistics
      await db.execute('''
        INSERT INTO tag_statistics (tag_id, usage_count, last_used, avg_importance)
        SELECT 
          it.$colJunctionTagId,
          COUNT(*) as usage_count,
          MAX(it.$colAssignedAt) as last_used,
          AVG(i.$colImportance) as avg_importance
        FROM $informationTagsTable it
        JOIN $informationTable i ON i.$colId = it.$colInformationId
        GROUP BY it.$colJunctionTagId
      ''');
      
      // Create index on tag statistics
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tag_statistics_usage 
        ON tag_statistics (usage_count DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tag_statistics_last_used 
        ON tag_statistics (last_used DESC)
      ''');
      
      // Add trigger to maintain tag statistics
      await db.execute('''
        CREATE TRIGGER maintain_tag_statistics AFTER INSERT ON $informationTagsTable
        BEGIN
          INSERT OR REPLACE INTO tag_statistics (tag_id, usage_count, last_used, avg_importance)
          SELECT 
            new.$colJunctionTagId,
            COUNT(*),
            MAX(it.$colAssignedAt),
            AVG(i.$colImportance)
          FROM $informationTagsTable it
          JOIN $informationTable i ON i.$colId = it.$colInformationId
          WHERE it.$colJunctionTagId = new.$colJunctionTagId;
        END
      ''');
      
      print('DatabaseHelper: Performance optimizations migration to v6 completed');
    } catch (e) {
      print('DatabaseHelper: Error migrating performance optimizations v6: $e');
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

  /// Verify tags table exists and has correct schema
  Future<bool> verifyTagsTableSchema() async {
    try {
      final db = await database;
      
      // Check if table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='$tagsTable'
      ''');
      
      if (tableExists.isEmpty) {
        print('DatabaseHelper: Tags table does not exist');
        return false;
      }
      
      // Check table schema
      final tableInfo = await db.rawQuery('PRAGMA table_info($tagsTable)');
      
      // Expected columns
      final expectedColumns = [
        colTagId, colTagName, colTagColor, colTagDescription,
        colTagUsageCount, colTagCreatedAt, colTagUpdatedAt
      ];
      
      final actualColumns = tableInfo.map((row) => row['name'] as String).toList();
      
      for (final expectedColumn in expectedColumns) {
        if (!actualColumns.contains(expectedColumn)) {
          print('DatabaseHelper: Missing column: $expectedColumn');
          return false;
        }
      }
      
      print('DatabaseHelper: Tags table schema verified');
      return true;
    } catch (e) {
      print('DatabaseHelper: Error verifying tags table schema: $e');
      return false;
    }
  }

  /// Get tags table column names
  Future<List<String>> getTagsTableColumns() async {
    try {
      final db = await database;
      final tableInfo = await db.rawQuery('PRAGMA table_info($tagsTable)');
      return tableInfo.map((row) => row['name'] as String).toList();
    } catch (e) {
      print('DatabaseHelper: Error getting tags table columns: $e');
      return [];
    }
  }

  /// Get a random predefined tag color
  static String getRandomTagColor() {
    final random = DateTime.now().millisecondsSinceEpoch % predefinedTagColors.length;
    return predefinedTagColors[random];
  }

  /// Validate if color is a valid hex color
  static bool isValidHexColor(String color) {
    final hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexColorRegex.hasMatch(color);
  }

  /// Get next available tag color from predefined colors
  Future<String> getNextAvailableTagColor() async {
    try {
      final db = await database;
      
      // Get all used colors
      final usedColors = await db.rawQuery('''
        SELECT DISTINCT $colTagColor FROM $tagsTable
      ''');
      
      final usedColorSet = usedColors
          .map((row) => row[colTagColor] as String)
          .toSet();
      
      // Find first unused color
      for (final color in predefinedTagColors) {
        if (!usedColorSet.contains(color)) {
          return color;
        }
      }
      
      // If all colors are used, return a random one
      return getRandomTagColor();
    } catch (e) {
      print('DatabaseHelper: Error getting next available tag color: $e');
      return getRandomTagColor();
    }
  }

  /// Verify information_tags junction table exists and has correct schema
  Future<bool> verifyInformationTagsTableSchema() async {
    try {
      final db = await database;
      
      // Check if table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='$informationTagsTable'
      ''');
      
      if (tableExists.isEmpty) {
        print('DatabaseHelper: Information_tags junction table does not exist');
        return false;
      }
      
      // Check table schema
      final tableInfo = await db.rawQuery('PRAGMA table_info($informationTagsTable)');
      
      // Expected columns
      final expectedColumns = [
        colInformationId, colJunctionTagId, colAssignedAt, colAssignedBy
      ];
      
      final actualColumns = tableInfo.map((row) => row['name'] as String).toList();
      
      for (final expectedColumn in expectedColumns) {
        if (!actualColumns.contains(expectedColumn)) {
          print('DatabaseHelper: Missing column: $expectedColumn');
          return false;
        }
      }
      
      // Check foreign key constraints
      final foreignKeys = await db.rawQuery('PRAGMA foreign_key_list($informationTagsTable)');
      if (foreignKeys.length < 2) {
        print('DatabaseHelper: Missing foreign key constraints');
        return false;
      }
      
      print('DatabaseHelper: Information_tags junction table schema verified');
      return true;
    } catch (e) {
      print('DatabaseHelper: Error verifying information_tags junction table schema: $e');
      return false;
    }
  }

  /// Get information_tags junction table column names
  Future<List<String>> getInformationTagsTableColumns() async {
    try {
      final db = await database;
      final tableInfo = await db.rawQuery('PRAGMA table_info($informationTagsTable)');
      return tableInfo.map((row) => row['name'] as String).toList();
    } catch (e) {
      print('DatabaseHelper: Error getting information_tags junction table columns: $e');
      return [];
    }
  }

  /// Get tag count for a specific information item
  Future<int> getTagCountForInformation(String informationId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $informationTagsTable 
        WHERE $colInformationId = ?
      ''', [informationId]);
      
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('DatabaseHelper: Error getting tag count for information: $e');
      return 0;
    }
  }

  /// Get information count for a specific tag
  Future<int> getInformationCountForTag(String tagId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $informationTagsTable 
        WHERE $colJunctionTagId = ?
      ''', [tagId]);
      
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('DatabaseHelper: Error getting information count for tag: $e');
      return 0;
    }
  }

  /// Check if a specific information-tag relationship exists
  Future<bool> doesInformationTagRelationshipExist(String informationId, String tagId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $informationTagsTable 
        WHERE $colInformationId = ? AND $colJunctionTagId = ?
      ''', [informationId, tagId]);
      
      return ((result.first['count'] as int?) ?? 0) > 0;
    } catch (e) {
      print('DatabaseHelper: Error checking information-tag relationship: $e');
      return false;
    }
  }

  /// Get all unique tags used across all information items
  Future<List<Map<String, dynamic>>> getAllUsedTags() async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT DISTINCT t.* FROM $tagsTable t
        INNER JOIN $informationTagsTable it ON t.$colTagId = it.$colJunctionTagId
        ORDER BY t.$colTagName
      ''');
    } catch (e) {
      print('DatabaseHelper: Error getting all used tags: $e');
      return [];
    }
  }

  /// Get all unused tags (not assigned to any information)
  Future<List<Map<String, dynamic>>> getAllUnusedTags() async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT t.* FROM $tagsTable t
        LEFT JOIN $informationTagsTable it ON t.$colTagId = it.$colJunctionTagId
        WHERE it.$colJunctionTagId IS NULL
        ORDER BY t.$colTagName
      ''');
    } catch (e) {
      print('DatabaseHelper: Error getting all unused tags: $e');
      return [];
    }
  }

  /// Check if a database version is supported
  static bool _isVersionSupported(int version) {
    return version >= _minimumSupportedVersion && version <= _maximumSupportedVersion;
  }

  /// Get current database version
  Future<int> getCurrentDatabaseVersion() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA user_version');
      return (result.first['user_version'] as int?) ?? _databaseVersion;
    } catch (e) {
      print('DatabaseHelper: Error getting database version: $e');
      return _databaseVersion;
    }
  }

  /// Get version history
  Future<List<Map<String, dynamic>>> getVersionHistory() async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT * FROM $_versionTableName 
        ORDER BY $colVersionNumber ASC
      ''');
    } catch (e) {
      print('DatabaseHelper: Error getting version history: $e');
      return [];
    }
  }

  /// Get version information
  static Map<String, dynamic> getVersionInfo(int version) {
    return {
      'version': version,
      'name': versionNames[version] ?? 'Unknown Version',
      'description': versionDescriptions[version] ?? 'No description available',
      'supported': _isVersionSupported(version),
    };
  }

  /// Get all supported versions
  static List<Map<String, dynamic>> getAllSupportedVersions() {
    final versions = <Map<String, dynamic>>[];
    for (int i = _minimumSupportedVersion; i <= _maximumSupportedVersion; i++) {
      versions.add(getVersionInfo(i));
    }
    return versions;
  }

  /// Check if database needs upgrade
  Future<bool> needsUpgrade() async {
    try {
      final currentVersion = await getCurrentDatabaseVersion();
      return currentVersion < _databaseVersion;
    } catch (e) {
      print('DatabaseHelper: Error checking if upgrade needed: $e');
      return false;
    }
  }

  /// Get database schema version info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final currentVersion = await getCurrentDatabaseVersion();
      final history = await getVersionHistory();
      
      return {
        'current_version': currentVersion,
        'target_version': _databaseVersion,
        'needs_upgrade': currentVersion < _databaseVersion,
        'version_info': getVersionInfo(currentVersion),
        'database_path': await getDatabasePath(),
        'version_history_count': history.length,
        'supported_version_range': {
          'min': _minimumSupportedVersion,
          'max': _maximumSupportedVersion,
        },
      };
    } catch (e) {
      print('DatabaseHelper: Error getting database info: $e');
      return {
        'error': e.toString(),
        'current_version': _databaseVersion,
        'target_version': _databaseVersion,
        'needs_upgrade': false,
      };
    }
  }

  /// Get all database indexes
  Future<List<Map<String, dynamic>>> getAllIndexes() async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT name, sql, tbl_name 
        FROM sqlite_master 
        WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
        ORDER BY tbl_name, name
      ''');
    } catch (e) {
      print('DatabaseHelper: Error getting indexes: $e');
      return [];
    }
  }

  /// Get indexes for a specific table
  Future<List<Map<String, dynamic>>> getTableIndexes(String tableName) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT name, sql, tbl_name 
        FROM sqlite_master 
        WHERE type = 'index' AND tbl_name = ? AND name NOT LIKE 'sqlite_%'
        ORDER BY name
      ''', [tableName]);
    } catch (e) {
      print('DatabaseHelper: Error getting table indexes: $e');
      return [];
    }
  }

  /// Analyze index usage and performance
  Future<Map<String, dynamic>> analyzeIndexPerformance() async {
    try {
      final db = await database;
      final indexes = await getAllIndexes();
      
      final analysis = <String, dynamic>{
        'total_indexes': indexes.length,
        'indexes_by_table': <String, int>{},
        'index_details': <Map<String, dynamic>>[],
      };
      
      for (final index in indexes) {
        final tableName = index['tbl_name'] as String;
        final indexName = index['name'] as String;
        
        // Count indexes per table
        analysis['indexes_by_table'][tableName] = 
            (analysis['indexes_by_table'][tableName] as int? ?? 0) + 1;
        
        // Get index info
        final indexInfo = await db.rawQuery('PRAGMA index_info($indexName)');
        
        analysis['index_details'].add({
          'name': indexName,
          'table': tableName,
          'columns': indexInfo.map((info) => info['name']).toList(),
          'column_count': indexInfo.length,
          'sql': index['sql'],
        });
      }
      
      return analysis;
    } catch (e) {
      print('DatabaseHelper: Error analyzing index performance: $e');
      return {
        'error': e.toString(),
        'total_indexes': 0,
        'indexes_by_table': <String, int>{},
        'index_details': <Map<String, dynamic>>[],
      };
    }
  }

  /// Rebuild all indexes (maintenance operation)
  Future<void> rebuildAllIndexes() async {
    try {
      final db = await database;
      print('DatabaseHelper: Starting index rebuild process');
      
      await db.execute('REINDEX');
      
      print('DatabaseHelper: All indexes rebuilt successfully');
    } catch (e) {
      print('DatabaseHelper: Error rebuilding indexes: $e');
      rethrow;
    }
  }

  /// Analyze database size and storage
  Future<Map<String, dynamic>> analyzeDatabaseStorage() async {
    try {
      final db = await database;
      
      // Get page count and page size
      final pageCountResult = await db.rawQuery('PRAGMA page_count');
      final pageSizeResult = await db.rawQuery('PRAGMA page_size');
      
      final pageCount = pageCountResult.first['page_count'] as int? ?? 0;
      final pageSize = pageSizeResult.first['page_size'] as int? ?? 0;
      final totalSize = pageCount * pageSize;
      
      // Get table sizes
      final tables = [informationTable, tagsTable, informationTagsTable, _versionTableName];
      final tableSizes = <String, int>{};
      
      for (final table in tables) {
        try {
          final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
          tableSizes[table] = result.first['count'] as int? ?? 0;
        } catch (e) {
          tableSizes[table] = 0;
        }
      }
      
      return {
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'page_count': pageCount,
        'page_size': pageSize,
        'table_row_counts': tableSizes,
      };
    } catch (e) {
      print('DatabaseHelper: Error analyzing database storage: $e');
      return {
        'error': e.toString(),
        'total_size_bytes': 0,
        'total_size_mb': '0.00',
        'page_count': 0,
        'page_size': 0,
        'table_row_counts': <String, int>{},
      };
    }
  }

  /// Optimize database performance
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      print('DatabaseHelper: Starting database optimization');
      
      // Analyze all tables
      await db.execute('ANALYZE');
      
      // Rebuild indexes
      await rebuildAllIndexes();
      
      // Vacuum database to reclaim space
      await db.execute('VACUUM');
      
      print('DatabaseHelper: Database optimization completed');
    } catch (e) {
      print('DatabaseHelper: Error optimizing database: $e');
      rethrow;
    }
  }

  /// Test migration to a specific version (for testing purposes)
  Future<bool> testMigrationToVersion(int targetVersion) async {
    try {
      print('DatabaseHelper: Testing migration to version $targetVersion');
      
      // Validate target version
      if (!_isVersionSupported(targetVersion)) {
        throw Exception('Target version $targetVersion is not supported');
      }
      
      final currentVersion = await getCurrentDatabaseVersion();
      if (currentVersion >= targetVersion) {
        print('DatabaseHelper: Already at or above target version');
        return true;
      }
      
      // Simulate the migration without actually changing the database
      print('DatabaseHelper: Migration test would migrate from $currentVersion to $targetVersion');
      
      // Check if all required tables exist
      for (int version = currentVersion + 1; version <= targetVersion; version++) {
        await _verifyRequiredTablesForMigration(await database, version);
      }
      
      print('DatabaseHelper: Migration test passed');
      return true;
    } catch (e) {
      print('DatabaseHelper: Migration test failed: $e');
      return false;
    }
  }

  /// Get migration status for all versions
  Future<List<Map<String, dynamic>>> getMigrationStatus() async {
    try {
      final currentVersion = await getCurrentDatabaseVersion();
      final migrationStatus = <Map<String, dynamic>>[];
      
      for (int version = 1; version <= _maximumSupportedVersion; version++) {
        final versionInfo = getVersionInfo(version);
        final isApplied = version <= currentVersion;
        final canApply = version == currentVersion + 1;
        
        migrationStatus.add({
          'version': version,
          'name': versionInfo['name'],
          'description': versionInfo['description'],
          'is_applied': isApplied,
          'can_apply': canApply,
          'is_current': version == currentVersion,
          'supported': versionInfo['supported'],
        });
      }
      
      return migrationStatus;
    } catch (e) {
      print('DatabaseHelper: Error getting migration status: $e');
      return [];
    }
  }

  /// Clean up old backup tables
  Future<void> cleanupOldBackups() async {
    try {
      final db = await database;
      print('DatabaseHelper: Cleaning up old backup tables');
      
      // Get all backup tables
      final backupTables = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name LIKE '%_backup_%'
        ORDER BY name
      ''');
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneWeekAgo = now - (7 * 24 * 60 * 60 * 1000); // 1 week in milliseconds
      
      for (final table in backupTables) {
        final tableName = table['name'] as String;
        
        // Extract timestamp from table name
        final parts = tableName.split('_');
        if (parts.length >= 3) {
          try {
            final timestamp = int.parse(parts.last);
            if (timestamp < oneWeekAgo) {
              await db.execute('DROP TABLE IF EXISTS $tableName');
              print('DatabaseHelper: Dropped old backup table: $tableName');
            }
          } catch (e) {
            // Skip if timestamp parsing fails
          }
        }
      }
      
      print('DatabaseHelper: Backup cleanup completed');
    } catch (e) {
      print('DatabaseHelper: Error cleaning up backups: $e');
      rethrow;
    }
  }

  /// Validate database structure consistency
  Future<Map<String, dynamic>> validateDatabaseStructure() async {
    try {
      final db = await database;
      final validation = <String, dynamic>{
        'is_valid': true,
        'errors': <String>[],
        'warnings': <String>[],
        'tables_checked': 0,
        'indexes_checked': 0,
      };
      
      // Check integrity
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      if (integrityResult.first['integrity_check'] != 'ok') {
        validation['is_valid'] = false;
        validation['errors'].add('Database integrity check failed');
      }
      
      // Check foreign key constraints
      final foreignKeyResult = await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeyResult.isNotEmpty) {
        validation['is_valid'] = false;
        validation['errors'].add('Foreign key constraint violations found');
      }
      
      // Check that all expected tables exist
      final expectedTables = [informationTable, tagsTable, informationTagsTable, _versionTableName];
      for (final table in expectedTables) {
        final result = await db.rawQuery('''
          SELECT name FROM sqlite_master 
          WHERE type='table' AND name='$table'
        ''');
        
        if (result.isEmpty) {
          validation['is_valid'] = false;
          validation['errors'].add('Required table $table is missing');
        } else {
          validation['tables_checked'] = (validation['tables_checked'] as int) + 1;
        }
      }
      
      // Check indexes
      final indexes = await getAllIndexes();
      validation['indexes_checked'] = indexes.length;
      
      if (indexes.length < 20) { // We should have many indexes
        validation['warnings'].add('Fewer indexes than expected (${indexes.length})');
      }
      
      return validation;
    } catch (e) {
      return {
        'is_valid': false,
        'errors': ['Validation failed: $e'],
        'warnings': <String>[],
        'tables_checked': 0,
        'indexes_checked': 0,
      };
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
      
      // Additional performance indexes
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_archived 
        ON $informationTable ($colIsArchived)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_updated_at 
        ON $informationTable ($colUpdatedAt)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_source 
        ON $informationTable ($colSource)
      ''');
      
      // Composite indexes for common query patterns
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_type_importance 
        ON $informationTable ($colType, $colImportance)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_favorite_created 
        ON $informationTable ($colIsFavorite, $colCreatedAt)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_archived_updated 
        ON $informationTable ($colIsArchived, $colUpdatedAt)
      ''');
      
      print('DatabaseHelper: Information table created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating information table: $e');
      rethrow;
    }
  }

  /// Create tags table
  Future<void> _createTagsTable(Database db) async {
    try {
      print('DatabaseHelper: Creating tags table');
      
      const String createTagsTableSQL = '''
        CREATE TABLE $tagsTable (
          $colTagId TEXT PRIMARY KEY,
          $colTagName TEXT NOT NULL UNIQUE,
          $colTagColor TEXT NOT NULL DEFAULT '#2196F3',
          $colTagDescription TEXT,
          $colTagUsageCount INTEGER NOT NULL DEFAULT 0,
          $colTagCreatedAt TEXT NOT NULL,
          $colTagUpdatedAt TEXT NOT NULL
        )
      ''';
      
      await db.execute(createTagsTableSQL);
      
      // Create indexes for better performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_name 
        ON $tagsTable ($colTagName)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_color 
        ON $tagsTable ($colTagColor)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_usage_count 
        ON $tagsTable ($colTagUsageCount)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_created_at 
        ON $tagsTable ($colTagCreatedAt)
      ''');
      
      // Additional performance indexes for tags
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_updated_at 
        ON $tagsTable ($colTagUpdatedAt)
      ''');
      
      // Composite indexes for common tag queries
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_color_usage 
        ON $tagsTable ($colTagColor, $colTagUsageCount)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_usage_created 
        ON $tagsTable ($colTagUsageCount, $colTagCreatedAt)
      ''');
      
      print('DatabaseHelper: Tags table created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating tags table: $e');
      rethrow;
    }
  }

  /// Create information_tags junction table
  Future<void> _createInformationTagsTable(Database db) async {
    try {
      print('DatabaseHelper: Creating information_tags junction table');
      
      const String createInformationTagsTableSQL = '''
        CREATE TABLE $informationTagsTable (
          $colInformationId TEXT NOT NULL,
          $colJunctionTagId TEXT NOT NULL,
          $colAssignedAt TEXT NOT NULL,
          $colAssignedBy TEXT DEFAULT 'system',
          PRIMARY KEY ($colInformationId, $colJunctionTagId),
          FOREIGN KEY ($colInformationId) REFERENCES $informationTable ($colId) ON DELETE CASCADE,
          FOREIGN KEY ($colJunctionTagId) REFERENCES $tagsTable ($colTagId) ON DELETE CASCADE
        )
      ''';
      
      await db.execute(createInformationTagsTableSQL);
      
      // Create indexes for better performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_information_id 
        ON $informationTagsTable ($colInformationId)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_tag_id 
        ON $informationTagsTable ($colJunctionTagId)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_assigned_at 
        ON $informationTagsTable ($colAssignedAt)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_composite 
        ON $informationTagsTable ($colInformationId, $colJunctionTagId)
      ''');
      
      // Additional performance indexes for junction table
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_assigned_by 
        ON $informationTagsTable ($colAssignedBy)
      ''');
      
      // Composite indexes for advanced junction table queries
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_tag_assigned 
        ON $informationTagsTable ($colJunctionTagId, $colAssignedAt)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_info_assigned 
        ON $informationTagsTable ($colInformationId, $colAssignedAt)
      ''');
      
      print('DatabaseHelper: Information_tags junction table created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating information_tags junction table: $e');
      rethrow;
    }
  }

  /// Create version history table
  Future<void> _createVersionHistoryTable(Database db) async {
    try {
      print('DatabaseHelper: Creating version history table');
      
      const String createVersionHistoryTableSQL = '''
        CREATE TABLE $_versionTableName (
          $colVersionId INTEGER PRIMARY KEY AUTOINCREMENT,
          $colVersionNumber INTEGER NOT NULL,
          $colVersionName TEXT NOT NULL,
          $colMigrationDate TEXT NOT NULL,
          $colMigrationDuration INTEGER NOT NULL DEFAULT 0,
          $colMigrationNotes TEXT,
          $colAppVersion TEXT
        )
      ''';
      
      await db.execute(createVersionHistoryTableSQL);
      
      // Create index for version number
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_version_history_number 
        ON $_versionTableName ($colVersionNumber)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_version_history_date 
        ON $_versionTableName ($colMigrationDate)
      ''');
      
      print('DatabaseHelper: Version history table created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating version history table: $e');
      rethrow;
    }
  }

  /// Ensure version history table exists (for existing databases)
  Future<void> _ensureVersionHistoryTableExists(Database db) async {
    try {
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='$_versionTableName'
      ''');
      
      if (tableExists.isEmpty) {
        await _createVersionHistoryTable(db);
      }
    } catch (e) {
      print('DatabaseHelper: Error ensuring version history table exists: $e');
      rethrow;
    }
  }

  /// Record version history entry
  Future<void> _recordVersionHistory(
    Database db,
    int version,
    int durationMs,
    String notes,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final versionName = versionNames[version] ?? 'Unknown Version';
      
      await db.insert(_versionTableName, {
        colVersionNumber: version,
        colVersionName: versionName,
        colMigrationDate: now,
        colMigrationDuration: durationMs,
        colMigrationNotes: notes,
        colAppVersion: '1.0.0', // This could be dynamic based on app version
      });
      
      print('DatabaseHelper: Recorded version $version in history (${durationMs}ms)');
    } catch (e) {
      print('DatabaseHelper: Error recording version history: $e');
      rethrow;
    }
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