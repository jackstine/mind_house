import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/tag.dart';

/// Unit tests for Tag model
void main() {
  group('Tag Model Tests', () {
    test('should create Tag with all required fields', () {
      final now = DateTime.now();
      final tag = Tag(
        id: 'test-id',
        name: 'flutter',
        displayName: 'Flutter',
        color: 'FF6B73',
        usageCount: 5,
        createdAt: now,
        lastUsedAt: now,
      );

      expect(tag.id, equals('test-id'));
      expect(tag.name, equals('flutter'));
      expect(tag.displayName, equals('Flutter'));
      expect(tag.color, equals('FF6B73'));
      expect(tag.usageCount, equals(5));
      expect(tag.createdAt, equals(now));
      expect(tag.lastUsedAt, equals(now));
    });

    test('should auto-generate UUID when id is not provided', () {
      final tag = Tag(name: 'flutter');
      
      expect(tag.id, isNotEmpty);
      expect(tag.id.length, equals(36)); // UUID length
      expect(tag.name, equals('flutter'));
    });

    test('should auto-generate timestamps when not provided', () {
      final before = DateTime.now();
      final tag = Tag(name: 'flutter');
      final after = DateTime.now();

      expect(tag.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(tag.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('should default usageCount to 0 when not provided', () {
      final tag = Tag(name: 'flutter');
      expect(tag.usageCount, equals(0));
    });

    test('should use name as displayName when displayName not provided', () {
      final tag = Tag(name: 'flutter');
      expect(tag.displayName, equals('flutter'));
    });

    test('should normalize tag name to lowercase', () {
      final tag = Tag(name: 'FLUTTER');
      expect(tag.name, equals('flutter'));
    });

    test('should preserve displayName case', () {
      final tag = Tag(name: 'FLUTTER', displayName: 'Flutter Framework');
      expect(tag.name, equals('flutter'));
      expect(tag.displayName, equals('Flutter Framework'));
    });

    test('should trim and normalize tag name', () {
      final tag = Tag(name: '  Flutter  ');
      expect(tag.name, equals('flutter'));
    });

    test('should throw exception for empty tag name', () {
      expect(
        () => Tag(name: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw exception for whitespace-only tag name', () {
      expect(
        () => Tag(name: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate color format', () {
      // Valid color
      final validTag = Tag(name: 'flutter', color: 'FF6B73');
      expect(validTag.color, equals('FF6B73'));

      // Invalid color should throw exception
      expect(
        () => Tag(name: 'flutter', color: 'invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle various valid color formats', () {
      final colors = ['FF6B73', '123456', 'ABCDEF', '000000', 'FFFFFF'];
      
      for (final color in colors) {
        final tag = Tag(name: 'test', color: color);
        expect(tag.color, equals(color));
      }
    });

    test('should reject invalid color formats', () {
      final invalidColors = ['GG6B73', '12345', '1234567', 'GGGGGG', ''];
      
      for (final color in invalidColors) {
        expect(
          () => Tag(name: 'test', color: color),
          throwsA(isA<ArgumentError>()),
          reason: 'Color $color should be invalid',
        );
      }
    });

    test('should handle special characters in tag name', () {
      final tag = Tag(name: 'c++');
      expect(tag.name, equals('c++'));
    });

    test('should handle unicode characters in tag name', () {
      final tag = Tag(name: 'тег', displayName: 'Russian Tag');
      expect(tag.name, equals('тег'));
      expect(tag.displayName, equals('Russian Tag'));
    });

    test('should handle numbers in tag name', () {
      final tag = Tag(name: 'flutter3');
      expect(tag.name, equals('flutter3'));
    });

    test('should handle hyphens and underscores in tag name', () {
      final tag = Tag(name: 'flutter-dart_mobile');
      expect(tag.name, equals('flutter-dart_mobile'));
    });

    group('toMap method', () {
      test('should convert Tag to Map correctly', () {
        final now = DateTime.now();
        final tag = Tag(
          id: 'test-id',
          name: 'flutter',
          displayName: 'Flutter',
          color: 'FF6B73',
          usageCount: 5,
          createdAt: now,
          lastUsedAt: now,
        );

        final map = tag.toMap();

        expect(map['id'], equals('test-id'));
        expect(map['name'], equals('flutter'));
        expect(map['display_name'], equals('Flutter'));
        expect(map['color'], equals('FF6B73'));
        expect(map['usage_count'], equals(5));
        expect(map['created_at'], equals(now.millisecondsSinceEpoch));
        expect(map['last_used_at'], equals(now.millisecondsSinceEpoch));
      });

      test('should handle null lastUsedAt in toMap', () {
        final tag = Tag(name: 'flutter', lastUsedAt: null);
        final map = tag.toMap();
        expect(map['last_used_at'], isNull);
      });
    });

    group('fromMap method', () {
      test('should create Tag from Map correctly', () {
        final now = DateTime.now();
        final map = {
          'id': 'test-id',
          'name': 'flutter',
          'display_name': 'Flutter',
          'color': 'FF6B73',
          'usage_count': 5,
          'created_at': now.millisecondsSinceEpoch,
          'last_used_at': now.millisecondsSinceEpoch,
        };

        final tag = Tag.fromMap(map);

        expect(tag.id, equals('test-id'));
        expect(tag.name, equals('flutter'));
        expect(tag.displayName, equals('Flutter'));
        expect(tag.color, equals('FF6B73'));
        expect(tag.usageCount, equals(5));
        expect(tag.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)));
        expect(tag.lastUsedAt, equals(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)));
      });

      test('should handle null lastUsedAt from Map', () {
        final map = {
          'id': 'test-id',
          'name': 'flutter',
          'display_name': 'Flutter',
          'color': 'FF6B73',
          'usage_count': 0,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'last_used_at': null,
        };

        final tag = Tag.fromMap(map);
        expect(tag.lastUsedAt, isNull);
      });

      test('should handle missing optional fields in fromMap', () {
        final map = {
          'id': 'test-id',
          'name': 'flutter',
          'display_name': 'Flutter',
          'color': 'FF6B73',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          // usage_count and last_used_at missing
        };

        final tag = Tag.fromMap(map);
        expect(tag.usageCount, equals(0)); // Default value
        expect(tag.lastUsedAt, isNull); // Default value
      });

      test('should throw exception for missing required fields in fromMap', () {
        final incompleteMap = {
          'id': 'test-id',
          // name missing
          'display_name': 'Flutter',
          'color': 'FF6B73',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        };

        expect(
          () => Tag.fromMap(incompleteMap),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('copyWith method', () {
      test('should create copy with updated fields', () {
        final original = Tag(
          name: 'flutter',
          displayName: 'Flutter',
          color: 'FF6B73',
          usageCount: 5,
        );

        final updated = original.copyWith(
          displayName: 'Flutter Framework',
          usageCount: 10,
        );

        // Original should be unchanged
        expect(original.displayName, equals('Flutter'));
        expect(original.usageCount, equals(5));

        // Updated should have new values
        expect(updated.name, equals('flutter')); // Unchanged
        expect(updated.displayName, equals('Flutter Framework')); // Changed
        expect(updated.usageCount, equals(10)); // Changed
        expect(updated.color, equals('FF6B73')); // Unchanged
      });

      test('should keep original values when not specified in copyWith', () {
        final original = Tag(
          name: 'flutter',
          displayName: 'Flutter',
          color: 'FF6B73',
          usageCount: 5,
        );

        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.displayName, equals(original.displayName));
        expect(copy.color, equals(original.color));
        expect(copy.usageCount, equals(original.usageCount));
        expect(copy.createdAt, equals(original.createdAt));
        expect(copy.lastUsedAt, equals(original.lastUsedAt));
      });

      test('should update lastUsedAt when incrementing usage', () {
        final original = Tag(name: 'flutter', usageCount: 5);
        
        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));
        
        final updated = original.copyWith(usageCount: 6);
        
        expect(updated.lastUsedAt!.isAfter(original.createdAt), isTrue);
        expect(updated.createdAt, equals(original.createdAt)); // Should not change
      });
    });

    group('incrementUsage method', () {
      test('should increment usage count and update lastUsedAt', () {
        final tag = Tag(name: 'flutter', usageCount: 5);
        final before = DateTime.now();
        
        final updatedTag = tag.incrementUsage();
        
        expect(updatedTag.usageCount, equals(6));
        expect(updatedTag.lastUsedAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(updatedTag.name, equals(tag.name)); // Other fields unchanged
        expect(updatedTag.id, equals(tag.id));
      });

      test('should work correctly for first usage', () {
        final tag = Tag(name: 'flutter', usageCount: 0, lastUsedAt: null);
        
        final updatedTag = tag.incrementUsage();
        
        expect(updatedTag.usageCount, equals(1));
        expect(updatedTag.lastUsedAt, isNotNull);
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all fields match', () {
        final now = DateTime.now();
        final tag1 = Tag(
          id: 'test-id',
          name: 'flutter',
          displayName: 'Flutter',
          color: 'FF6B73',
          usageCount: 5,
          createdAt: now,
          lastUsedAt: now,
        );
        final tag2 = Tag(
          id: 'test-id',
          name: 'flutter',
          displayName: 'Flutter',
          color: 'FF6B73',
          usageCount: 5,
          createdAt: now,
          lastUsedAt: now,
        );

        expect(tag1, equals(tag2));
        expect(tag1.hashCode, equals(tag2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final tag1 = Tag(name: 'flutter');
        final tag2 = Tag(name: 'dart');

        expect(tag1, isNot(equals(tag2)));
        expect(tag1.hashCode, isNot(equals(tag2.hashCode)));
      });

      test('should not be equal when usage count differs', () {
        final tag1 = Tag(name: 'flutter', usageCount: 5);
        final tag2 = Tag(name: 'flutter', usageCount: 10);

        expect(tag1, isNot(equals(tag2)));
      });
    });

    group('toString method', () {
      test('should provide meaningful string representation', () {
        final tag = Tag(
          name: 'flutter',
          displayName: 'Flutter',
          usageCount: 5,
        );

        final stringRep = tag.toString();
        
        expect(stringRep, contains('Tag'));
        expect(stringRep, contains('flutter'));
        expect(stringRep, contains('Flutter'));
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null values appropriately', () {
        expect(
          () => Tag(name: null as dynamic),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle very long tag names', () {
        final longName = 'a' * 1000;
        final tag = Tag(name: longName);
        expect(tag.name.length, equals(1000));
      });

      test('should handle negative usage count', () {
        expect(
          () => Tag(name: 'flutter', usageCount: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle very large usage count', () {
        final tag = Tag(name: 'flutter', usageCount: 999999);
        expect(tag.usageCount, equals(999999));
      });

      test('should preserve case in display name but normalize name', () {
        final tag = Tag(
          name: 'Flutter-DART',
          displayName: 'Flutter & Dart Framework',
        );
        expect(tag.name, equals('flutter-dart'));
        expect(tag.displayName, equals('Flutter & Dart Framework'));
      });

      test('should handle tag names with spaces by replacing with hyphens', () {
        final tag = Tag(name: 'flutter dart');
        expect(tag.name, equals('flutter-dart'));
      });

      test('should handle multiple consecutive spaces', () {
        final tag = Tag(name: 'flutter    dart');
        expect(tag.name, equals('flutter-dart'));
      });

      test('should handle mixed separators', () {
        final tag = Tag(name: 'flutter_dart mobile');
        expect(tag.name, equals('flutter_dart-mobile'));
      });
    });

    group('Color validation edge cases', () {
      test('should accept lowercase hex colors', () {
        final tag = Tag(name: 'flutter', color: 'ff6b73');
        expect(tag.color, equals('FF6B73')); // Should be normalized to uppercase
      });

      test('should accept mixed case hex colors', () {
        final tag = Tag(name: 'flutter', color: 'Ff6B73');
        expect(tag.color, equals('FF6B73'));
      });

      test('should reject colors with hash prefix', () {
        expect(
          () => Tag(name: 'flutter', color: '#FF6B73'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject non-hex characters', () {
        expect(
          () => Tag(name: 'flutter', color: 'GG6B73'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}