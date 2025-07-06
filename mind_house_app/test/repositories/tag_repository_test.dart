import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/exceptions/database_exception.dart';

void main() {
  group('TagRepository Tests', () {
    late Database database;
    late TagRepository repository;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create in-memory database for testing
      database = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tags (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE NOT NULL,
              color TEXT,
              usage_count INTEGER DEFAULT 0,
              created_at INTEGER NOT NULL
            )
          ''');
        },
      );
      repository = TagRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should create tag successfully', () async {
      // Arrange
      final tag = Tag(name: 'work');

      // Act
      final result = await repository.create(tag);

      // Assert
      expect(result.id, isNotNull);
      expect(result.name, 'work');
      expect(result.usageCount, 0);
    });

    test('should retrieve tag by id', () async {
      // Arrange
      final tag = Tag(name: 'personal');
      final created = await repository.create(tag);

      // Act
      final result = await repository.getById(created.id!);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, created.id);
      expect(result.name, 'personal');
    });

    test('should return null when tag not found', () async {
      // Act
      final result = await repository.getById(999);

      // Assert
      expect(result, isNull);
    });

    test('should retrieve all tags ordered by usage count desc', () async {
      // Arrange
      final tag1 = Tag(name: 'work', usageCount: 5);
      final tag2 = Tag(name: 'personal', usageCount: 10);
      final tag3 = Tag(name: 'project', usageCount: 2);
      await repository.create(tag1);
      await repository.create(tag2);
      await repository.create(tag3);

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 3);
      expect(results[0].name, 'personal'); // Highest usage first
      expect(results[1].name, 'work');
      expect(results[2].name, 'project');
    });

    test('should update tag successfully', () async {
      // Arrange
      final tag = Tag(name: 'original');
      final created = await repository.create(tag);
      final updated = created.copyWith(
        name: 'updated',
        color: '#FF5722',
        usageCount: 5,
      );

      // Act
      final result = await repository.update(updated);

      // Assert
      expect(result.name, 'updated');
      expect(result.color, '#FF5722');
      expect(result.usageCount, 5);
    });

    test('should delete tag successfully', () async {
      // Arrange
      final tag = Tag(name: 'to-delete');
      final created = await repository.create(tag);

      // Act
      await repository.delete(created.id!);

      // Assert
      final result = await repository.getById(created.id!);
      expect(result, isNull);
    });

    test('should find tag by name', () async {
      // Arrange
      final tag = Tag(name: 'work');
      await repository.create(tag);

      // Act
      final result = await repository.findByName('work');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'work');
    });

    test('should find tag by name case insensitive', () async {
      // Arrange
      final tag = Tag(name: 'Work Project');
      await repository.create(tag);

      // Act
      final result = await repository.findByName('work project');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'Work Project');
    });

    test('should get tag suggestions by prefix', () async {
      // Arrange
      await repository.create(Tag(name: 'work', usageCount: 10));
      await repository.create(Tag(name: 'workout', usageCount: 5));
      await repository.create(Tag(name: 'personal', usageCount: 8));
      await repository.create(Tag(name: 'project', usageCount: 3));

      // Act
      final results = await repository.getSuggestions('wo');

      // Assert
      expect(results.length, 2);
      expect(results[0].name, 'work'); // Higher usage first
      expect(results[1].name, 'workout');
    });

    test('should limit tag suggestions', () async {
      // Arrange
      for (int i = 0; i < 15; i++) {
        await repository.create(Tag(name: 'work$i', usageCount: i));
      }

      // Act
      final results = await repository.getSuggestions('work', limit: 5);

      // Assert
      expect(results.length, 5);
    });

    test('should increment tag usage count', () async {
      // Arrange
      final tag = Tag(name: 'test', usageCount: 3);
      final created = await repository.create(tag);

      // Act
      await repository.incrementUsageCount(created.id!);

      // Assert
      final updated = await repository.getById(created.id!);
      expect(updated!.usageCount, 4);
    });

    test('should get most used tags', () async {
      // Arrange
      await repository.create(Tag(name: 'work', usageCount: 10));
      await repository.create(Tag(name: 'personal', usageCount: 8));
      await repository.create(Tag(name: 'project', usageCount: 15));
      await repository.create(Tag(name: 'test', usageCount: 2));

      // Act
      final results = await repository.getMostUsed(limit: 2);

      // Assert
      expect(results.length, 2);
      expect(results[0].name, 'project');
      expect(results[1].name, 'work');
    });

    test('should get unused tags', () async {
      // Arrange
      await repository.create(Tag(name: 'used', usageCount: 5));
      await repository.create(Tag(name: 'unused1', usageCount: 0));
      await repository.create(Tag(name: 'unused2', usageCount: 0));

      // Act
      final results = await repository.getUnused();

      // Assert
      expect(results.length, 2);
      expect(results.any((tag) => tag.name == 'unused1'), true);
      expect(results.any((tag) => tag.name == 'unused2'), true);
    });

    test('should count total tags', () async {
      // Arrange
      await repository.create(Tag(name: 'tag1'));
      await repository.create(Tag(name: 'tag2'));
      await repository.create(Tag(name: 'tag3'));

      // Act
      final count = await repository.count();

      // Assert
      expect(count, 3);
    });

    test('should handle duplicate tag name error', () async {
      // Arrange
      await repository.create(Tag(name: 'duplicate'));

      // Act & Assert
      expect(
        () async => await repository.create(Tag(name: 'duplicate')),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('should handle database errors gracefully', () async {
      // Arrange
      await database.close(); // Close database to cause error

      // Act & Assert
      expect(
        () async => await repository.getAll(),
        throwsA(isA<RepositoryException>()),
      );
    });
  });
}