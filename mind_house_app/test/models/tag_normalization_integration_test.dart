import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/tag.dart';

void main() {
  group('Tag Model with Normalization Integration', () {
    group('Constructor with normalization', () {
      test('should normalize name and displayName correctly', () {
        final tag = Tag(name: 'Flutter-App_Development!!!');
        
        expect(tag.name, equals('flutter app development'));
        expect(tag.displayName, equals('Flutter App Development'));
      });

      test('should use provided displayName when given', () {
        final tag = Tag(
          name: 'flutter-app',
          displayName: 'Flutter Application',
        );
        
        expect(tag.name, equals('flutter app'));
        expect(tag.displayName, equals('Flutter Application'));
      });

      test('should throw error for invalid normalized names', () {
        expect(
          () => Tag(name: '   '),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => Tag(name: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle complex normalization cases', () {
        final tag = Tag(name: '  Mobile-App_Development & UI/UX!!!  ');
        
        expect(tag.name, equals('mobile app development ui ux'));
        expect(tag.displayName, equals('Mobile App Development UI UX'));
      });
    });

    group('isEquivalentTo method', () {
      test('should return true for equivalent tag names', () {
        final tag = Tag(name: 'flutter app');
        
        expect(tag.isEquivalentTo('Flutter-App'), isTrue);
        expect(tag.isEquivalentTo('flutter_app'), isTrue);
        expect(tag.isEquivalentTo('FLUTTER APP'), isTrue);
        expect(tag.isEquivalentTo('  flutter   app  '), isTrue);
      });

      test('should return false for different tag names', () {
        final tag = Tag(name: 'flutter app');
        
        expect(tag.isEquivalentTo('dart app'), isFalse);
        expect(tag.isEquivalentTo('flutter web'), isFalse);
        expect(tag.isEquivalentTo('mobile app'), isFalse);
      });
    });

    group('generateSlug method', () {
      test('should generate correct slugs', () {
        final tag1 = Tag(name: 'Flutter App Development');
        expect(tag1.generateSlug(), equals('flutter-app-development'));

        final tag2 = Tag(name: 'UI & UX Design');
        expect(tag2.generateSlug(), equals('ui-ux-design'));

        final tag3 = Tag(name: 'Web Development 2024');
        expect(tag3.generateSlug(), equals('web-development-2024'));
      });
    });

    group('getSuggestions method', () {
      test('should return relevant suggestions', () {
        final tag = Tag(name: 'flutter-app_dev!!!');
        final suggestions = tag.getSuggestions();
        
        expect(suggestions, isNotEmpty);
        expect(suggestions, contains('flutter app dev'));
      });
    });

    group('fromInput factory constructor', () {
      test('should create tag from user input', () {
        final tag = Tag.fromInput('Mobile-App_Development!!!');
        
        expect(tag.name, equals('mobile app development'));
        expect(tag.displayName, equals('Mobile App Development'));
        expect(tag.color, isNotEmpty);
      });

      test('should use provided color', () {
        final tag = Tag.fromInput('flutter', color: '#FF0000');
        
        expect(tag.name, equals('flutter'));
        expect(tag.color, equals('#FF0000'));
      });
    });

    group('fromHashtags factory constructor', () {
      test('should create tags from hashtag text', () {
        const text = 'Learning #flutter and #dart for #mobile-app development';
        final tags = Tag.fromHashtags(text);
        
        expect(tags, hasLength(3));
        expect(tags.map((t) => t.name), containsAll(['flutter', 'dart', 'mobile app']));
      });

      test('should handle duplicate hashtags', () {
        const text = '#flutter #dart #flutter #mobile';
        final tags = Tag.fromHashtags(text);
        
        expect(tags, hasLength(3));
        expect(tags.map((t) => t.name), containsAll(['flutter', 'dart', 'mobile']));
      });

      test('should return empty list when no hashtags found', () {
        const text = 'No hashtags in this text';
        final tags = Tag.fromHashtags(text);
        
        expect(tags, isEmpty);
      });
    });

    group('copyWith with normalization', () {
      test('should normalize updated names', () {
        final originalTag = Tag(name: 'flutter');
        final updatedTag = originalTag.copyWith(
          name: 'Flutter-App_Development!!!',
          displayName: 'Flutter Application Development',
        );
        
        expect(updatedTag.name, equals('flutter app development'));
        expect(updatedTag.displayName, equals('Flutter Application Development'));
        expect(updatedTag.id, equals(originalTag.id)); // ID should remain same
      });
    });

    group('Integration with existing Tag functionality', () {
      test('should work with existing color validation', () {
        expect(
          () => Tag(name: 'flutter', color: 'invalid-color'),
          throwsA(isA<ArgumentError>()),
        );
        
        final tag = Tag(name: 'flutter', color: '#FF0000');
        expect(tag.color, equals('#FF0000'));
      });

      test('should work with usage tracking', () {
        final tag = Tag(name: 'flutter-app', usageCount: 5);
        final incrementedTag = tag.incrementUsage();
        
        expect(incrementedTag.usageCount, equals(6));
        expect(incrementedTag.name, equals('flutter app'));
      });

      test('should work with Material Design colors', () {
        final randomColor = Tag.getRandomColor();
        final tag = Tag(name: 'flutter', color: randomColor);
        
        expect(Tag.materialColors, contains(tag.color));
      });

      test('should maintain JSON serialization compatibility', () {
        final tag = Tag(name: 'Flutter-App_Development');
        final json = tag.toJson();
        final restoredTag = Tag.fromJson(json);
        
        expect(restoredTag.name, equals(tag.name));
        // Note: displayName is not currently stored in database schema,
        // so it will be regenerated from the normalized name
        expect(restoredTag.displayName, equals(tag.name)); // Both will be normalized
        expect(restoredTag.id, equals(tag.id));
      });
    });

    group('Edge cases and error handling', () {
      test('should handle very long names correctly', () {
        final longName = 'a' * 150; // Exceeds max length
        expect(
          () => Tag(name: longName),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle unicode characters', () {
        final tag = Tag(name: 'Café-App_Development');
        expect(tag.name, equals('café app development'));
        expect(tag.displayName, equals('Café App Development'));
      });

      test('should handle special punctuation correctly', () {
        final tag = Tag(name: 'Mobile...App---Development!!!');
        expect(tag.name, equals('mobile app development'));
        expect(tag.displayName, equals('Mobile App Development'));
      });
    });
  });
}