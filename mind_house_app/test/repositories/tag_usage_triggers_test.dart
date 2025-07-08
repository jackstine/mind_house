import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/models/information_tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';

void main() {
  late InformationRepository informationRepository;
  late TagRepository tagRepository;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize SQLite FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();
    informationRepository = InformationRepository();
    tagRepository = TagRepository();
  });

  tearDown(() async {
    // Clean up database after each test
    try {
      await databaseHelper.deleteDatabase();
    } catch (e) {
      // Ignore errors during cleanup
    }
  });

  group('Tag Usage Count Update Triggers', () {
    test('should increment tag usage count when tag is assigned to information', () async {
      // Create test data
      final tag = Tag(
        name: 'test-tag',
        displayName: 'Test Tag',
        color: '#FF0000',
        description: 'Test tag',
        usageCount: 0,
      );
      
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      // Save tag and information
      await tagRepository.create(tag);
      await informationRepository.create(information);
      
      // Verify initial usage count
      final initialTag = await tagRepository.getById(tag.id);
      expect(initialTag!.usageCount, equals(0));

      // Assign tag to information (this should increment usage count)
      await informationRepository.addTags(information.id, [tag.id]);
      
      // Verify usage count incremented
      final updatedTag = await tagRepository.getById(tag.id);
      expect(updatedTag!.usageCount, equals(1));
    });

    test('should decrement tag usage count when tag is removed from information', () async {
      // Create test data
      final tag = Tag(
        name: 'test-tag',
        displayName: 'Test Tag',
        color: '#FF0000',
        description: 'Test tag',
        usageCount: 1,
      );
      
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      // Save tag and information
      await tagRepository.create(tag);
      await informationRepository.create(information);
      
      // Assign tag first
      await informationRepository.addTags(information.id, [tag.id]);
      
      // Verify tag is assigned and usage count incremented
      final assignedTag = await tagRepository.getById(tag.id);
      expect(assignedTag!.usageCount, equals(2)); // 1 initial + 1 from assignment

      // Remove tag from information
      await informationRepository.removeTags(information.id, [tag.id]);
      
      // Verify usage count decremented
      final updatedTag = await tagRepository.getById(tag.id);
      expect(updatedTag!.usageCount, equals(1)); // Back to 1
    });

    test('should handle multiple tags assignment correctly', () async {
      // Create test data
      final tag1 = Tag(name: 'tag1', displayName: 'Tag 1', color: '#FF0000', usageCount: 0);
      final tag2 = Tag(name: 'tag2', displayName: 'Tag 2', color: '#00FF00', usageCount: 0);
      final tag3 = Tag(name: 'tag3', displayName: 'Tag 3', color: '#0000FF', usageCount: 0);
      
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      // Save all entities
      await tagRepository.create(tag1);
      await tagRepository.create(tag2);
      await tagRepository.create(tag3);
      await informationRepository.create(information);

      // Assign multiple tags at once
      await informationRepository.addTags(information.id, [tag1.id, tag2.id, tag3.id]);
      
      // Verify all tags have incremented usage counts
      final updatedTag1 = await tagRepository.getById(tag1.id);
      final updatedTag2 = await tagRepository.getById(tag2.id);
      final updatedTag3 = await tagRepository.getById(tag3.id);
      
      expect(updatedTag1!.usageCount, equals(1));
      expect(updatedTag2!.usageCount, equals(1));
      expect(updatedTag3!.usageCount, equals(1));
    });

    test('should handle partial tag removal correctly', () async {
      // Create test data
      final tag1 = Tag(name: 'tag1', displayName: 'Tag 1', color: '#FF0000', usageCount: 0);
      final tag2 = Tag(name: 'tag2', displayName: 'Tag 2', color: '#00FF00', usageCount: 0);
      
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      // Save all entities
      await tagRepository.create(tag1);
      await tagRepository.create(tag2);
      await informationRepository.create(information);

      // Assign both tags
      await informationRepository.addTags(information.id, [tag1.id, tag2.id]);
      
      // Verify both tags have usage count 1
      final assignedTag1 = await tagRepository.getById(tag1.id);
      final assignedTag2 = await tagRepository.getById(tag2.id);
      expect(assignedTag1!.usageCount, equals(1));
      expect(assignedTag2!.usageCount, equals(1));

      // Remove only tag1
      await informationRepository.removeTags(information.id, [tag1.id]);
      
      // Verify only tag1 usage count decremented
      final updatedTag1 = await tagRepository.getById(tag1.id);
      final updatedTag2 = await tagRepository.getById(tag2.id);
      expect(updatedTag1!.usageCount, equals(0));
      expect(updatedTag2!.usageCount, equals(1)); // Should remain unchanged
    });

    test('should update tags correctly by replacing all tags', () async {
      // Create test data
      final tag1 = Tag(name: 'tag1', displayName: 'Tag 1', color: '#FF0000', usageCount: 0);
      final tag2 = Tag(name: 'tag2', displayName: 'Tag 2', color: '#00FF00', usageCount: 0);
      final tag3 = Tag(name: 'tag3', displayName: 'Tag 3', color: '#0000FF', usageCount: 0);
      
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      // Save all entities
      await tagRepository.create(tag1);
      await tagRepository.create(tag2);
      await tagRepository.create(tag3);
      await informationRepository.create(information);

      // Initially assign tag1 and tag2
      await informationRepository.addTags(information.id, [tag1.id, tag2.id]);
      
      // Verify initial state
      expect((await tagRepository.getById(tag1.id))!.usageCount, equals(1));
      expect((await tagRepository.getById(tag2.id))!.usageCount, equals(1));
      expect((await tagRepository.getById(tag3.id))!.usageCount, equals(0));

      // Update tags to tag2 and tag3 (removes tag1, keeps tag2, adds tag3)
      await informationRepository.updateTags(information.id, [tag2.id, tag3.id]);
      
      // Verify final state
      expect((await tagRepository.getById(tag1.id))!.usageCount, equals(0)); // Decremented
      expect((await tagRepository.getById(tag2.id))!.usageCount, equals(1)); // Unchanged
      expect((await tagRepository.getById(tag3.id))!.usageCount, equals(1)); // Incremented
    });

    test('should handle non-existent tag gracefully', () async {
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      await informationRepository.create(information);

      // Try to assign non-existent tag
      expect(
        () async => await informationRepository.addTags(information.id, ['non-existent-id']),
        throwsA(isA<MindHouseDatabaseException>()),
      );
    });

    test('should handle non-existent information gracefully', () async {
      final tag = Tag(name: 'test-tag', displayName: 'Test Tag', color: '#FF0000');
      await tagRepository.create(tag);

      // Try to assign tag to non-existent information
      expect(
        () async => await informationRepository.addTags('non-existent-id', [tag.id]),
        throwsA(isA<MindHouseDatabaseException>()),
      );
    });

    test('should not allow negative usage counts', () async {
      // Create tag with 0 usage count
      final tag = Tag(name: 'test-tag', displayName: 'Test Tag', color: '#FF0000', usageCount: 0);
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      await tagRepository.create(tag);
      await informationRepository.create(information);

      // Try to remove tag that was never assigned (should not go negative)
      await informationRepository.removeTags(information.id, [tag.id]);
      
      // Usage count should remain 0 (not go negative)
      final updatedTag = await tagRepository.getById(tag.id);
      expect(updatedTag!.usageCount, equals(0));
    });

    test('should track tag assignment history in information_tags table', () async {
      final tag = Tag(name: 'test-tag', displayName: 'Test Tag', color: '#FF0000');
      final information = Information(
        title: 'Test Information',
        content: 'Test content',
        type: InformationType.note,
      );

      await tagRepository.create(tag);
      await informationRepository.create(information);

      // Assign tag
      await informationRepository.addTags(information.id, [tag.id]);
      
      // Verify assignment is tracked
      final assignments = await informationRepository.getTagAssignments(information.id);
      expect(assignments.length, equals(1));
      expect(assignments.first.informationId, equals(information.id));
      expect(assignments.first.tagId, equals(tag.id));
      expect(assignments.first.assignedAt, isA<DateTime>());
    });
  });
}