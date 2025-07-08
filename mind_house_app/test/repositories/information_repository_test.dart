import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/database/database_helper.dart';

void main() {
  // Initialize ffi loader for testing
  sqfliteFfiInit();
  
  late InformationRepository repository;
  late DatabaseHelper databaseHelper;
  
  setUpAll(() async {
    // Use in-memory database for testing
    databaseFactory = databaseFactoryFfi;
  });
  
  setUp(() async {
    databaseHelper = DatabaseHelper.instance;
    repository = InformationRepository();
    
    // Initialize database for each test
    await databaseHelper.database;
  });
  
  tearDown(() async {
    // Close database after each test
    await databaseHelper.close();
  });

  group('InformationRepository Tests', () {
    test('should create and retrieve information', () async {
      // Create test information
      final information = Information(
        title: 'Test Title',
        content: 'Test content for information',
        type: InformationType.note,
        importance: 5,
      );
      
      // Create information in database
      final createdId = await repository.create(information);
      expect(createdId, equals(information.id));
      
      // Retrieve information from database
      final retrieved = await repository.getById(information.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(information.id));
      expect(retrieved.title, equals(information.title));
      expect(retrieved.content, equals(information.content));
      expect(retrieved.type, equals(information.type));
      expect(retrieved.importance, equals(information.importance));
    });
    
    test('should update existing information', () async {
      // Create initial information
      final information = Information(
        title: 'Original Title',
        content: 'Original content',
        type: InformationType.note,
      );
      
      await repository.create(information);
      
      // Update information
      final updatedInfo = information.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
        importance: 8,
      );
      
      final updateResult = await repository.update(updatedInfo);
      expect(updateResult, isTrue);
      
      // Verify update
      final retrieved = await repository.getById(information.id);
      expect(retrieved!.title, equals('Updated Title'));
      expect(retrieved.content, equals('Updated content'));
      expect(retrieved.importance, equals(8));
      expect(retrieved.updatedAt.isAfter(information.updatedAt), isTrue);
    });
    
    test('should delete information', () async {
      // Create information
      final information = Information(
        title: 'To Delete',
        content: 'This will be deleted',
        type: InformationType.note,
      );
      
      await repository.create(information);
      
      // Verify it exists
      final beforeDelete = await repository.getById(information.id);
      expect(beforeDelete, isNotNull);
      
      // Delete information
      final deleteResult = await repository.delete(information.id);
      expect(deleteResult, isTrue);
      
      // Verify it's deleted
      final afterDelete = await repository.getById(information.id);
      expect(afterDelete, isNull);
    });
    
    test('should get all information items', () async {
      // Create multiple information items
      final info1 = Information(
        title: 'First Info',
        content: 'First content',
        type: InformationType.note,
      );
      
      final info2 = Information(
        title: 'Second Info',
        content: 'Second content',
        type: InformationType.bookmark,
        importance: 7,
      );
      
      final info3 = Information(
        title: 'Third Info',
        content: 'Third content',
        type: InformationType.task,
        isFavorite: true,
      );
      
      await repository.create(info1);
      await repository.create(info2);
      await repository.create(info3);
      
      // Get all information
      final allInfo = await repository.getAll();
      expect(allInfo.length, greaterThanOrEqualTo(3));
      
      // Verify our items are in the results
      final ids = allInfo.map((info) => info.id).toList();
      expect(ids, contains(info1.id));
      expect(ids, contains(info2.id));
      expect(ids, contains(info3.id));
    });
    
    test('should filter information by type', () async {
      // Create information of different types
      final note = Information(
        title: 'Note Info',
        content: 'Note content',
        type: InformationType.note,
      );
      
      final bookmark = Information(
        title: 'Bookmark Info',
        content: 'Bookmark content',
        type: InformationType.bookmark,
      );
      
      final task = Information(
        title: 'Task Info',
        content: 'Task content',
        type: InformationType.task,
      );
      
      await repository.create(note);
      await repository.create(bookmark);
      await repository.create(task);
      
      // Filter by type
      final notes = await repository.getByType(InformationType.note);
      final bookmarks = await repository.getByType(InformationType.bookmark);
      final tasks = await repository.getByType(InformationType.task);
      
      // Verify filtering
      expect(notes.any((info) => info.id == note.id), isTrue);
      expect(bookmarks.any((info) => info.id == bookmark.id), isTrue);
      expect(tasks.any((info) => info.id == task.id), isTrue);
      
      // Verify type consistency
      expect(notes.every((info) => info.type == InformationType.note), isTrue);
      expect(bookmarks.every((info) => info.type == InformationType.bookmark), isTrue);
      expect(tasks.every((info) => info.type == InformationType.task), isTrue);
    });
    
    test('should get favorite information items', () async {
      // Create favorite and non-favorite information
      final favorite1 = Information(
        title: 'Favorite 1',
        content: 'Favorite content 1',
        type: InformationType.note,
        isFavorite: true,
      );
      
      final favorite2 = Information(
        title: 'Favorite 2',
        content: 'Favorite content 2',
        type: InformationType.bookmark,
        isFavorite: true,
      );
      
      final nonFavorite = Information(
        title: 'Not Favorite',
        content: 'Not favorite content',
        type: InformationType.note,
        isFavorite: false,
      );
      
      await repository.create(favorite1);
      await repository.create(favorite2);
      await repository.create(nonFavorite);
      
      // Get favorites
      final favorites = await repository.getFavorites();
      
      // Verify favorites
      expect(favorites.any((info) => info.id == favorite1.id), isTrue);
      expect(favorites.any((info) => info.id == favorite2.id), isTrue);
      expect(favorites.any((info) => info.id == nonFavorite.id), isFalse);
      expect(favorites.every((info) => info.isFavorite), isTrue);
    });
    
    test('should get archived information items', () async {
      // Create archived and non-archived information
      final archived1 = Information(
        title: 'Archived 1',
        content: 'Archived content 1',
        type: InformationType.note,
        isArchived: true,
      );
      
      final archived2 = Information(
        title: 'Archived 2',
        content: 'Archived content 2',
        type: InformationType.task,
        isArchived: true,
      );
      
      final active = Information(
        title: 'Active',
        content: 'Active content',
        type: InformationType.note,
        isArchived: false,
      );
      
      await repository.create(archived1);
      await repository.create(archived2);
      await repository.create(active);
      
      // Get archived
      final archived = await repository.getArchived();
      
      // Verify archived
      expect(archived.any((info) => info.id == archived1.id), isTrue);
      expect(archived.any((info) => info.id == archived2.id), isTrue);
      expect(archived.any((info) => info.id == active.id), isFalse);
      expect(archived.every((info) => info.isArchived), isTrue);
    });
    
    test('should search information by title and content', () async {
      // Create information with searchable content
      final info1 = Information(
        title: 'Flutter Development',
        content: 'Learning Flutter widgets and state management',
        type: InformationType.note,
      );
      
      final info2 = Information(
        title: 'Database Design',
        content: 'SQLite schema and Flutter integration',
        type: InformationType.bookmark,
      );
      
      final info3 = Information(
        title: 'Testing Strategy',
        content: 'Unit tests and widget tests for mobile apps',
        type: InformationType.task,
      );
      
      await repository.create(info1);
      await repository.create(info2);
      await repository.create(info3);
      
      // Search by title keywords
      final flutterResults = await repository.search('Flutter');
      expect(flutterResults.length, greaterThanOrEqualTo(2));
      expect(flutterResults.any((info) => info.id == info1.id), isTrue);
      expect(flutterResults.any((info) => info.id == info2.id), isTrue);
      
      // Search by content keywords
      final testResults = await repository.search('tests');
      expect(testResults.any((info) => info.id == info3.id), isTrue);
      
      // Search with no results
      final noResults = await repository.search('nonexistent');
      expect(noResults.isEmpty, isTrue);
    });
    
    test('should handle pagination correctly', () async {
      // Create multiple information items
      final infoItems = <Information>[];
      for (int i = 0; i < 25; i++) {
        final info = Information(
          title: 'Info $i',
          content: 'Content for information $i',
          type: InformationType.note,
          importance: i % 10,
        );
        infoItems.add(info);
        await repository.create(info);
      }
      
      // Test pagination
      final page1 = await repository.getAll(limit: 10, offset: 0);
      expect(page1.length, equals(10));
      
      final page2 = await repository.getAll(limit: 10, offset: 10);
      expect(page2.length, equals(10));
      
      final page3 = await repository.getAll(limit: 10, offset: 20);
      expect(page3.length, greaterThanOrEqualTo(5));
      
      // Verify no overlap between pages
      final page1Ids = page1.map((info) => info.id).toSet();
      final page2Ids = page2.map((info) => info.id).toSet();
      expect(page1Ids.intersection(page2Ids).isEmpty, isTrue);
    });
    
    test('should sort information by different criteria', () async {
      // Create information with different timestamps and importance
      await Future.delayed(const Duration(milliseconds: 10));
      final old = Information(
        title: 'Old Info',
        content: 'Old content',
        type: InformationType.note,
        importance: 3,
      );
      await repository.create(old);
      
      await Future.delayed(const Duration(milliseconds: 10));
      final middle = Information(
        title: 'Middle Info',
        content: 'Middle content',
        type: InformationType.note,
        importance: 8,
      );
      await repository.create(middle);
      
      await Future.delayed(const Duration(milliseconds: 10));
      final recent = Information(
        title: 'Recent Info',
        content: 'Recent content',
        type: InformationType.note,
        importance: 5,
      );
      await repository.create(recent);
      
      // Sort by creation date (newest first)
      final byDateDesc = await repository.getAllSorted(
        sortBy: SortField.createdAt,
        sortOrder: SortOrder.descending,
      );
      expect(byDateDesc.first.id, equals(recent.id));
      expect(byDateDesc.last.id, equals(old.id));
      
      // Sort by importance (highest first)
      final byImportance = await repository.getAllSorted(
        sortBy: SortField.importance,
        sortOrder: SortOrder.descending,
      );
      expect(byImportance.first.importance, equals(8));
      expect(byImportance.last.importance, equals(3));
    });
    
    test('should handle database errors gracefully', () async {
      // Test with invalid ID
      final nonExistent = await repository.getById('invalid-uuid');
      expect(nonExistent, isNull);
      
      // Test update with non-existent ID
      final fakeInfo = Information(
        id: 'fake-id',
        title: 'Fake',
        content: 'Fake content',
        type: InformationType.note,
      );
      final updateResult = await repository.update(fakeInfo);
      expect(updateResult, isFalse);
      
      // Test delete with non-existent ID
      final deleteResult = await repository.delete('fake-id');
      expect(deleteResult, isFalse);
    });
    
    test('should mark information as accessed', () async {
      // Create information
      final information = Information(
        title: 'Access Test',
        content: 'Test access tracking',
        type: InformationType.note,
      );
      
      await repository.create(information);
      
      // Verify initially no access time
      final initial = await repository.getById(information.id);
      expect(initial!.accessedAt, isNull);
      
      // Mark as accessed
      final markResult = await repository.markAsAccessed(information.id);
      expect(markResult, isTrue);
      
      // Verify access time is set
      final accessed = await repository.getById(information.id);
      expect(accessed!.accessedAt, isNotNull);
      expect(accessed.accessedAt!.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });
  });
}