import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/database/database_helper.dart';

void main() {
  group('DatabaseHelper Tests', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize Flutter binding for testing
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI for testing
      sqfliteFfiInit();
      // Use the ffi factory for testing
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper();
    });

    tearDown(() async {
      // Clean up database after each test
      try {
        await databaseHelper.deleteDatabase();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('DatabaseHelper should be a singleton', () {
      final instance1 = DatabaseHelper();
      final instance2 = DatabaseHelper();
      expect(instance1, equals(instance2));
    });

    test('Database should initialize successfully', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('Database health check should pass', () async {
      final isHealthy = await databaseHelper.isDatabaseHealthy();
      expect(isHealthy, isTrue);
    });

    test('Manual database initialization should work', () async {
      await databaseHelper.initializeDatabase();
      final isHealthy = await databaseHelper.isDatabaseHealthy();
      expect(isHealthy, isTrue);
    });

    test('Database path should be valid', () async {
      final path = await databaseHelper.getDatabasePath();
      expect(path, isNotEmpty);
      expect(path.endsWith('mind_house.db'), isTrue);
    });

    test('Information table should be created with correct schema', () async {
      final db = await databaseHelper.database;
      
      // Verify table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='information'
      ''');
      expect(tableExists.isNotEmpty, isTrue);
      
      // Verify schema
      final schemaValid = await databaseHelper.verifyInformationTableSchema();
      expect(schemaValid, isTrue);
      
      // Verify columns
      final columns = await databaseHelper.getInformationTableColumns();
      expect(columns.contains('id'), isTrue);
      expect(columns.contains('title'), isTrue);
      expect(columns.contains('content'), isTrue);
      expect(columns.contains('type'), isTrue);
      expect(columns.contains('created_at'), isTrue);
      expect(columns.contains('updated_at'), isTrue);
    });

    test('Information table indexes should be created', () async {
      final db = await databaseHelper.database;
      
      // Check if indexes exist
      final indexes = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='index' AND tbl_name='information'
      ''');
      
      expect(indexes.isNotEmpty, isTrue);
      
      // Verify specific indexes
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();
      expect(indexNames.contains('idx_information_title'), isTrue);
      expect(indexNames.contains('idx_information_type'), isTrue);
      expect(indexNames.contains('idx_information_created_at'), isTrue);
    });

    test('Tags table should be created with correct schema', () async {
      final db = await databaseHelper.database;
      
      // Verify table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='tags'
      ''');
      expect(tableExists.isNotEmpty, isTrue);
      
      // Verify schema
      final schemaValid = await databaseHelper.verifyTagsTableSchema();
      expect(schemaValid, isTrue);
      
      // Verify columns
      final columns = await databaseHelper.getTagsTableColumns();
      expect(columns.contains('id'), isTrue);
      expect(columns.contains('name'), isTrue);
      expect(columns.contains('color'), isTrue);
      expect(columns.contains('description'), isTrue);
      expect(columns.contains('usage_count'), isTrue);
      expect(columns.contains('created_at'), isTrue);
      expect(columns.contains('updated_at'), isTrue);
    });

    test('Tags table indexes should be created', () async {
      final db = await databaseHelper.database;
      
      // Check if indexes exist
      final indexes = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='index' AND tbl_name='tags'
      ''');
      
      expect(indexes.isNotEmpty, isTrue);
      
      // Verify specific indexes
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();
      expect(indexNames.contains('idx_tags_name'), isTrue);
      expect(indexNames.contains('idx_tags_color'), isTrue);
      expect(indexNames.contains('idx_tags_usage_count'), isTrue);
    });

    test('Tag color utilities should work correctly', () {
      // Test random color generation
      final randomColor = DatabaseHelper.getRandomTagColor();
      expect(randomColor, isNotEmpty);
      expect(DatabaseHelper.isValidHexColor(randomColor), isTrue);
      
      // Test hex color validation
      expect(DatabaseHelper.isValidHexColor('#FF0000'), isTrue);
      expect(DatabaseHelper.isValidHexColor('#abc'), isTrue);
      expect(DatabaseHelper.isValidHexColor('FF0000'), isFalse);
      expect(DatabaseHelper.isValidHexColor('#GG0000'), isFalse);
      expect(DatabaseHelper.isValidHexColor('#FF00'), isFalse);
      
      // Test predefined colors
      expect(DatabaseHelper.predefinedTagColors.length, greaterThan(10));
      for (final color in DatabaseHelper.predefinedTagColors) {
        expect(DatabaseHelper.isValidHexColor(color), isTrue);
      }
    });

    test('Information_tags junction table should be created with correct schema', () async {
      final db = await databaseHelper.database;
      
      // Verify table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='information_tags'
      ''');
      expect(tableExists.isNotEmpty, isTrue);
      
      // Verify schema
      final schemaValid = await databaseHelper.verifyInformationTagsTableSchema();
      expect(schemaValid, isTrue);
      
      // Verify columns
      final columns = await databaseHelper.getInformationTagsTableColumns();
      expect(columns.contains('information_id'), isTrue);
      expect(columns.contains('tag_id'), isTrue);
      expect(columns.contains('assigned_at'), isTrue);
      expect(columns.contains('assigned_by'), isTrue);
    });

    test('Information_tags junction table indexes should be created', () async {
      final db = await databaseHelper.database;
      
      // Check if indexes exist
      final indexes = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='index' AND tbl_name='information_tags'
      ''');
      
      expect(indexes.isNotEmpty, isTrue);
      
      // Verify specific indexes
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();
      expect(indexNames.contains('idx_information_tags_information_id'), isTrue);
      expect(indexNames.contains('idx_information_tags_tag_id'), isTrue);
      expect(indexNames.contains('idx_information_tags_assigned_at'), isTrue);
      expect(indexNames.contains('idx_information_tags_composite'), isTrue);
    });

    test('Information_tags junction table foreign keys should be enforced', () async {
      final db = await databaseHelper.database;
      
      // Check foreign key constraints
      final foreignKeys = await db.rawQuery('PRAGMA foreign_key_list(information_tags)');
      expect(foreignKeys.length, equals(2));
      
      // Verify foreign key table references
      final tableRefs = foreignKeys.map((fk) => fk['table'] as String).toList();
      expect(tableRefs.contains('information'), isTrue);
      expect(tableRefs.contains('tags'), isTrue);
    });

    test('Version management utilities should work correctly', () {
      // Test version support checking
      expect(DatabaseHelper.getVersionInfo(1)['supported'], isTrue);
      expect(DatabaseHelper.getVersionInfo(5)['supported'], isTrue);
      expect(DatabaseHelper.getVersionInfo(10)['supported'], isTrue);
      expect(DatabaseHelper.getVersionInfo(0)['supported'], isFalse);
      expect(DatabaseHelper.getVersionInfo(11)['supported'], isFalse);
      
      // Test version info
      final versionInfo = DatabaseHelper.getVersionInfo(1);
      expect(versionInfo['version'], equals(1));
      expect(versionInfo['name'], equals('Initial Schema'));
      expect(versionInfo['description'], contains('Basic information'));
      
      // Test all supported versions
      final supportedVersions = DatabaseHelper.getAllSupportedVersions();
      expect(supportedVersions.length, equals(10));
      expect(supportedVersions.first['version'], equals(1));
      expect(supportedVersions.last['version'], equals(10));
    });

    test('Database version history table should be created', () async {
      final db = await databaseHelper.database;
      
      // Verify version history table exists
      final tableExists = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name='database_version_history'
      ''');
      expect(tableExists.isNotEmpty, isTrue);
      
      // Verify version history has been recorded
      final history = await databaseHelper.getVersionHistory();
      expect(history.isNotEmpty, isTrue);
      expect(history.first['version_number'], equals(1));
      expect(history.first['version_name'], equals('Initial Schema'));
    });

    test('Database indexes should be created and analyzed', () async {
      final db = await databaseHelper.database;
      
      // Get all indexes
      final allIndexes = await databaseHelper.getAllIndexes();
      expect(allIndexes.isNotEmpty, isTrue);
      
      // Verify we have indexes for all main tables
      final indexTables = allIndexes.map((idx) => idx['tbl_name'] as String).toSet();
      expect(indexTables.contains('information'), isTrue);
      expect(indexTables.contains('tags'), isTrue);
      expect(indexTables.contains('information_tags'), isTrue);
      
      // Verify index analysis works
      final analysis = await databaseHelper.analyzeIndexPerformance();
      expect(analysis['total_indexes'], greaterThan(15)); // We should have many indexes
      expect(analysis['indexes_by_table'], isNotEmpty);
      expect(analysis['index_details'], isNotEmpty);
      
      // Verify specific table indexes
      final infoIndexes = await databaseHelper.getTableIndexes('information');
      expect(infoIndexes.length, greaterThan(5)); // Should have multiple indexes
      
      final tagIndexes = await databaseHelper.getTableIndexes('tags');
      expect(tagIndexes.length, greaterThan(3)); // Should have multiple indexes
    });

    test('Database storage analysis should work', () async {
      final storageAnalysis = await databaseHelper.analyzeDatabaseStorage();
      
      expect(storageAnalysis['total_size_bytes'], isA<int>());
      expect(storageAnalysis['total_size_mb'], isA<String>());
      expect(storageAnalysis['page_count'], isA<int>());
      expect(storageAnalysis['page_size'], isA<int>());
      expect(storageAnalysis['table_row_counts'], isA<Map>());
      
      // Should have row counts for all tables
      final rowCounts = storageAnalysis['table_row_counts'] as Map;
      expect(rowCounts.containsKey('information'), isTrue);
      expect(rowCounts.containsKey('tags'), isTrue);
      expect(rowCounts.containsKey('information_tags'), isTrue);
      expect(rowCounts.containsKey('database_version_history'), isTrue);
    });
  });
}