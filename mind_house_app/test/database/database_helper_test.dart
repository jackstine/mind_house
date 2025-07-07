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
  });
}