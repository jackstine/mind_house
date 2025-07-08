import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/tag.dart';

void main() {
  group('Tag Model Tests', () {
    late String testId;
    late String testName;
    late String testDisplayName;
    late String testDescription;
    late String testColor;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testLastUsedAt;

    setUp(() {
      testId = 'test-tag-123';
      testName = 'work';
      testDisplayName = 'Work';
      testDescription = 'Work-related information';
      testColor = '#2196F3';
      testCreatedAt = DateTime(2024, 1, 1, 10, 0, 0);
      testUpdatedAt = DateTime(2024, 1, 1, 10, 0, 0);
      testLastUsedAt = DateTime(2024, 1, 1, 11, 0, 0);
    });

    group('Constructor Tests', () {
      test('should create Tag with all required fields', () {
        final tag = Tag(
          name: testName,
          displayName: testDisplayName,
        );

        expect(tag.name, equals(testName));
        expect(tag.displayName, equals(testDisplayName));
        expect(tag.id, isNotEmpty);
        expect(tag.color, equals(Tag.defaultColor));
        expect(tag.usageCount, equals(0));
        expect(tag.description, isNull);
        expect(tag.createdAt, isA<DateTime>());
        expect(tag.updatedAt, isA<DateTime>());
        expect(tag.lastUsedAt, isNull);
      });

      test('should create Tag with all optional fields', () {
        final tag = Tag(
          id: testId,
          name: testName,
          displayName: testDisplayName,
          description: testDescription,
          color: testColor,
          usageCount: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          lastUsedAt: testLastUsedAt,
        );

        expect(tag.id, equals(testId));
        expect(tag.name, equals(testName));
        expect(tag.displayName, equals(testDisplayName));
        expect(tag.description, equals(testDescription));
        expect(tag.color, equals(testColor));
        expect(tag.usageCount, equals(5));
        expect(tag.createdAt, equals(testCreatedAt));
        expect(tag.updatedAt, equals(testUpdatedAt));
        expect(tag.lastUsedAt, equals(testLastUsedAt));
      });

      test('should generate UUID when id is not provided', () {
        final tag1 = Tag(name: 'tag1', displayName: 'Tag 1');
        final tag2 = Tag(name: 'tag2', displayName: 'Tag 2');

        expect(tag1.id, isNotEmpty);
        expect(tag2.id, isNotEmpty);
        expect(tag1.id, isNot(equals(tag2.id)));
      });

      test('should normalize tag name to lowercase', () {
        final tag = Tag(name: 'WORK', displayName: 'Work');
        expect(tag.name, equals('work'));
      });

      test('should set current time for timestamps when not provided', () {
        final beforeCreation = DateTime.now().subtract(Duration(seconds: 1));
        final tag = Tag(name: testName, displayName: testDisplayName);
        final afterCreation = DateTime.now().add(Duration(seconds: 1));

        expect(tag.createdAt.isAfter(beforeCreation), isTrue);
        expect(tag.createdAt.isBefore(afterCreation), isTrue);
        expect(tag.updatedAt.isAfter(beforeCreation), isTrue);
        expect(tag.updatedAt.isBefore(afterCreation), isTrue);
      });
    });

    group('Validation Tests', () {
      test('should throw ArgumentError for empty name', () {
        expect(
          () => Tag(name: '', displayName: testDisplayName),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for whitespace-only name', () {
        expect(
          () => Tag(name: '   ', displayName: testDisplayName),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for empty displayName', () {
        expect(
          () => Tag(name: testName, displayName: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for whitespace-only displayName', () {
        expect(
          () => Tag(name: testName, displayName: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for negative usageCount', () {
        expect(
          () => Tag(name: testName, displayName: testDisplayName, usageCount: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid color format', () {
        expect(
          () => Tag(name: testName, displayName: testDisplayName, color: 'invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept valid hex color formats', () {
        final validColors = ['#FF0000', '#ff0000', '#F00', '#f00'];
        
        for (final color in validColors) {
          expect(
            () => Tag(name: testName, displayName: testDisplayName, color: color),
            returnsNormally,
          );
        }
      });
    });

    group('Factory Constructor Tests', () {
      test('should create Tag from JSON correctly', () {
        final json = {
          'id': testId,
          'name': testName,
          'display_name': testDisplayName,
          'description': testDescription,
          'color': testColor,
          'usage_count': 5,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': testUpdatedAt.toIso8601String(),
          'last_used_at': testLastUsedAt.toIso8601String(),
        };

        final tag = Tag.fromJson(json);

        expect(tag.id, equals(testId));
        expect(tag.name, equals(testName));
        expect(tag.displayName, equals(testDisplayName));
        expect(tag.description, equals(testDescription));
        expect(tag.color, equals(testColor));
        expect(tag.usageCount, equals(5));
        expect(tag.createdAt, equals(testCreatedAt));
        expect(tag.updatedAt, equals(testUpdatedAt));
        expect(tag.lastUsedAt, equals(testLastUsedAt));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'id': testId,
          'name': testName,
          'display_name': testDisplayName,
          'color': testColor,
          'usage_count': 0,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': testUpdatedAt.toIso8601String(),
        };

        final tag = Tag.fromJson(json);

        expect(tag.description, isNull);
        expect(tag.lastUsedAt, isNull);
      });

      test('should apply defaults when fields are missing from JSON', () {
        final json = {
          'id': testId,
          'name': testName,
          'display_name': testDisplayName,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': testUpdatedAt.toIso8601String(),
        };

        final tag = Tag.fromJson(json);

        expect(tag.color, equals(Tag.defaultColor));
        expect(tag.usageCount, equals(0));
      });
    });

    group('Serialization Tests', () {
      test('should convert Tag to JSON correctly', () {
        final tag = Tag(
          id: testId,
          name: testName,
          displayName: testDisplayName,
          description: testDescription,
          color: testColor,
          usageCount: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          lastUsedAt: testLastUsedAt,
        );

        final json = tag.toJson();

        expect(json['id'], equals(testId));
        expect(json['name'], equals(testName));
        expect(json['display_name'], equals(testDisplayName));
        expect(json['description'], equals(testDescription));
        expect(json['color'], equals(testColor));
        expect(json['usage_count'], equals(5));
        expect(json['created_at'], equals(testCreatedAt.toIso8601String()));
        expect(json['updated_at'], equals(testUpdatedAt.toIso8601String()));
        expect(json['last_used_at'], equals(testLastUsedAt.toIso8601String()));
      });

      test('should handle null fields in serialization', () {
        final tag = Tag(
          id: testId,
          name: testName,
          displayName: testDisplayName,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final json = tag.toJson();

        expect(json['description'], isNull);
        expect(json['last_used_at'], isNull);
      });
    });

    group('CopyWith Tests', () {
      late Tag originalTag;

      setUp(() {
        originalTag = Tag(
          id: testId,
          name: testName,
          displayName: testDisplayName,
          description: testDescription,
          color: testColor,
          usageCount: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          lastUsedAt: testLastUsedAt,
        );
      });

      test('should create copy with updated fields', () {
        final updatedTag = originalTag.copyWith(
          displayName: 'Updated Work',
          usageCount: 10,
        );

        expect(updatedTag.id, equals(originalTag.id)); // ID should not change
        expect(updatedTag.name, equals(originalTag.name));
        expect(updatedTag.displayName, equals('Updated Work'));
        expect(updatedTag.description, equals(originalTag.description));
        expect(updatedTag.color, equals(originalTag.color));
        expect(updatedTag.usageCount, equals(10));
        expect(updatedTag.createdAt, equals(originalTag.createdAt)); // createdAt should not change
        expect(updatedTag.updatedAt.isAfter(originalTag.updatedAt), isTrue);
        expect(updatedTag.lastUsedAt, equals(originalTag.lastUsedAt));
      });

      test('should preserve original values when no updates provided', () {
        final copiedTag = originalTag.copyWith();

        expect(copiedTag.id, equals(originalTag.id));
        expect(copiedTag.name, equals(originalTag.name));
        expect(copiedTag.displayName, equals(originalTag.displayName));
        expect(copiedTag.description, equals(originalTag.description));
        expect(copiedTag.color, equals(originalTag.color));
        expect(copiedTag.usageCount, equals(originalTag.usageCount));
        expect(copiedTag.createdAt, equals(originalTag.createdAt));
        expect(copiedTag.updatedAt.isAfter(originalTag.updatedAt), isTrue);
        expect(copiedTag.lastUsedAt, equals(originalTag.lastUsedAt));
      });

      test('should allow explicit updatedAt override', () {
        final specificTime = DateTime(2024, 6, 1, 15, 30, 0);
        final updatedTag = originalTag.copyWith(updatedAt: specificTime);

        expect(updatedTag.updatedAt, equals(specificTime));
      });
    });

    group('Usage Tracking Tests', () {
      test('should increment usage count and update lastUsedAt', () {
        final tag = Tag(
          name: testName,
          displayName: testDisplayName,
          usageCount: 5,
        );

        final beforeUsage = DateTime.now().subtract(Duration(seconds: 1));
        final usedTag = tag.incrementUsage();
        final afterUsage = DateTime.now().add(Duration(seconds: 1));

        expect(usedTag.usageCount, equals(6));
        expect(usedTag.lastUsedAt, isNotNull);
        expect(usedTag.lastUsedAt!.isAfter(beforeUsage), isTrue);
        expect(usedTag.lastUsedAt!.isBefore(afterUsage), isTrue);
        expect(usedTag.updatedAt.isAfter(tag.updatedAt), isTrue);
      });

      test('should handle incrementing from zero usage', () {
        final tag = Tag(
          name: testName,
          displayName: testDisplayName,
          usageCount: 0,
        );

        final usedTag = tag.incrementUsage();

        expect(usedTag.usageCount, equals(1));
        expect(usedTag.lastUsedAt, isNotNull);
      });
    });

    group('Predefined Colors Tests', () {
      test('should have predefined material colors', () {
        expect(Tag.materialColors, isNotEmpty);
        expect(Tag.materialColors.length, greaterThan(10));
        
        // Test a few known Material Design colors
        expect(Tag.materialColors, contains('#F44336')); // Red
        expect(Tag.materialColors, contains('#2196F3')); // Blue
        expect(Tag.materialColors, contains('#4CAF50')); // Green
      });

      test('should get random color from material colors', () {
        final color1 = Tag.getRandomColor();
        final color2 = Tag.getRandomColor();

        expect(Tag.materialColors, contains(color1));
        expect(Tag.materialColors, contains(color2));
        // Note: colors might be the same due to randomness, so we don't test inequality
      });

      test('should have valid default color', () {
        expect(Tag.materialColors, contains(Tag.defaultColor));
      });
    });

    group('Equality and HashCode Tests', () {
      test('should be equal when IDs are the same', () {
        final tag1 = Tag(
          id: testId,
          name: 'work',
          displayName: 'Work',
        );
        final tag2 = Tag(
          id: testId,
          name: 'personal',
          displayName: 'Personal',
        );

        expect(tag1, equals(tag2));
        expect(tag1.hashCode, equals(tag2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        final tag1 = Tag(name: 'work', displayName: 'Work');
        final tag2 = Tag(name: 'work', displayName: 'Work');

        expect(tag1, isNot(equals(tag2)));
        expect(tag1.hashCode, isNot(equals(tag2.hashCode)));
      });
    });

    group('String Representation Tests', () {
      test('should provide meaningful toString', () {
        final tag = Tag(
          id: testId,
          name: testName,
          displayName: testDisplayName,
          usageCount: 5,
        );

        final str = tag.toString();

        expect(str, contains(testId));
        expect(str, contains(testName));
        expect(str, contains(testDisplayName));
        expect(str, contains('5'));
      });
    });
  });
}