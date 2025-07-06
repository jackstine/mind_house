import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/exceptions/database_exception.dart';

void main() {
  group('InformationRepository Tests', () {
    late Database database;
    late InformationRepository repository;

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
            CREATE TABLE information (
              id TEXT PRIMARY KEY,
              content TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        },
      );
      repository = InformationRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should create information successfully', () async {
      // Arrange
      final information = Information(content: 'Test content');

      // Act
      final result = await repository.create(information);

      // Assert
      expect(result.id, information.id);
      expect(result.content, 'Test content');
    });

    test('should retrieve information by id', () async {
      // Arrange
      final information = Information(content: 'Test content');
      await repository.create(information);

      // Act
      final result = await repository.getById(information.id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, information.id);
      expect(result.content, 'Test content');
    });

    test('should return null when information not found', () async {
      // Act
      final result = await repository.getById('non-existent-id');

      // Assert
      expect(result, isNull);
    });

    test('should retrieve all information', () async {
      // Arrange
      final info1 = Information(content: 'Content 1');
      final info2 = Information(content: 'Content 2');
      await repository.create(info1);
      await repository.create(info2);

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 2);
      expect(results.any((info) => info.content == 'Content 1'), true);
      expect(results.any((info) => info.content == 'Content 2'), true);
    });

    test('should retrieve all information ordered by creation date desc', () async {
      // Arrange
      final info1 = Information(
        content: 'First content',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      );
      final info2 = Information(
        content: 'Second content',
        createdAt: DateTime.now(),
      );
      await repository.create(info1);
      await repository.create(info2);

      // Act
      final results = await repository.getAll();

      // Assert
      expect(results.length, 2);
      expect(results.first.content, 'Second content'); // Most recent first
      expect(results.last.content, 'First content');
    });

    test('should update information successfully', () async {
      // Arrange
      final information = Information(content: 'Original content');
      await repository.create(information);
      final updatedInfo = information.copyWith(
        content: 'Updated content',
        updatedAt: DateTime.now().add(Duration(minutes: 1)),
      );

      // Act
      final result = await repository.update(updatedInfo);

      // Assert
      expect(result.content, 'Updated content');
      expect(result.id, information.id);
    });

    test('should delete information successfully', () async {
      // Arrange
      final information = Information(content: 'To be deleted');
      await repository.create(information);

      // Act
      await repository.delete(information.id);

      // Assert
      final result = await repository.getById(information.id);
      expect(result, isNull);
    });

    test('should return empty list when no information exists', () async {
      // Act
      final results = await repository.getAll();

      // Assert
      expect(results, isEmpty);
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

    test('should search information by content', () async {
      // Arrange
      final info1 = Information(content: 'Flutter development tips');
      final info2 = Information(content: 'Dart programming guide');
      final info3 = Information(content: 'Mobile app testing');
      await repository.create(info1);
      await repository.create(info2);
      await repository.create(info3);

      // Act
      final results = await repository.searchByContent('Flutter');

      // Assert
      expect(results.length, 1);
      expect(results.first.content, 'Flutter development tips');
    });

    test('should search information case insensitive', () async {
      // Arrange
      final information = Information(content: 'Flutter Development');
      await repository.create(information);

      // Act
      final results = await repository.searchByContent('flutter');

      // Assert
      expect(results.length, 1);
      expect(results.first.content, 'Flutter Development');
    });

    test('should count total information items', () async {
      // Arrange
      await repository.create(Information(content: 'Content 1'));
      await repository.create(Information(content: 'Content 2'));
      await repository.create(Information(content: 'Content 3'));

      // Act
      final count = await repository.count();

      // Assert
      expect(count, 3);
    });
  });
}