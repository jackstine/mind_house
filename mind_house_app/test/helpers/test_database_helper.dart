import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/models/information_tag.dart';

/// Test database helper for managing test database lifecycle
class TestDatabaseHelper {
  static Database? _database;
  static DatabaseHelper? _databaseHelper;

  /// Initialize FFI for testing
  static void setupTestDatabase() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /// Get test database instance
  static Future<Database> getTestDatabase() async {
    if (_database == null) {
      _databaseHelper = DatabaseHelper();
      _database = await _databaseHelper!.database;
    }
    return _database!;
  }

  /// Clear all data from test database
  static Future<void> clearTestDatabase() async {
    final db = await getTestDatabase();
    await db.transaction((txn) async {
      await txn.delete('information_tags');
      await txn.delete('tags');
      await txn.delete('information');
    });
  }

  /// Close test database
  static Future<void> closeTestDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _databaseHelper = null;
    }
  }

  /// Seed test database with sample data
  static Future<void> seedTestDatabase({
    List<Information>? information,
    List<Tag>? tags,
    List<InformationTag>? associations,
  }) async {
    final db = await getTestDatabase();
    
    await db.transaction((txn) async {
      // Insert information
      if (information != null) {
        for (final info in information) {
          await txn.insert('information', info.toMap());
        }
      }

      // Insert tags
      if (tags != null) {
        for (final tag in tags) {
          await txn.insert('tags', tag.toMap());
        }
      }

      // Insert associations
      if (associations != null) {
        for (final assoc in associations) {
          await txn.insert('information_tags', assoc.toMap());
        }
      }
    });
  }

  /// Create a fresh test database for each test
  static Future<Database> createFreshTestDatabase() async {
    // Close existing database
    await closeTestDatabase();
    
    // Create new in-memory database
    final db = await openDatabase(
      ':memory:',
      version: DatabaseHelper.databaseVersion,
      onCreate: (db, version) async {
        await DatabaseHelper.createTables(db);
      },
    );
    
    _database = db;
    return db;
  }

  /// Verify database schema is correct
  static Future<bool> verifyDatabaseSchema() async {
    try {
      final db = await getTestDatabase();
      
      // Check if all required tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toSet();
      final expectedTables = {'information', 'tags', 'information_tags'};
      
      if (!expectedTables.every((table) => tableNames.contains(table))) {
        return false;
      }

      // Verify information table schema
      final infoColumns = await db.rawQuery('PRAGMA table_info(information)');
      final infoColumnNames = infoColumns.map((col) => col['name'] as String).toSet();
      final expectedInfoColumns = {'id', 'content', 'created_at', 'updated_at', 'is_deleted'};
      
      if (!expectedInfoColumns.every((col) => infoColumnNames.contains(col))) {
        return false;
      }

      // Verify tags table schema
      final tagColumns = await db.rawQuery('PRAGMA table_info(tags)');
      final tagColumnNames = tagColumns.map((col) => col['name'] as String).toSet();
      final expectedTagColumns = {'id', 'name', 'display_name', 'color', 'usage_count', 'created_at', 'last_used_at'};
      
      if (!expectedTagColumns.every((col) => tagColumnNames.contains(col))) {
        return false;
      }

      // Verify information_tags table schema
      final assocColumns = await db.rawQuery('PRAGMA table_info(information_tags)');
      final assocColumnNames = assocColumns.map((col) => col['name'] as String).toSet();
      final expectedAssocColumns = {'information_id', 'tag_id', 'created_at'};
      
      if (!expectedAssocColumns.every((col) => assocColumnNames.contains(col))) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get database statistics for performance testing
  static Future<Map<String, int>> getDatabaseStats() async {
    final db = await getTestDatabase();
    
    final infoCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM information')
    ) ?? 0;
    
    final tagCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tags')
    ) ?? 0;
    
    final assocCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM information_tags')
    ) ?? 0;

    return {
      'information_count': infoCount,
      'tag_count': tagCount,
      'association_count': assocCount,
    };
  }

  /// Execute performance timing test on database operation
  static Future<Duration> timeOperation(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Create test database with large dataset for performance testing
  static Future<void> createPerformanceTestDatabase({
    int informationCount = 1000,
    int tagCount = 500,
    int associationsCount = 2000,
  }) async {
    await createFreshTestDatabase();
    final db = await getTestDatabase();

    await db.transaction((txn) async {
      // Insert large number of information items
      for (int i = 0; i < informationCount; i++) {
        await txn.insert('information', {
          'id': 'perf-info-$i',
          'content': 'Performance test information item #$i with some content',
          'created_at': DateTime.now().subtract(Duration(minutes: i)).millisecondsSinceEpoch,
          'updated_at': DateTime.now().subtract(Duration(seconds: i)).millisecondsSinceEpoch,
          'is_deleted': 0,
        });
      }

      // Insert large number of tags
      for (int i = 0; i < tagCount; i++) {
        await txn.insert('tags', {
          'id': 'perf-tag-$i',
          'name': 'tag_$i',
          'display_name': 'Tag $i',
          'color': 'FF${(i % 256).toRadixString(16).padLeft(2, '0')}00',
          'usage_count': i % 100,
          'created_at': DateTime.now().subtract(Duration(hours: i)).millisecondsSinceEpoch,
          'last_used_at': DateTime.now().subtract(Duration(minutes: i * 2)).millisecondsSinceEpoch,
        });
      }

      // Insert associations
      for (int i = 0; i < associationsCount; i++) {
        final infoIndex = i % informationCount;
        final tagIndex = i % tagCount;
        await txn.insert('information_tags', {
          'information_id': 'perf-info-$infoIndex',
          'tag_id': 'perf-tag-$tagIndex',
          'created_at': DateTime.now().subtract(Duration(seconds: i)).millisecondsSinceEpoch,
        });
      }
    });
  }

  /// Verify data integrity in test database
  static Future<List<String>> verifyDataIntegrity() async {
    final db = await getTestDatabase();
    final issues = <String>[];

    try {
      // Check for orphaned associations
      final orphanedAssociations = await db.rawQuery('''
        SELECT COUNT(*) as count FROM information_tags it
        LEFT JOIN information i ON it.information_id = i.id
        LEFT JOIN tags t ON it.tag_id = t.id
        WHERE i.id IS NULL OR t.id IS NULL
      ''');
      
      final orphanedCount = orphanedAssociations.first['count'] as int;
      if (orphanedCount > 0) {
        issues.add('Found $orphanedCount orphaned information_tag associations');
      }

      // Check for duplicate associations
      final duplicateAssociations = await db.rawQuery('''
        SELECT information_id, tag_id, COUNT(*) as count
        FROM information_tags
        GROUP BY information_id, tag_id
        HAVING COUNT(*) > 1
      ''');
      
      if (duplicateAssociations.isNotEmpty) {
        issues.add('Found ${duplicateAssociations.length} duplicate associations');
      }

      // Check for invalid dates
      final invalidDates = await db.rawQuery('''
        SELECT COUNT(*) as count FROM information
        WHERE created_at > updated_at
      ''');
      
      final invalidCount = invalidDates.first['count'] as int;
      if (invalidCount > 0) {
        issues.add('Found $invalidCount information items with created_at > updated_at');
      }

    } catch (e) {
      issues.add('Error during data integrity check: $e');
    }

    return issues;
  }
}