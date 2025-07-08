import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/utils/validation_utils.dart';

void main() {
  group('ValidationException', () {
    test('should create exception with message only', () {
      const exception = ValidationException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.field, isNull);
      expect(exception.value, isNull);
      expect(exception.toString(), equals('ValidationException: Test error'));
    });

    test('should create exception with field and value', () {
      const exception = ValidationException(
        'Test error',
        field: 'name',
        value: 'invalid',
      );
      expect(exception.message, equals('Test error'));
      expect(exception.field, equals('name'));
      expect(exception.value, equals('invalid'));
      expect(exception.toString(), 
          equals('ValidationException: Test error (field: name) (value: invalid)'));
    });
  });

  group('ValidationResult', () {
    test('success should create valid result', () {
      final result = ValidationResult.success(sanitizedValue: 'clean data');
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
      expect(result.sanitizedValue, equals('clean data'));
    });

    test('failure should create invalid result', () {
      final result = ValidationResult.failure('Test error');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Test error'));
      expect(result.sanitizedValue, isNull);
    });

    test('throwIfInvalid should not throw for valid result', () {
      final result = ValidationResult.success();
      expect(() => result.throwIfInvalid(), returnsNormally);
    });

    test('throwIfInvalid should throw ValidationException for invalid result', () {
      final result = ValidationResult.failure('Test error');
      expect(
        () => result.throwIfInvalid(field: 'name', value: 'test'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('String Validation', () {
    group('validateRequiredString', () {
      test('should accept valid non-empty string', () {
        final result = ValidationUtils.validateRequiredString('Hello World');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Hello World'));
      });

      test('should trim whitespace', () {
        final result = ValidationUtils.validateRequiredString('  Hello World  ');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Hello World'));
      });

      test('should reject null value', () {
        final result = ValidationUtils.validateRequiredString(null);
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be null'));
      });

      test('should reject empty string', () {
        final result = ValidationUtils.validateRequiredString('');
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be empty'));
      });

      test('should reject whitespace-only string', () {
        final result = ValidationUtils.validateRequiredString('   ');
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be empty'));
      });

      test('should enforce minimum length', () {
        final result = ValidationUtils.validateRequiredString(
          'Hi',
          minLength: 5,
        );
        expect(result.isValid, isFalse);
        expect(result.error, contains('at least 5 characters'));
      });

      test('should enforce maximum length', () {
        final result = ValidationUtils.validateRequiredString(
          'This is a very long string',
          maxLength: 10,
        );
        expect(result.isValid, isFalse);
        expect(result.error, contains('no more than 10 characters'));
      });

      test('should use custom field name in error messages', () {
        final result = ValidationUtils.validateRequiredString(
          null,
          fieldName: 'Title',
        );
        expect(result.error, contains('Title cannot be null'));
      });
    });

    group('validateOptionalString', () {
      test('should accept null value', () {
        final result = ValidationUtils.validateOptionalString(null);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, isNull);
      });

      test('should accept empty string as null', () {
        final result = ValidationUtils.validateOptionalString('');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, isNull);
      });

      test('should validate non-empty string like required string', () {
        final result = ValidationUtils.validateOptionalString(
          'test',
          minLength: 10,
        );
        expect(result.isValid, isFalse);
        expect(result.error, contains('at least 10 characters'));
      });
    });
  });

  group('Tag Validation', () {
    group('validateTagName', () {
      test('should accept valid tag name', () {
        final result = ValidationUtils.validateTagName('Work Projects');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('work projects'));
      });

      test('should accept tag name with hyphens and underscores', () {
        final result = ValidationUtils.validateTagName('work-project_2023');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('work-project_2023'));
      });

      test('should normalize to lowercase', () {
        final result = ValidationUtils.validateTagName('URGENT');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('urgent'));
      });

      test('should reject empty tag name', () {
        final result = ValidationUtils.validateTagName('');
        expect(result.isValid, isFalse);
        expect(result.error, contains('Tag name cannot be empty'));
      });

      test('should reject tag name with special characters', () {
        final result = ValidationUtils.validateTagName('work@home');
        expect(result.isValid, isFalse);
        expect(result.error, contains('can only contain letters, numbers'));
      });

      test('should reject tag name that is too long', () {
        final result = ValidationUtils.validateTagName('a' * 51);
        expect(result.isValid, isFalse);
        expect(result.error, contains('no more than 50 characters'));
      });
    });

    group('validateTagDisplayName', () {
      test('should accept valid display name', () {
        final result = ValidationUtils.validateTagDisplayName('Work Projects');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Work Projects'));
      });

      test('should reject empty display name', () {
        final result = ValidationUtils.validateTagDisplayName('');
        expect(result.isValid, isFalse);
        expect(result.error, contains('Tag display name cannot be empty'));
      });
    });

    group('validateTagDescription', () {
      test('should accept null description', () {
        final result = ValidationUtils.validateTagDescription(null);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, isNull);
      });

      test('should accept valid description', () {
        final result = ValidationUtils.validateTagDescription('Tag for work-related items');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Tag for work-related items'));
      });

      test('should reject description that is too long', () {
        final result = ValidationUtils.validateTagDescription('a' * 501);
        expect(result.isValid, isFalse);
        expect(result.error, contains('no more than 500 characters'));
      });
    });
  });

  group('Information Validation', () {
    group('validateInformationTitle', () {
      test('should accept valid title', () {
        final result = ValidationUtils.validateInformationTitle('Meeting Notes');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Meeting Notes'));
      });

      test('should reject empty title', () {
        final result = ValidationUtils.validateInformationTitle('');
        expect(result.isValid, isFalse);
        expect(result.error, contains('Information title cannot be empty'));
      });

      test('should reject title that is too long', () {
        final result = ValidationUtils.validateInformationTitle('a' * 201);
        expect(result.isValid, isFalse);
        expect(result.error, contains('no more than 200 characters'));
      });
    });

    group('validateInformationContent', () {
      test('should accept valid content', () {
        final result = ValidationUtils.validateInformationContent('This is some content');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('This is some content'));
      });

      test('should reject empty content', () {
        final result = ValidationUtils.validateInformationContent('');
        expect(result.isValid, isFalse);
        expect(result.error, contains('Information content cannot be empty'));
      });

      test('should accept very long content', () {
        final longContent = 'a' * 10000;
        final result = ValidationUtils.validateInformationContent(longContent);
        expect(result.isValid, isTrue);
      });

      test('should reject content that exceeds maximum length', () {
        final result = ValidationUtils.validateInformationContent('a' * 50001);
        expect(result.isValid, isFalse);
        expect(result.error, contains('no more than 50000 characters'));
      });
    });

    group('validateInformationSource', () {
      test('should accept null source', () {
        final result = ValidationUtils.validateInformationSource(null);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, isNull);
      });

      test('should accept valid source', () {
        final result = ValidationUtils.validateInformationSource('Meeting with John');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Meeting with John'));
      });
    });

    group('validateImportance', () {
      test('should accept valid importance levels', () {
        for (int i = 0; i <= 10; i++) {
          final result = ValidationUtils.validateImportance(i);
          expect(result.isValid, isTrue, reason: 'Importance $i should be valid');
          expect(result.sanitizedValue, equals(i));
        }
      });

      test('should default to 0 for null value', () {
        final result = ValidationUtils.validateImportance(null);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(0));
      });

      test('should reject negative importance', () {
        final result = ValidationUtils.validateImportance(-1);
        expect(result.isValid, isFalse);
        expect(result.error, contains('between 0 and 10'));
      });

      test('should reject importance greater than 10', () {
        final result = ValidationUtils.validateImportance(11);
        expect(result.isValid, isFalse);
        expect(result.error, contains('between 0 and 10'));
      });
    });
  });

  group('URL Validation', () {
    test('should accept null URL', () {
      final result = ValidationUtils.validateUrl(null);
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, isNull);
    });

    test('should accept empty URL', () {
      final result = ValidationUtils.validateUrl('');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, isNull);
    });

    test('should accept valid HTTP URL', () {
      final result = ValidationUtils.validateUrl('http://example.com');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('http://example.com'));
    });

    test('should accept valid HTTPS URL', () {
      final result = ValidationUtils.validateUrl('https://example.com/path?param=value');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('https://example.com/path?param=value'));
    });

    test('should trim whitespace from URL', () {
      final result = ValidationUtils.validateUrl('  https://example.com  ');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('https://example.com'));
    });

    test('should reject malformed URL', () {
      final result = ValidationUtils.validateUrl('not-a-url');
      expect(result.isValid, isFalse);
      expect(result.error, contains('Invalid URL format'));
    });

    test('should reject URL without scheme', () {
      final result = ValidationUtils.validateUrl('example.com');
      expect(result.isValid, isFalse);
      expect(result.error, contains('must include a scheme'));
    });

    test('should reject non-HTTP(S) schemes', () {
      final result = ValidationUtils.validateUrl('ftp://example.com');
      expect(result.isValid, isFalse);
      expect(result.error, contains('must use http or https scheme'));
    });

    test('should reject URL without domain', () {
      final result = ValidationUtils.validateUrl('https://');
      expect(result.isValid, isFalse);
      expect(result.error, contains('must include a domain'));
    });
  });

  group('Color Validation', () {
    test('should accept valid 6-digit hex color', () {
      final result = ValidationUtils.validateHexColor('#FF0000');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('#FF0000'));
    });

    test('should accept valid 3-digit hex color and normalize', () {
      final result = ValidationUtils.validateHexColor('#F00');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('#FF0000'));
    });

    test('should normalize to uppercase', () {
      final result = ValidationUtils.validateHexColor('#ff0000');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('#FF0000'));
    });

    test('should reject empty color', () {
      final result = ValidationUtils.validateHexColor('');
      expect(result.isValid, isFalse);
      expect(result.error, contains('Color cannot be empty'));
    });

    test('should reject null color', () {
      final result = ValidationUtils.validateHexColor(null);
      expect(result.isValid, isFalse);
      expect(result.error, contains('Color cannot be empty'));
    });

    test('should reject color without hash', () {
      final result = ValidationUtils.validateHexColor('FF0000');
      expect(result.isValid, isFalse);
      expect(result.error, contains('valid hex color format'));
    });

    test('should reject invalid hex characters', () {
      final result = ValidationUtils.validateHexColor('#GG0000');
      expect(result.isValid, isFalse);
      expect(result.error, contains('valid hex color format'));
    });

    test('should reject wrong length hex color', () {
      final result = ValidationUtils.validateHexColor('#FF00');
      expect(result.isValid, isFalse);
      expect(result.error, contains('valid hex color format'));
    });
  });

  group('UUID Validation', () {
    test('should accept valid UUID', () {
      final result = ValidationUtils.validateUuid('123e4567-e89b-12d3-a456-426614174000');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('123e4567-e89b-12d3-a456-426614174000'));
    });

    test('should normalize to lowercase', () {
      final result = ValidationUtils.validateUuid('123E4567-E89B-12D3-A456-426614174000');
      expect(result.isValid, isTrue);
      expect(result.sanitizedValue, equals('123e4567-e89b-12d3-a456-426614174000'));
    });

    test('should reject empty UUID', () {
      final result = ValidationUtils.validateUuid('');
      expect(result.isValid, isFalse);
      expect(result.error, contains('UUID cannot be empty'));
    });

    test('should reject null UUID', () {
      final result = ValidationUtils.validateUuid(null);
      expect(result.isValid, isFalse);
      expect(result.error, contains('UUID cannot be empty'));
    });

    test('should reject malformed UUID', () {
      final result = ValidationUtils.validateUuid('not-a-uuid');
      expect(result.isValid, isFalse);
      expect(result.error, contains('Invalid UUID format'));
    });

    test('should reject UUID without hyphens', () {
      final result = ValidationUtils.validateUuid('123e4567e89b12d3a456426614174000');
      expect(result.isValid, isFalse);
      expect(result.error, contains('Invalid UUID format'));
    });
  });

  group('Numeric Validation', () {
    group('validateNonNegativeInt', () {
      test('should accept zero', () {
        final result = ValidationUtils.validateNonNegativeInt(0);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(0));
      });

      test('should accept positive integer', () {
        final result = ValidationUtils.validateNonNegativeInt(42);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(42));
      });

      test('should reject negative integer', () {
        final result = ValidationUtils.validateNonNegativeInt(-1);
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be negative'));
      });

      test('should reject null value', () {
        final result = ValidationUtils.validateNonNegativeInt(null);
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be null'));
      });

      test('should use custom field name', () {
        final result = ValidationUtils.validateNonNegativeInt(
          null,
          fieldName: 'count',
        );
        expect(result.error, contains('count cannot be null'));
      });
    });

    group('validatePositiveInt', () {
      test('should accept positive integer', () {
        final result = ValidationUtils.validatePositiveInt(1);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(1));
      });

      test('should reject zero', () {
        final result = ValidationUtils.validatePositiveInt(0);
        expect(result.isValid, isFalse);
        expect(result.error, contains('must be positive'));
      });

      test('should reject negative integer', () {
        final result = ValidationUtils.validatePositiveInt(-1);
        expect(result.isValid, isFalse);
        expect(result.error, contains('must be positive'));
      });
    });

    group('validateIntRange', () {
      test('should accept value within range', () {
        final result = ValidationUtils.validateIntRange(5, min: 0, max: 10);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(5));
      });

      test('should accept minimum value', () {
        final result = ValidationUtils.validateIntRange(0, min: 0, max: 10);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(0));
      });

      test('should accept maximum value', () {
        final result = ValidationUtils.validateIntRange(10, min: 0, max: 10);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(10));
      });

      test('should reject value below minimum', () {
        final result = ValidationUtils.validateIntRange(-1, min: 0, max: 10);
        expect(result.isValid, isFalse);
        expect(result.error, contains('between 0 and 10'));
      });

      test('should reject value above maximum', () {
        final result = ValidationUtils.validateIntRange(11, min: 0, max: 10);
        expect(result.isValid, isFalse);
        expect(result.error, contains('between 0 and 10'));
      });
    });
  });

  group('Date Validation', () {
    group('validatePastOrPresentDate', () {
      test('should accept past date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final result = ValidationUtils.validatePastOrPresentDate(pastDate);
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(pastDate));
      });

      test('should accept present date', () {
        final now = DateTime.now();
        final result = ValidationUtils.validatePastOrPresentDate(now);
        expect(result.isValid, isTrue);
      });

      test('should reject future date', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final result = ValidationUtils.validatePastOrPresentDate(futureDate);
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be in the future'));
      });

      test('should reject null date', () {
        final result = ValidationUtils.validatePastOrPresentDate(null);
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be null'));
      });
    });

    group('validateDateRange', () {
      final baseDate = DateTime(2023, 6, 15);
      final earliestDate = DateTime(2023, 1, 1);
      final latestDate = DateTime(2023, 12, 31);

      test('should accept date within range', () {
        final result = ValidationUtils.validateDateRange(
          baseDate,
          earliest: earliestDate,
          latest: latestDate,
        );
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals(baseDate));
      });

      test('should accept date at earliest boundary', () {
        final result = ValidationUtils.validateDateRange(
          earliestDate,
          earliest: earliestDate,
          latest: latestDate,
        );
        expect(result.isValid, isTrue);
      });

      test('should accept date at latest boundary', () {
        final result = ValidationUtils.validateDateRange(
          latestDate,
          earliest: earliestDate,
          latest: latestDate,
        );
        expect(result.isValid, isTrue);
      });

      test('should reject date before earliest', () {
        final tooEarly = DateTime(2022, 12, 31);
        final result = ValidationUtils.validateDateRange(
          tooEarly,
          earliest: earliestDate,
          latest: latestDate,
        );
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be before'));
      });

      test('should reject date after latest', () {
        final tooLate = DateTime(2024, 1, 1);
        final result = ValidationUtils.validateDateRange(
          tooLate,
          earliest: earliestDate,
          latest: latestDate,
        );
        expect(result.isValid, isFalse);
        expect(result.error, contains('cannot be after'));
      });
    });
  });

  group('Compound Validation Methods', () {
    group('validateTagData', () {
      test('should validate all tag fields successfully', () {
        final results = ValidationUtils.validateTagData(
          name: 'work',
          displayName: 'Work',
          description: 'Work-related items',
          color: '#FF0000',
          usageCount: 5,
        );

        expect(results['name']!.isValid, isTrue);
        expect(results['displayName']!.isValid, isTrue);
        expect(results['description']!.isValid, isTrue);
        expect(results['color']!.isValid, isTrue);
        expect(results['usageCount']!.isValid, isTrue);
      });

      test('should identify validation errors', () {
        final results = ValidationUtils.validateTagData(
          name: '',
          displayName: 'Work',
          description: null,
          color: 'invalid',
          usageCount: -1,
        );

        expect(results['name']!.isValid, isFalse);
        expect(results['displayName']!.isValid, isTrue);
        expect(results['description']!.isValid, isTrue);
        expect(results['color']!.isValid, isFalse);
        expect(results['usageCount']!.isValid, isFalse);
      });
    });

    group('validateInformationData', () {
      test('should validate all information fields successfully', () {
        final results = ValidationUtils.validateInformationData(
          title: 'Meeting Notes',
          content: 'Notes from the meeting',
          source: 'Daily standup',
          url: 'https://example.com',
          importance: 5,
        );

        expect(results['title']!.isValid, isTrue);
        expect(results['content']!.isValid, isTrue);
        expect(results['source']!.isValid, isTrue);
        expect(results['url']!.isValid, isTrue);
        expect(results['importance']!.isValid, isTrue);
      });

      test('should identify validation errors', () {
        final results = ValidationUtils.validateInformationData(
          title: '',
          content: 'Content',
          source: null,
          url: 'invalid-url',
          importance: -1,
        );

        expect(results['title']!.isValid, isFalse);
        expect(results['content']!.isValid, isTrue);
        expect(results['source']!.isValid, isTrue);
        expect(results['url']!.isValid, isFalse);
        expect(results['importance']!.isValid, isFalse);
      });
    });

    group('areAllValid', () {
      test('should return true when all results are valid', () {
        final results = {
          'field1': ValidationResult.success(),
          'field2': ValidationResult.success(),
        };
        expect(ValidationUtils.areAllValid(results), isTrue);
      });

      test('should return false when any result is invalid', () {
        final results = {
          'field1': ValidationResult.success(),
          'field2': ValidationResult.failure('Error'),
        };
        expect(ValidationUtils.areAllValid(results), isFalse);
      });
    });

    group('getAllErrors', () {
      test('should return empty list when all results are valid', () {
        final results = {
          'field1': ValidationResult.success(),
          'field2': ValidationResult.success(),
        };
        final errors = ValidationUtils.getAllErrors(results);
        expect(errors, isEmpty);
      });

      test('should return all error messages with field names', () {
        final results = {
          'field1': ValidationResult.failure('Error 1'),
          'field2': ValidationResult.success(),
          'field3': ValidationResult.failure('Error 3'),
        };
        final errors = ValidationUtils.getAllErrors(results);
        expect(errors, hasLength(2));
        expect(errors, contains('field1: Error 1'));
        expect(errors, contains('field3: Error 3'));
      });
    });

    group('throwIfAnyInvalid', () {
      test('should not throw when all results are valid', () {
        final results = {
          'field1': ValidationResult.success(),
          'field2': ValidationResult.success(),
        };
        expect(
          () => ValidationUtils.throwIfAnyInvalid(results),
          returnsNormally,
        );
      });

      test('should throw ValidationException when any result is invalid', () {
        final results = {
          'field1': ValidationResult.success(),
          'field2': ValidationResult.failure('Error 2'),
        };
        expect(
          () => ValidationUtils.throwIfAnyInvalid(results),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}