import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/information.dart';

/// Unit tests for Information model
void main() {
  group('Information Model Tests', () {
    test('should create Information with all required fields', () {
      final now = DateTime.now();
      final information = Information(
        id: 'test-id',
        content: 'Test content',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      expect(information.id, equals('test-id'));
      expect(information.content, equals('Test content'));
      expect(information.createdAt, equals(now));
      expect(information.updatedAt, equals(now));
      expect(information.isDeleted, equals(false));
    });

    test('should auto-generate UUID when id is not provided', () {
      final information = Information(content: 'Test content');
      
      expect(information.id, isNotEmpty);
      expect(information.id.length, equals(36)); // UUID length
      expect(information.content, equals('Test content'));
    });

    test('should auto-generate timestamps when not provided', () {
      final before = DateTime.now();
      final information = Information(content: 'Test content');
      final after = DateTime.now();

      expect(information.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(information.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(information.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(information.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('should default isDeleted to false when not provided', () {
      final information = Information(content: 'Test content');
      expect(information.isDeleted, equals(false));
    });

    test('should validate and trim content', () {
      final information = Information(content: '  Test content with spaces  ');
      expect(information.content, equals('Test content with spaces'));
    });

    test('should throw exception for empty content', () {
      expect(
        () => Information(content: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw exception for whitespace-only content', () {
      expect(
        () => Information(content: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle very long content', () {
      final longContent = 'A' * 10000;
      final information = Information(content: longContent);
      expect(information.content, equals(longContent));
    });

    test('should handle special characters in content', () {
      const specialContent = 'Content with special chars: @#\$%^&*()_+-=[]{}|;:",.<>?';
      final information = Information(content: specialContent);
      expect(information.content, equals(specialContent));
    });

    test('should handle unicode and emoji content', () {
      const emojiContent = 'Unicode content 🎉💻📱🚀 with emojis';
      final information = Information(content: emojiContent);
      expect(information.content, equals(emojiContent));
    });

    test('should handle multiline content', () {
      const multilineContent = 'Line 1\nLine 2\nLine 3';
      final information = Information(content: multilineContent);
      expect(information.content, equals(multilineContent));
    });

    group('toMap method', () {
      test('should convert Information to Map correctly', () {
        final now = DateTime.now();
        final information = Information(
          id: 'test-id',
          content: 'Test content',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );

        final map = information.toMap();

        expect(map['id'], equals('test-id'));
        expect(map['content'], equals('Test content'));
        expect(map['created_at'], equals(now.millisecondsSinceEpoch));
        expect(map['updated_at'], equals(now.millisecondsSinceEpoch));
        expect(map['is_deleted'], equals(0)); // SQLite boolean as int
      });

      test('should handle deleted state in toMap', () {
        final information = Information(
          content: 'Test content',
          isDeleted: true,
        );

        final map = information.toMap();
        expect(map['is_deleted'], equals(1)); // SQLite boolean as int
      });
    });

    group('fromMap method', () {
      test('should create Information from Map correctly', () {
        final now = DateTime.now();
        final map = {
          'id': 'test-id',
          'content': 'Test content',
          'created_at': now.millisecondsSinceEpoch,
          'updated_at': now.millisecondsSinceEpoch,
          'is_deleted': 0,
        };

        final information = Information.fromMap(map);

        expect(information.id, equals('test-id'));
        expect(information.content, equals('Test content'));
        expect(information.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)));
        expect(information.updatedAt, equals(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)));
        expect(information.isDeleted, equals(false));
      });

      test('should handle deleted state from Map', () {
        final map = {
          'id': 'test-id',
          'content': 'Test content',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'is_deleted': 1,
        };

        final information = Information.fromMap(map);
        expect(information.isDeleted, equals(true));
      });

      test('should handle missing optional fields in fromMap', () {
        final map = {
          'id': 'test-id',
          'content': 'Test content',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          // is_deleted missing - should default to false
        };

        final information = Information.fromMap(map);
        expect(information.isDeleted, equals(false));
      });

      test('should throw exception for missing required fields in fromMap', () {
        final incompleteMap = {
          'id': 'test-id',
          // content missing
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };

        expect(
          () => Information.fromMap(incompleteMap),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('copyWith method', () {
      test('should create copy with updated fields', () {
        final original = Information(
          id: 'original-id',
          content: 'Original content',
          isDeleted: false,
        );

        final updated = original.copyWith(
          content: 'Updated content',
          isDeleted: true,
        );

        // Original should be unchanged
        expect(original.content, equals('Original content'));
        expect(original.isDeleted, equals(false));

        // Updated should have new values
        expect(updated.id, equals('original-id')); // Unchanged
        expect(updated.content, equals('Updated content')); // Changed
        expect(updated.isDeleted, equals(true)); // Changed
      });

      test('should keep original values when not specified in copyWith', () {
        final original = Information(
          content: 'Original content',
          isDeleted: false,
        );

        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.content, equals(original.content));
        expect(copy.createdAt, equals(original.createdAt));
        expect(copy.updatedAt, equals(original.updatedAt));
        expect(copy.isDeleted, equals(original.isDeleted));
      });

      test('should update timestamp when using copyWith', () {
        final original = Information(content: 'Original content');
        
        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));
        
        final updated = original.copyWith(content: 'Updated content');
        
        expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
        expect(updated.createdAt, equals(original.createdAt)); // Should not change
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all fields match', () {
        final now = DateTime.now();
        final info1 = Information(
          id: 'test-id',
          content: 'Test content',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );
        final info2 = Information(
          id: 'test-id',
          content: 'Test content',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );

        expect(info1, equals(info2));
        expect(info1.hashCode, equals(info2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final info1 = Information(content: 'Content 1');
        final info2 = Information(content: 'Content 2');

        expect(info1, isNot(equals(info2)));
        expect(info1.hashCode, isNot(equals(info2.hashCode)));
      });

      test('should not be equal when deleted state differs', () {
        final info1 = Information(content: 'Test content', isDeleted: false);
        final info2 = Information(content: 'Test content', isDeleted: true);

        expect(info1, isNot(equals(info2)));
      });
    });

    group('toString method', () {
      test('should provide meaningful string representation', () {
        final information = Information(
          id: 'test-id',
          content: 'Test content',
          isDeleted: false,
        );

        final stringRep = information.toString();
        
        expect(stringRep, contains('Information'));
        expect(stringRep, contains('test-id'));
        expect(stringRep, contains('Test content'));
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null values appropriately', () {
        expect(
          () => Information(content: null as dynamic),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle extremely long content', () {
        final veryLongContent = 'A' * 100000; // 100k characters
        final information = Information(content: veryLongContent);
        expect(information.content.length, equals(100000));
      });

      test('should handle content with only newlines', () {
        expect(
          () => Information(content: '\n\n\n'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle content with mixed whitespace', () {
        expect(
          () => Information(content: ' \t\n\r '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should preserve meaningful whitespace in content', () {
        const contentWithSpaces = 'Word1 word2  word3';
        final information = Information(content: contentWithSpaces);
        expect(information.content, equals('Word1 word2  word3'));
      });
    });
  });
}