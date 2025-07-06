import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/tag.dart';

void main() {
  group('Tag Model Tests', () {
    test('should create Tag with auto-generated id', () {
      // Act
      final tag = Tag(name: 'work');

      // Assert
      expect(tag.id, isNull); // Auto-increment handled by database
      expect(tag.name, 'work');
      expect(tag.color, isNull);
      expect(tag.usageCount, 0);
      expect(tag.createdAt, isNotNull);
    });

    test('should create Tag with all parameters', () {
      // Arrange
      final testTime = DateTime.now();

      // Act
      final tag = Tag(
        id: 1,
        name: 'project',
        color: '#FF5722',
        usageCount: 5,
        createdAt: testTime,
      );

      // Assert
      expect(tag.id, 1);
      expect(tag.name, 'project');
      expect(tag.color, '#FF5722');
      expect(tag.usageCount, 5);
      expect(tag.createdAt, testTime);
    });

    test('should convert to Map correctly', () {
      // Arrange
      final testTime = DateTime.now();
      final tag = Tag(
        id: 1,
        name: 'personal',
        color: '#2196F3',
        usageCount: 3,
        createdAt: testTime,
      );

      // Act
      final map = tag.toMap();

      // Assert
      expect(map['id'], 1);
      expect(map['name'], 'personal');
      expect(map['color'], '#2196F3');
      expect(map['usage_count'], 3);
      expect(map['created_at'], testTime.millisecondsSinceEpoch);
    });

    test('should create Tag from Map correctly', () {
      // Arrange
      final testTime = DateTime.now();
      final map = {
        'id': 1,
        'name': 'urgent',
        'color': '#F44336',
        'usage_count': 7,
        'created_at': testTime.millisecondsSinceEpoch,
      };

      // Act
      final tag = Tag.fromMap(map);

      // Assert
      expect(tag.id, 1);
      expect(tag.name, 'urgent');
      expect(tag.color, '#F44336');
      expect(tag.usageCount, 7);
      expect(tag.createdAt.millisecondsSinceEpoch, testTime.millisecondsSinceEpoch);
    });

    test('should create Tag from Map without optional fields', () {
      // Arrange
      final testTime = DateTime.now();
      final map = {
        'id': 2,
        'name': 'simple',
        'usage_count': 0,
        'created_at': testTime.millisecondsSinceEpoch,
      };

      // Act
      final tag = Tag.fromMap(map);

      // Assert
      expect(tag.id, 2);
      expect(tag.name, 'simple');
      expect(tag.color, isNull);
      expect(tag.usageCount, 0);
      expect(tag.createdAt.millisecondsSinceEpoch, testTime.millisecondsSinceEpoch);
    });

    test('should create updated copy with copyWith', () {
      // Arrange
      final testTime = DateTime.now();
      final original = Tag(
        id: 1,
        name: 'original',
        color: '#000000',
        usageCount: 1,
        createdAt: testTime,
      );

      // Act
      final updated = original.copyWith(
        name: 'updated',
        usageCount: 5,
      );

      // Assert
      expect(updated.id, 1);
      expect(updated.name, 'updated');
      expect(updated.color, '#000000');
      expect(updated.usageCount, 5);
      expect(updated.createdAt, testTime);
    });

    test('should increment usage count', () {
      // Arrange
      final tag = Tag(name: 'test', usageCount: 3);

      // Act
      final incremented = tag.incrementUsage();

      // Assert
      expect(incremented.usageCount, 4);
      expect(incremented.name, 'test');
      expect(incremented.id, tag.id);
    });

    test('should normalize tag name', () {
      // Act
      final tag1 = Tag(name: 'Work Project');
      final tag2 = Tag(name: 'WORK PROJECT');
      final tag3 = Tag(name: 'work-project');

      // Assert
      expect(tag1.normalizedName, 'work project');
      expect(tag2.normalizedName, 'work project');
      expect(tag3.normalizedName, 'work-project');
    });

    test('should validate tag name is not empty', () {
      // Assert
      expect(
        () => Tag(name: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate tag name is not only whitespace', () {
      // Assert
      expect(
        () => Tag(name: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should trim tag name', () {
      // Act
      final tag = Tag(name: '  work  ');

      // Assert
      expect(tag.name, 'work');
    });

    test('should validate color format', () {
      // Valid colors should work
      expect(() => Tag(name: 'test', color: '#FF5722'), returnsNormally);
      expect(() => Tag(name: 'test', color: '#000'), returnsNormally);
      expect(() => Tag(name: 'test', color: '#ffffff'), returnsNormally);

      // Invalid colors should throw
      expect(() => Tag(name: 'test', color: 'red'), throwsA(isA<ArgumentError>()));
      expect(() => Tag(name: 'test', color: '#GG5722'), throwsA(isA<ArgumentError>()));
      expect(() => Tag(name: 'test', color: '#12'), throwsA(isA<ArgumentError>()));
    });

    test('should handle equality correctly', () {
      // Arrange
      final testTime = DateTime.now();
      final tag1 = Tag(
        id: 1,
        name: 'test',
        color: '#FF5722',
        usageCount: 2,
        createdAt: testTime,
      );
      final tag2 = Tag(
        id: 1,
        name: 'test',
        color: '#FF5722',
        usageCount: 2,
        createdAt: testTime,
      );

      // Assert
      expect(tag1, equals(tag2));
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('should have different equality for different names', () {
      // Arrange
      final tag1 = Tag(id: 1, name: 'work');
      final tag2 = Tag(id: 1, name: 'personal');

      // Assert
      expect(tag1, isNot(equals(tag2)));
    });
  });
}