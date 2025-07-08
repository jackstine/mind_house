import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/utils/tag_normalization.dart';

void main() {
  group('TagNormalization', () {
    group('normalizeName', () {
      test('should convert to lowercase', () {
        expect(TagNormalization.normalizeName('FLUTTER'), equals('flutter'));
        expect(TagNormalization.normalizeName('Flutter'), equals('flutter'));
        expect(TagNormalization.normalizeName('DART'), equals('dart'));
      });

      test('should trim whitespace', () {
        expect(TagNormalization.normalizeName('  flutter  '), equals('flutter'));
        expect(TagNormalization.normalizeName('\tflutter\n'), equals('flutter'));
        expect(TagNormalization.normalizeName(' DART '), equals('dart'));
      });

      test('should replace multiple spaces with single space', () {
        expect(TagNormalization.normalizeName('mobile   app'), equals('mobile app'));
        expect(TagNormalization.normalizeName('web    development'), equals('web development'));
        expect(TagNormalization.normalizeName('flutter     dart'), equals('flutter dart'));
      });

      test('should replace special characters with spaces', () {
        expect(TagNormalization.normalizeName('mobile-app'), equals('mobile app'));
        expect(TagNormalization.normalizeName('web_development'), equals('web development'));
        expect(TagNormalization.normalizeName('flutter/dart'), equals('flutter dart'));
        expect(TagNormalization.normalizeName('ui&ux'), equals('ui ux'));
        expect(TagNormalization.normalizeName('front-end_dev'), equals('front end dev'));
      });

      test('should handle unicode characters correctly', () {
        expect(TagNormalization.normalizeName('café'), equals('café'));
        expect(TagNormalization.normalizeName('naïve'), equals('naïve'));
        expect(TagNormalization.normalizeName('Español'), equals('español'));
      });

      test('should handle numbers and alphanumeric combinations', () {
        expect(TagNormalization.normalizeName('Flutter3'), equals('flutter3'));
        expect(TagNormalization.normalizeName('Web2.0'), equals('web2 0'));
        expect(TagNormalization.normalizeName('iOS15'), equals('ios15'));
        expect(TagNormalization.normalizeName('Android-API-30'), equals('android api 30'));
      });

      test('should remove excessive punctuation', () {
        expect(TagNormalization.normalizeName('flutter!!!'), equals('flutter'));
        expect(TagNormalization.normalizeName('dart???'), equals('dart'));
        expect(TagNormalization.normalizeName('mobile...app'), equals('mobile app'));
        expect(TagNormalization.normalizeName('web---dev'), equals('web dev'));
      });

      test('should handle empty and whitespace-only strings', () {
        expect(TagNormalization.normalizeName(''), equals(''));
        expect(TagNormalization.normalizeName('   '), equals(''));
        expect(TagNormalization.normalizeName('\t\n'), equals(''));
      });

      test('should handle single characters', () {
        expect(TagNormalization.normalizeName('A'), equals('a'));
        expect(TagNormalization.normalizeName('1'), equals('1'));
        expect(TagNormalization.normalizeName('@'), equals(''));
      });

      test('should handle complex mixed cases', () {
        expect(
          TagNormalization.normalizeName('  Mobile-App_Development!!!  '),
          equals('mobile app development'),
        );
        expect(
          TagNormalization.normalizeName('Flutter&Dart/Web-Dev_2024'),
          equals('flutter dart web dev 2024'),
        );
        expect(
          TagNormalization.normalizeName('UI/UX---Design...Mobile'),
          equals('ui ux design mobile'),
        );
      });
    });

    group('normalizeForDisplay', () {
      test('should preserve original casing for display', () {
        expect(TagNormalization.normalizeForDisplay('Flutter'), equals('Flutter'));
        expect(TagNormalization.normalizeForDisplay('DART'), equals('DART'));
        expect(TagNormalization.normalizeForDisplay('Mobile App'), equals('Mobile App'));
      });

      test('should trim whitespace but preserve casing', () {
        expect(TagNormalization.normalizeForDisplay('  Flutter  '), equals('Flutter'));
        expect(TagNormalization.normalizeForDisplay('\tDart\n'), equals('Dart'));
      });

      test('should replace multiple spaces with single space', () {
        expect(TagNormalization.normalizeForDisplay('Mobile   App'), equals('Mobile App'));
        expect(TagNormalization.normalizeForDisplay('Web    Development'), equals('Web Development'));
      });

      test('should replace special characters with spaces', () {
        expect(TagNormalization.normalizeForDisplay('Mobile-App'), equals('Mobile App'));
        expect(TagNormalization.normalizeForDisplay('Web_Development'), equals('Web Development'));
        expect(TagNormalization.normalizeForDisplay('Flutter/Dart'), equals('Flutter Dart'));
      });

      test('should remove excessive punctuation', () {
        expect(TagNormalization.normalizeForDisplay('Flutter!!!'), equals('Flutter'));
        expect(TagNormalization.normalizeForDisplay('Dart???'), equals('Dart'));
        expect(TagNormalization.normalizeForDisplay('Mobile...App'), equals('Mobile App'));
      });
    });

    group('areEquivalent', () {
      test('should return true for equivalent normalized names', () {
        expect(TagNormalization.areEquivalent('Flutter', 'flutter'), isTrue);
        expect(TagNormalization.areEquivalent('Mobile App', 'mobile-app'), isTrue);
        expect(TagNormalization.areEquivalent('Web_Development', 'web development'), isTrue);
        expect(TagNormalization.areEquivalent('  DART  ', 'dart'), isTrue);
      });

      test('should return false for different normalized names', () {
        expect(TagNormalization.areEquivalent('Flutter', 'Dart'), isFalse);
        expect(TagNormalization.areEquivalent('Mobile App', 'Web App'), isFalse);
        expect(TagNormalization.areEquivalent('iOS', 'Android'), isFalse);
      });

      test('should handle edge cases', () {
        expect(TagNormalization.areEquivalent('', ''), isTrue);
        expect(TagNormalization.areEquivalent('', '   '), isTrue);
        expect(TagNormalization.areEquivalent('a', 'A'), isTrue);
        expect(TagNormalization.areEquivalent('a', 'b'), isFalse);
      });
    });

    group('isValid', () {
      test('should return true for valid tag names', () {
        expect(TagNormalization.isValid('flutter'), isTrue);
        expect(TagNormalization.isValid('Mobile App'), isTrue);
        expect(TagNormalization.isValid('Web Development'), isTrue);
        expect(TagNormalization.isValid('iOS15'), isTrue);
        expect(TagNormalization.isValid('café'), isTrue);
      });

      test('should return false for invalid tag names', () {
        expect(TagNormalization.isValid(''), isFalse);
        expect(TagNormalization.isValid('   '), isFalse);
        expect(TagNormalization.isValid('\t\n'), isFalse);
      });

      test('should return false for names that are too long', () {
        final longName = 'a' * 101; // Assuming max length is 100
        expect(TagNormalization.isValid(longName), isFalse);
      });

      test('should return true for names at max length', () {
        final maxLengthName = 'a' * 100; // Assuming max length is 100
        expect(TagNormalization.isValid(maxLengthName), isTrue);
      });
    });

    group('generateSlug', () {
      test('should generate URL-safe slugs', () {
        expect(TagNormalization.generateSlug('Flutter App'), equals('flutter-app'));
        expect(TagNormalization.generateSlug('Web Development'), equals('web-development'));
        expect(TagNormalization.generateSlug('iOS & Android'), equals('ios-android'));
      });

      test('should handle special characters', () {
        expect(TagNormalization.generateSlug('UI/UX Design'), equals('ui-ux-design'));
        expect(TagNormalization.generateSlug('Front-end & Back-end'), equals('front-end-back-end'));
        expect(TagNormalization.generateSlug('Web 2.0'), equals('web-2-0'));
      });

      test('should remove multiple dashes', () {
        expect(TagNormalization.generateSlug('Web---App'), equals('web-app'));
        expect(TagNormalization.generateSlug('Mobile___Development'), equals('mobile-development'));
      });

      test('should trim leading and trailing dashes', () {
        expect(TagNormalization.generateSlug('-Flutter-'), equals('flutter'));
        expect(TagNormalization.generateSlug('__Dart__'), equals('dart'));
      });
    });

    group('extractHashtags', () {
      test('should extract hashtags from text', () {
        final result = TagNormalization.extractHashtags('Learning #flutter and #dart for #mobile development');
        expect(result, containsAll(['flutter', 'dart', 'mobile']));
      });

      test('should normalize extracted hashtags', () {
        final result = TagNormalization.extractHashtags('Working on #Flutter-App and #Web_Development');
        expect(result, containsAll(['flutter app', 'web development']));
      });

      test('should handle duplicate hashtags', () {
        final result = TagNormalization.extractHashtags('#flutter #dart #flutter #mobile');
        expect(result, containsAll(['flutter', 'dart', 'mobile']));
        expect(result.length, equals(3)); // No duplicates
      });

      test('should return empty list when no hashtags found', () {
        final result = TagNormalization.extractHashtags('No hashtags in this text');
        expect(result, isEmpty);
      });
    });
  });
}