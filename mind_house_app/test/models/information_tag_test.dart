import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/information_tag.dart';

void main() {
  group('InformationTag Model Tests', () {
    late DateTime testDateTime;
    
    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30, 0);
    });
    
    group('Constructor and Validation', () {
      test('should create InformationTag with valid data', () {
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        expect(informationTag.informationId, equals('info-123'));
        expect(informationTag.tagId, equals('tag-456'));
        expect(informationTag.assignedAt, equals(testDateTime));
        expect(informationTag.assignedBy, equals('user-789'));
      });
      
      test('should create InformationTag with default values', () {
        final beforeCreation = DateTime.now();
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
        );
        final afterCreation = DateTime.now();
        
        expect(informationTag.informationId, equals('info-123'));
        expect(informationTag.tagId, equals('tag-456'));
        expect(informationTag.assignedBy, equals('system'));
        expect(informationTag.assignedAt.isAfter(beforeCreation.subtract(Duration(milliseconds: 1))), isTrue);
        expect(informationTag.assignedAt.isBefore(afterCreation.add(Duration(milliseconds: 1))), isTrue);
      });
      
      test('should throw ArgumentError when informationId is empty', () {
        expect(
          () => InformationTag(
            informationId: '',
            tagId: 'tag-456',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Information ID cannot be empty'),
          )),
        );
      });
      
      test('should throw ArgumentError when informationId is whitespace only', () {
        expect(
          () => InformationTag(
            informationId: '   ',
            tagId: 'tag-456',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Information ID cannot be empty'),
          )),
        );
      });
      
      test('should throw ArgumentError when tagId is empty', () {
        expect(
          () => InformationTag(
            informationId: 'info-123',
            tagId: '',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Tag ID cannot be empty'),
          )),
        );
      });
      
      test('should throw ArgumentError when tagId is whitespace only', () {
        expect(
          () => InformationTag(
            informationId: 'info-123',
            tagId: '   ',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Tag ID cannot be empty'),
          )),
        );
      });
      
      test('should throw ArgumentError when assignedBy is empty', () {
        expect(
          () => InformationTag(
            informationId: 'info-123',
            tagId: 'tag-456',
            assignedBy: '',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('AssignedBy cannot be empty'),
          )),
        );
      });
      
      test('should throw ArgumentError when assignedBy is whitespace only', () {
        expect(
          () => InformationTag(
            informationId: 'info-123',
            tagId: 'tag-456',
            assignedBy: '   ',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('AssignedBy cannot be empty'),
          )),
        );
      });
    });
    
    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final json = informationTag.toJson();
        
        expect(json, equals({
          'information_id': 'info-123',
          'tag_id': 'tag-456',
          'assigned_at': '2024-01-15T10:30:00.000',
          'assigned_by': 'user-789',
        }));
      });
      
      test('should serialize to JSON with default assignedBy', () {
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
        );
        
        final json = informationTag.toJson();
        
        expect(json['assigned_by'], equals('system'));
      });
      
      test('should deserialize from JSON correctly', () {
        final json = {
          'information_id': 'info-123',
          'tag_id': 'tag-456',
          'assigned_at': '2024-01-15T10:30:00.000',
          'assigned_by': 'user-789',
        };
        
        final informationTag = InformationTag.fromJson(json);
        
        expect(informationTag.informationId, equals('info-123'));
        expect(informationTag.tagId, equals('tag-456'));
        expect(informationTag.assignedAt, equals(testDateTime));
        expect(informationTag.assignedBy, equals('user-789'));
      });
      
      test('should deserialize from JSON with default assignedBy', () {
        final json = {
          'information_id': 'info-123',
          'tag_id': 'tag-456',
          'assigned_at': '2024-01-15T10:30:00.000',
        };
        
        final informationTag = InformationTag.fromJson(json);
        
        expect(informationTag.assignedBy, equals('system'));
      });
      
      test('should handle round-trip JSON serialization', () {
        final original = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final json = original.toJson();
        final deserialized = InformationTag.fromJson(json);
        
        expect(deserialized.informationId, equals(original.informationId));
        expect(deserialized.tagId, equals(original.tagId));
        expect(deserialized.assignedAt, equals(original.assignedAt));
        expect(deserialized.assignedBy, equals(original.assignedBy));
      });
    });
    
    group('copyWith Method', () {
      late InformationTag originalInformationTag;
      
      setUp(() {
        originalInformationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
      });
      
      test('should create copy with updated assignedAt', () {
        final newDateTime = DateTime(2024, 2, 20, 15, 45, 0);
        final updatedInformationTag = originalInformationTag.copyWith(
          assignedAt: newDateTime,
        );
        
        expect(updatedInformationTag.informationId, equals(originalInformationTag.informationId));
        expect(updatedInformationTag.tagId, equals(originalInformationTag.tagId));
        expect(updatedInformationTag.assignedAt, equals(newDateTime));
        expect(updatedInformationTag.assignedBy, equals(originalInformationTag.assignedBy));
      });
      
      test('should create copy with updated assignedBy', () {
        final updatedInformationTag = originalInformationTag.copyWith(
          assignedBy: 'admin-999',
        );
        
        expect(updatedInformationTag.informationId, equals(originalInformationTag.informationId));
        expect(updatedInformationTag.tagId, equals(originalInformationTag.tagId));
        expect(updatedInformationTag.assignedAt, equals(originalInformationTag.assignedAt));
        expect(updatedInformationTag.assignedBy, equals('admin-999'));
      });
      
      test('should create copy with multiple updated fields', () {
        final newDateTime = DateTime(2024, 2, 20, 15, 45, 0);
        final updatedInformationTag = originalInformationTag.copyWith(
          assignedAt: newDateTime,
          assignedBy: 'admin-999',
        );
        
        expect(updatedInformationTag.informationId, equals(originalInformationTag.informationId));
        expect(updatedInformationTag.tagId, equals(originalInformationTag.tagId));
        expect(updatedInformationTag.assignedAt, equals(newDateTime));
        expect(updatedInformationTag.assignedBy, equals('admin-999'));
      });
      
      test('should create copy with no changes when no parameters provided', () {
        final copiedInformationTag = originalInformationTag.copyWith();
        
        expect(copiedInformationTag.informationId, equals(originalInformationTag.informationId));
        expect(copiedInformationTag.tagId, equals(originalInformationTag.tagId));
        expect(copiedInformationTag.assignedAt, equals(originalInformationTag.assignedAt));
        expect(copiedInformationTag.assignedBy, equals(originalInformationTag.assignedBy));
      });
      
      test('should maintain immutability of primary key fields', () {
        final newDateTime = DateTime(2024, 2, 20, 15, 45, 0);
        final updatedInformationTag = originalInformationTag.copyWith(
          assignedAt: newDateTime,
          assignedBy: 'admin-999',
        );
        
        // Primary key fields should remain unchanged
        expect(updatedInformationTag.informationId, equals('info-123'));
        expect(updatedInformationTag.tagId, equals('tag-456'));
      });
    });
    
    group('Equality and Hash Code', () {
      test('should be equal when informationId and tagId are the same', () {
        final informationTag1 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final informationTag2 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: DateTime(2024, 3, 1, 12, 0, 0), // Different date
          assignedBy: 'admin-999', // Different assignedBy
        );
        
        expect(informationTag1, equals(informationTag2));
        expect(informationTag1.hashCode, equals(informationTag2.hashCode));
      });
      
      test('should not be equal when informationId is different', () {
        final informationTag1 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final informationTag2 = InformationTag(
          informationId: 'info-999', // Different informationId
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        expect(informationTag1, isNot(equals(informationTag2)));
      });
      
      test('should not be equal when tagId is different', () {
        final informationTag1 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final informationTag2 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-999', // Different tagId
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        expect(informationTag1, isNot(equals(informationTag2)));
      });
      
      test('should not be equal when compared to different type', () {
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        expect(informationTag, isNot(equals('not an InformationTag')));
        expect(informationTag, isNot(equals(123)));
        expect(informationTag, isNot(equals(null)));
      });
      
      test('should have same hash code for equal objects', () {
        final informationTag1 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final informationTag2 = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: DateTime(2024, 3, 1), // Different date
          assignedBy: 'admin-999', // Different assignedBy
        );
        
        expect(informationTag1.hashCode, equals(informationTag2.hashCode));
      });
    });
    
    group('toString Method', () {
      test('should provide readable string representation', () {
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: testDateTime,
          assignedBy: 'user-789',
        );
        
        final stringRep = informationTag.toString();
        
        expect(stringRep, contains('InformationTag('));
        expect(stringRep, contains('informationId: info-123'));
        expect(stringRep, contains('tagId: tag-456'));
        expect(stringRep, contains('assignedAt: $testDateTime'));
        expect(stringRep, contains('assignedBy: "user-789"'));
      });
      
      test('should handle special characters in string representation', () {
        final informationTag = InformationTag(
          informationId: 'info-with-dashes',
          tagId: 'tag_with_underscores',
          assignedAt: testDateTime,
          assignedBy: 'user@example.com',
        );
        
        final stringRep = informationTag.toString();
        
        expect(stringRep, contains('informationId: info-with-dashes'));
        expect(stringRep, contains('tagId: tag_with_underscores'));
        expect(stringRep, contains('assignedBy: "user@example.com"'));
      });
    });
    
    group('Edge Cases and Integration', () {
      test('should handle UTC and local datetime correctly', () {
        final utcDateTime = DateTime.utc(2024, 1, 15, 10, 30, 0);
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: utcDateTime,
        );
        
        final json = informationTag.toJson();
        final deserialized = InformationTag.fromJson(json);
        
        expect(deserialized.assignedAt, equals(utcDateTime));
      });
      
      test('should handle minimum and maximum datetime values', () {
        final minDateTime = DateTime.fromMillisecondsSinceEpoch(0);
        final informationTag = InformationTag(
          informationId: 'info-123',
          tagId: 'tag-456',
          assignedAt: minDateTime,
        );
        
        expect(informationTag.assignedAt, equals(minDateTime));
        
        // Test serialization with extreme dates
        final json = informationTag.toJson();
        final deserialized = InformationTag.fromJson(json);
        expect(deserialized.assignedAt, equals(minDateTime));
      });
      
      test('should handle very long ID strings', () {
        final longId = 'a' * 1000; // Very long ID
        final informationTag = InformationTag(
          informationId: longId,
          tagId: 'tag-456',
        );
        
        expect(informationTag.informationId, equals(longId));
        expect(informationTag.informationId.length, equals(1000));
      });
      
      test('should handle Unicode characters in ID fields', () {
        final informationTag = InformationTag(
          informationId: 'info-测试-123',
          tagId: 'tag-🏷️-456',
          assignedBy: 'user-أحمد',
        );
        
        expect(informationTag.informationId, equals('info-测试-123'));
        expect(informationTag.tagId, equals('tag-🏷️-456'));
        expect(informationTag.assignedBy, equals('user-أحمد'));
        
        // Test serialization with Unicode
        final json = informationTag.toJson();
        final deserialized = InformationTag.fromJson(json);
        
        expect(deserialized.informationId, equals('info-测试-123'));
        expect(deserialized.tagId, equals('tag-🏷️-456'));
        expect(deserialized.assignedBy, equals('user-أحمد'));
      });
    });
  });
}