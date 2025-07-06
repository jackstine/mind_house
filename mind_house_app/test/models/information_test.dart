import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/information.dart';

void main() {
  group('Information Model Tests', () {
    test('should create Information with generated UUID when id not provided', () {
      // Act
      final information = Information(
        content: 'Test content',
      );

      // Assert
      expect(information.id, isNotNull);
      expect(information.id.length, 36); // UUID v4 format
      expect(information.content, 'Test content');
      expect(information.createdAt, isNotNull);
      expect(information.updatedAt, isNotNull);
    });

    test('should create Information with provided UUID', () {
      // Arrange
      const testId = '123e4567-e89b-12d3-a456-426614174000';
      final testTime = DateTime.now();

      // Act
      final information = Information(
        id: testId,
        content: 'Test content',
        createdAt: testTime,
        updatedAt: testTime,
      );

      // Assert
      expect(information.id, testId);
      expect(information.content, 'Test content');
      expect(information.createdAt, testTime);
      expect(information.updatedAt, testTime);
    });

    test('should convert to Map correctly', () {
      // Arrange
      const testId = '123e4567-e89b-12d3-a456-426614174000';
      final testTime = DateTime.now();
      final information = Information(
        id: testId,
        content: 'Test content',
        createdAt: testTime,
        updatedAt: testTime,
      );

      // Act
      final map = information.toMap();

      // Assert
      expect(map['id'], testId);
      expect(map['content'], 'Test content');
      expect(map['created_at'], testTime.millisecondsSinceEpoch);
      expect(map['updated_at'], testTime.millisecondsSinceEpoch);
    });

    test('should create Information from Map correctly', () {
      // Arrange
      const testId = '123e4567-e89b-12d3-a456-426614174000';
      final testTime = DateTime.now();
      final map = {
        'id': testId,
        'content': 'Test content',
        'created_at': testTime.millisecondsSinceEpoch,
        'updated_at': testTime.millisecondsSinceEpoch,
      };

      // Act
      final information = Information.fromMap(map);

      // Assert
      expect(information.id, testId);
      expect(information.content, 'Test content');
      expect(information.createdAt.millisecondsSinceEpoch, testTime.millisecondsSinceEpoch);
      expect(information.updatedAt.millisecondsSinceEpoch, testTime.millisecondsSinceEpoch);
    });

    test('should create updated copy with copyWith', () {
      // Arrange
      const testId = '123e4567-e89b-12d3-a456-426614174000';
      final testTime = DateTime.now();
      final original = Information(
        id: testId,
        content: 'Original content',
        createdAt: testTime,
        updatedAt: testTime,
      );

      // Act
      final updated = original.copyWith(
        content: 'Updated content',
        updatedAt: testTime.add(Duration(minutes: 1)),
      );

      // Assert
      expect(updated.id, testId);
      expect(updated.content, 'Updated content');
      expect(updated.createdAt, testTime);
      expect(updated.updatedAt, testTime.add(Duration(minutes: 1)));
    });

    test('should validate content is not empty', () {
      // Assert
      expect(
        () => Information(content: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate content is not null', () {
      // Assert - This tests the Dart null safety check
      expect(
        () => Information(content: null as dynamic),
        throwsA(isA<TypeError>()),
      );
    });

    test('should create Information with trimmed content', () {
      // Act
      final information = Information(content: '  Test content  ');

      // Assert
      expect(information.content, 'Test content');
    });

    test('should handle equality correctly', () {
      // Arrange
      const testId = '123e4567-e89b-12d3-a456-426614174000';
      final testTime = DateTime.now();
      final info1 = Information(
        id: testId,
        content: 'Test content',
        createdAt: testTime,
        updatedAt: testTime,
      );
      final info2 = Information(
        id: testId,
        content: 'Test content',
        createdAt: testTime,
        updatedAt: testTime,
      );

      // Assert
      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
    });
  });
}