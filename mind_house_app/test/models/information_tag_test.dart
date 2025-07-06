import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/information_tag.dart';

void main() {
  group('InformationTag Model Tests', () {
    test('should create InformationTag with all parameters', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;
      final testTime = DateTime.now();

      // Act
      final informationTag = InformationTag(
        informationId: informationId,
        tagId: tagId,
        createdAt: testTime,
      );

      // Assert
      expect(informationTag.informationId, informationId);
      expect(informationTag.tagId, tagId);
      expect(informationTag.createdAt, testTime);
    });

    test('should create InformationTag with default createdAt', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;

      // Act
      final informationTag = InformationTag(
        informationId: informationId,
        tagId: tagId,
      );

      // Assert
      expect(informationTag.informationId, informationId);
      expect(informationTag.tagId, tagId);
      expect(informationTag.createdAt, isNotNull);
      expect(informationTag.createdAt.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('should convert to Map correctly', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;
      final testTime = DateTime.now();
      final informationTag = InformationTag(
        informationId: informationId,
        tagId: tagId,
        createdAt: testTime,
      );

      // Act
      final map = informationTag.toMap();

      // Assert
      expect(map['information_id'], informationId);
      expect(map['tag_id'], tagId);
      expect(map['created_at'], testTime.millisecondsSinceEpoch);
    });

    test('should create InformationTag from Map correctly', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;
      final testTime = DateTime.now();
      final map = {
        'information_id': informationId,
        'tag_id': tagId,
        'created_at': testTime.millisecondsSinceEpoch,
      };

      // Act
      final informationTag = InformationTag.fromMap(map);

      // Assert
      expect(informationTag.informationId, informationId);
      expect(informationTag.tagId, tagId);
      expect(informationTag.createdAt.millisecondsSinceEpoch, testTime.millisecondsSinceEpoch);
    });

    test('should create updated copy with copyWith', () {
      // Arrange
      const originalInfoId = '123e4567-e89b-12d3-a456-426614174000';
      const newInfoId = '987fcdeb-51a2-43d1-b678-123456789abc';
      const originalTagId = 1;
      const newTagId = 2;
      final testTime = DateTime.now();
      final original = InformationTag(
        informationId: originalInfoId,
        tagId: originalTagId,
        createdAt: testTime,
      );

      // Act
      final updated = original.copyWith(
        informationId: newInfoId,
        tagId: newTagId,
      );

      // Assert
      expect(updated.informationId, newInfoId);
      expect(updated.tagId, newTagId);
      expect(updated.createdAt, testTime);
    });

    test('should validate informationId is not empty', () {
      // Assert
      expect(
        () => InformationTag(informationId: '', tagId: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate tagId is positive', () {
      // Assert
      expect(
        () => InformationTag(informationId: '123e4567-e89b-12d3-a456-426614174000', tagId: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => InformationTag(informationId: '123e4567-e89b-12d3-a456-426614174000', tagId: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle equality correctly', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;
      final testTime = DateTime.now();
      final infoTag1 = InformationTag(
        informationId: informationId,
        tagId: tagId,
        createdAt: testTime,
      );
      final infoTag2 = InformationTag(
        informationId: informationId,
        tagId: tagId,
        createdAt: testTime,
      );

      // Assert
      expect(infoTag1, equals(infoTag2));
      expect(infoTag1.hashCode, equals(infoTag2.hashCode));
    });

    test('should have different equality for different informationId', () {
      // Arrange
      const informationId1 = '123e4567-e89b-12d3-a456-426614174000';
      const informationId2 = '987fcdeb-51a2-43d1-b678-123456789abc';
      const tagId = 1;
      final infoTag1 = InformationTag(informationId: informationId1, tagId: tagId);
      final infoTag2 = InformationTag(informationId: informationId2, tagId: tagId);

      // Assert
      expect(infoTag1, isNot(equals(infoTag2)));
    });

    test('should have different equality for different tagId', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId1 = 1;
      const tagId2 = 2;
      final infoTag1 = InformationTag(informationId: informationId, tagId: tagId1);
      final infoTag2 = InformationTag(informationId: informationId, tagId: tagId2);

      // Assert
      expect(infoTag1, isNot(equals(infoTag2)));
    });

    test('should provide string representation', () {
      // Arrange
      const informationId = '123e4567-e89b-12d3-a456-426614174000';
      const tagId = 1;
      final informationTag = InformationTag(
        informationId: informationId,
        tagId: tagId,
      );

      // Act
      final stringRep = informationTag.toString();

      // Assert
      expect(stringRep, contains('InformationTag'));
      expect(stringRep, contains(informationId));
      expect(stringRep, contains('$tagId'));
    });
  });
}