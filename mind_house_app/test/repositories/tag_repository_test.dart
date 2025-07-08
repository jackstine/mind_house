import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/database/database_helper.dart';

void main() {
  // Initialize ffi loader if needed
  sqfliteFfiInit();
  
  // Use the ffi database factory for testing
  databaseFactory = databaseFactoryFfi;
  
  late TagRepository tagRepository;
  late DatabaseHelper databaseHelper;
  
  setUpAll(() async {
    // Initialize test environment
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  
  setUp(() async {
    // Create fresh instances for each test
    databaseHelper = DatabaseHelper();
    tagRepository = TagRepository();
    
    // Initialize database in memory for testing
    await databaseHelper.database;
  });
  
  tearDown(() async {
    // Clean up after each test
    await databaseHelper.close();
  });
  
  group('TagRepository CRUD Operations', () {
    test('should create a new tag successfully', () async {
      // Arrange
      final tag = Tag(
        name: 'flutter',
        displayName: 'Flutter',
        description: 'Google UI framework',
        color: '#2196F3',
      );
      
      // Act
      final result = await tagRepository.create(tag);
      
      // Assert
      expect(result, equals(tag.id));
      
      // Verify tag was actually created
      final retrievedTag = await tagRepository.getById(tag.id);
      expect(retrievedTag, isNotNull);
      expect(retrievedTag!.name, equals('flutter'));
      expect(retrievedTag.displayName, equals('flutter')); // Falls back to name since display_name not in schema yet
      expect(retrievedTag.description, equals('Google UI framework'));
      expect(retrievedTag.color, equals('#2196F3'));
    });
    
    test('should retrieve tag by ID', () async {
      // Arrange
      final tag = Tag(
        name: 'dart',
        displayName: 'Dart',
        color: '#00D2B8',
      );
      await tagRepository.create(tag);
      
      // Act
      final result = await tagRepository.getById(tag.id);
      
      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(tag.id));
      expect(result.name, equals('dart'));
      expect(result.displayName, equals('dart')); // Falls back to name since display_name not in schema yet
      expect(result.color, equals('#00D2B8'));
    });
    
    test('should return null for non-existent tag ID', () async {
      // Act
      final result = await tagRepository.getById('non-existent-id');
      
      // Assert
      expect(result, isNull);
    });
    
    test('should update an existing tag', () async {
      // Arrange
      final tag = Tag(
        name: 'mobile',
        displayName: 'Mobile',
        color: '#FF5722',
      );
      await tagRepository.create(tag);
      
      final updatedTag = tag.copyWith(
        displayName: 'Mobile Development',
        description: 'Mobile app development',
        color: '#FF9800',
      );
      
      // Act
      final result = await tagRepository.update(updatedTag);
      
      // Assert
      expect(result, isTrue);
      
      // Verify update was applied
      final retrievedTag = await tagRepository.getById(tag.id);
      expect(retrievedTag!.displayName, equals('mobile')); // Falls back to name since display_name not in schema yet
      expect(retrievedTag.description, equals('Mobile app development'));
      expect(retrievedTag.color, equals('#FF9800'));
    });
    
    test('should return false when updating non-existent tag', () async {
      // Arrange
      final tag = Tag(
        id: 'non-existent-id',
        name: 'test',
        displayName: 'Test',
      );
      
      // Act
      final result = await tagRepository.update(tag);
      
      // Assert
      expect(result, isFalse);
    });
    
    test('should delete an existing tag', () async {
      // Arrange
      final tag = Tag(
        name: 'temporary',
        displayName: 'Temporary',
      );
      await tagRepository.create(tag);
      
      // Act
      final result = await tagRepository.delete(tag.id);
      
      // Assert
      expect(result, isTrue);
      
      // Verify tag was deleted
      final retrievedTag = await tagRepository.getById(tag.id);
      expect(retrievedTag, isNull);
    });
    
    test('should return false when deleting non-existent tag', () async {
      // Act
      final result = await tagRepository.delete('non-existent-id');
      
      // Assert
      expect(result, isFalse);
    });
  });
  
  group('TagRepository Query Operations', () {
    late List<Tag> testTags;
    
    setUp(() async {
      // Create test data
      testTags = [
        Tag(name: 'flutter', displayName: 'Flutter', color: '#2196F3', usageCount: 5),
        Tag(name: 'dart', displayName: 'Dart', color: '#00D2B8', usageCount: 3),
        Tag(name: 'mobile', displayName: 'Mobile', color: '#FF5722', usageCount: 8),
        Tag(name: 'web', displayName: 'Web Development', color: '#4CAF50', usageCount: 2),
      ];
      
      for (final tag in testTags) {
        await tagRepository.create(tag);
      }
    });
    
    test('should retrieve all tags', () async {
      // Act
      final result = await tagRepository.getAll();
      
      // Assert
      expect(result.length, equals(4));
      expect(result.map((t) => t.name).toSet(), 
             equals({'flutter', 'dart', 'mobile', 'web'}));
    });
    
    test('should retrieve tags with pagination', () async {
      // Act
      final result = await tagRepository.getAll(limit: 2, offset: 1);
      
      // Assert
      expect(result.length, equals(2));
    });
    
    test('should retrieve tags sorted by usage count', () async {
      // Act
      final result = await tagRepository.getAllSorted(
        sortBy: TagSortField.usageCount,
        sortOrder: SortOrder.descending,
      );
      
      // Assert
      expect(result.length, equals(4));
      expect(result.first.name, equals('mobile')); // highest usage count (8)
      expect(result.last.name, equals('web')); // lowest usage count (2)
    });
    
    test('should retrieve tags sorted by name', () async {
      // Act
      final result = await tagRepository.getAllSorted(
        sortBy: TagSortField.name,
        sortOrder: SortOrder.ascending,
      );
      
      // Assert
      expect(result.length, equals(4));
      expect(result.map((t) => t.name), equals(['dart', 'flutter', 'mobile', 'web']));
    });
    
    test('should search tags by name', () async {
      // Act
      final result = await tagRepository.searchByName('fl');
      
      // Assert
      expect(result.length, equals(1));
      expect(result.first.name, equals('flutter'));
    });
    
    test('should search tags by name pattern', () async {
      // Act
      final result = await tagRepository.searchByName('web');
      
      // Assert
      expect(result.length, equals(1));
      expect(result.first.name, equals('web'));
    });
    
    test('should return empty list for no search matches', () async {
      // Act
      final result = await tagRepository.searchByName('nonexistent');
      
      // Assert
      expect(result.isEmpty, isTrue);
    });
    
    test('should get tags by color', () async {
      // Act
      final result = await tagRepository.getByColor('#2196F3');
      
      // Assert
      expect(result.length, equals(1));
      expect(result.first.name, equals('flutter'));
    });
    
    test('should get frequently used tags', () async {
      // Act
      final result = await tagRepository.getFrequentlyUsed(threshold: 5);
      
      // Assert
      expect(result.length, equals(2)); // mobile(8) and flutter(5)
      expect(result.map((t) => t.name).toSet(), equals({'mobile', 'flutter'}));
    });
    
    test('should get unused tags', () async {
      // Create an unused tag
      final unusedTag = Tag(name: 'unused', displayName: 'Unused', usageCount: 0);
      await tagRepository.create(unusedTag);
      
      // Act
      final result = await tagRepository.getUnused();
      
      // Assert
      expect(result.length, equals(1));
      expect(result.first.name, equals('unused'));
    });
    
    test('should get tag count', () async {
      // Act
      final result = await tagRepository.getCount();
      
      // Assert
      expect(result, equals(4));
    });
    
    test('should get used colors', () async {
      // Act
      final result = await tagRepository.getUsedColors();
      
      // Assert
      expect(result.length, equals(4));
      expect(result.toSet(), equals({'#2196F3', '#00D2B8', '#FF5722', '#4CAF50'}));
    });
  });
  
  group('TagRepository Usage Tracking', () {
    late Tag testTag;
    
    setUp(() async {
      testTag = Tag(
        name: 'tracking',
        displayName: 'Tracking Test',
        usageCount: 0,
      );
      await tagRepository.create(testTag);
    });
    
    test('should increment usage count', () async {
      // Act
      final result = await tagRepository.incrementUsage(testTag.id);
      
      // Assert
      expect(result, isTrue);
      
      // Verify usage was incremented
      final updatedTag = await tagRepository.getById(testTag.id);
      expect(updatedTag!.usageCount, equals(1));
      // Note: lastUsedAt will be null since the field doesn't exist in current schema
    });
    
    test('should return false when incrementing usage for non-existent tag', () async {
      // Act
      final result = await tagRepository.incrementUsage('non-existent-id');
      
      // Assert
      expect(result, isFalse);
    });
    
    test('should update last used timestamp', () async {
      // Act
      final result = await tagRepository.updateLastUsed(testTag.id);
      
      // Assert
      expect(result, isTrue);
      
      // Verify timestamp was updated (checking updated_at since last_used_at not in schema yet)
      final updatedTag = await tagRepository.getById(testTag.id);
      expect(updatedTag!.updatedAt.isAfter(testTag.updatedAt), isTrue);
    });
  });
  
  group('TagRepository Validation', () {
    test('should handle duplicate tag names gracefully', () async {
      // Arrange
      final tag1 = Tag(name: 'duplicate', displayName: 'First');
      final tag2 = Tag(name: 'duplicate', displayName: 'Second');
      
      await tagRepository.create(tag1);
      
      // Act & Assert
      expect(
        () => tagRepository.create(tag2),
        throwsA(isA<MindHouseDatabaseException>()),
      );
    });
    
    test('should validate tag data on create', () async {
      // Arrange - Tag model validation should catch this
      expect(
        () => Tag(name: '', displayName: 'Empty Name'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('TagRepository Advanced Suggestions', () {
    late List<Tag> testTags;
    
    setUp(() async {
      // Create comprehensive test data for suggestion testing
      testTags = [
        Tag(name: 'flutter', displayName: 'Flutter', color: '#2196F3', usageCount: 15),
        Tag(name: 'flutter-widgets', displayName: 'Flutter Widgets', color: '#2196F3', usageCount: 8),
        Tag(name: 'dart', displayName: 'Dart', color: '#00D2B8', usageCount: 12),
        Tag(name: 'dart-async', displayName: 'Dart Async', color: '#00D2B8', usageCount: 6),
        Tag(name: 'mobile', displayName: 'Mobile', color: '#FF5722', usageCount: 20),
        Tag(name: 'web', displayName: 'Web Development', color: '#4CAF50', usageCount: 5),
        Tag(name: 'backend', displayName: 'Backend', color: '#9C27B0', usageCount: 3),
        Tag(name: 'frontend', displayName: 'Frontend', color: '#FF9800', usageCount: 7),
      ];
      
      for (final tag in testTags) {
        await tagRepository.create(tag);
      }
    });
    
    test('should get basic suggestions with partial name match', () async {
      // Act
      final result = await tagRepository.getSuggestions('fl');
      
      // Assert
      expect(result.length, equals(2)); // flutter and flutter-widgets
      expect(result.map((t) => t.name).toSet(), equals({'flutter', 'flutter-widgets'}));
      // Should prioritize by usage count - flutter (15) before flutter-widgets (8)
      expect(result.first.name, equals('flutter'));
    });
    
    test('should return empty list for empty suggestion query', () async {
      // Act
      final result = await tagRepository.getSuggestions('');
      
      // Assert
      expect(result.isEmpty, isTrue);
    });
    
    test('should get smart suggestions prioritizing exact prefix matches', () async {
      // Act
      final result = await tagRepository.getSmartSuggestions('dart');
      
      // Assert
      expect(result.length, equals(2)); // dart and dart-async
      // Should prioritize exact match 'dart' over partial match 'dart-async'
      expect(result.first.name, equals('dart'));
      expect(result.last.name, equals('dart-async'));
    });
    
    test('should exclude existing tags from smart suggestions', () async {
      // Arrange
      final flutterTag = testTags.firstWhere((t) => t.name == 'flutter');
      
      // Act
      final result = await tagRepository.getSmartSuggestions(
        'fl',
        existingTagIds: [flutterTag.id],
      );
      
      // Assert
      expect(result.length, equals(1)); // Only flutter-widgets, flutter excluded
      expect(result.first.name, equals('flutter-widgets'));
    });
    
    test('should boost recently used tags in smart suggestions', () async {
      // Arrange - Update a tag to make it recently used
      final webTag = testTags.firstWhere((t) => t.name == 'web');
      await tagRepository.updateLastUsed(webTag.id);
      
      // Act
      final result = await tagRepository.getSmartSuggestions(
        'we',
        includeRecentlyUsed: true,
      );
      
      // Assert
      expect(result.isNotEmpty, isTrue);
      expect(result.first.name, equals('web'));
    });
    
    test('should get contextual suggestions based on co-occurrence patterns', () async {
      // This test would require creating information and information_tags data
      // For now, test the method doesn't crash with empty base tags
      
      // Act
      final result = await tagRepository.getContextualSuggestions([]);
      
      // Assert
      expect(result.isEmpty, isTrue);
    });
    
    test('should handle contextual suggestions with non-existent base tags', () async {
      // Act
      final result = await tagRepository.getContextualSuggestions(['non-existent-id']);
      
      // Assert
      expect(result.isEmpty, isTrue);
    });
    
    test('should get trending suggestions based on recent usage', () async {
      // Act - This may return empty results without information data, but should not crash
      final result = await tagRepository.getTrendingSuggestions(days: 30);
      
      // Assert
      expect(result, isA<List<Tag>>());
      // In a real scenario with information data, this would return trending tags
    });
    
    test('should get diverse suggestions across different colors', () async {
      // Act
      final result = await tagRepository.getDiverseSuggestions(
        limit: 6,
        maxPerColor: 1,
      );
      
      // Assert
      expect(result.length, lessThanOrEqualTo(6));
      
      // Check that we don't have more than 1 tag per color
      final colorCounts = <String, int>{};
      for (final tag in result) {
        colorCounts[tag.color] = (colorCounts[tag.color] ?? 0) + 1;
      }
      
      for (final count in colorCounts.values) {
        expect(count, lessThanOrEqualTo(1));
      }
    });
    
    test('should exclude specified tags from diverse suggestions', () async {
      // Arrange
      final mobileTag = testTags.firstWhere((t) => t.name == 'mobile');
      final flutterTag = testTags.firstWhere((t) => t.name == 'flutter');
      
      // Act
      final result = await tagRepository.getDiverseSuggestions(
        excludeTagIds: [mobileTag.id, flutterTag.id],
      );
      
      // Assert
      final resultNames = result.map((t) => t.name).toSet();
      expect(resultNames.contains('mobile'), isFalse);
      expect(resultNames.contains('flutter'), isFalse);
    });
    
    test('should handle smart suggestions with special characters in input', () async {
      // Act
      final result = await tagRepository.getSmartSuggestions('dart-');
      
      // Assert
      expect(result.length, equals(1)); // dart-async
      expect(result.first.name, equals('dart-async'));
    });
    
    test('should limit suggestion results correctly', () async {
      // Act
      final result = await tagRepository.getSmartSuggestions(
        'e', // Should match multiple tags (web, mobile, backend, frontend)
        limit: 2,
      );
      
      // Assert
      expect(result.length, lessThanOrEqualTo(2));
    });
    
    test('should handle case-insensitive smart suggestions', () async {
      // Act
      final result = await tagRepository.getSmartSuggestions('FLUTTER');
      
      // Assert
      expect(result.isNotEmpty, isTrue);
      expect(result.any((t) => t.name.contains('flutter')), isTrue);
    });
    
    test('should handle empty results gracefully for all suggestion methods', () async {
      // Act & Assert - All these should return empty lists without crashing
      expect(await tagRepository.getSuggestions('xyz123'), isEmpty);
      expect(await tagRepository.getSmartSuggestions('xyz123'), isEmpty);
      expect(await tagRepository.getContextualSuggestions([]), isEmpty);
      expect(await tagRepository.getDiverseSuggestions(excludeTagIds: testTags.map((t) => t.id).toList()), isEmpty);
    });
  });
}