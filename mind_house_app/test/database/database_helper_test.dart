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
  });
}