import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/models/information.dart';

void main() {
  group('Information Model Tests', () {
    late Information testInformation;
    
    setUp(() {
      testInformation = Information(
        title: 'Test Title',
        content: 'Test content for information model',
        type: InformationType.note,
      );
    });
    
    group('Constructor Tests', () {
      test('should create Information with required fields', () {
        expect(testInformation.title, equals('Test Title'));
        expect(testInformation.content, equals('Test content for information model'));
        expect(testInformation.type, equals(InformationType.note));
        expect(testInformation.id, isNotNull);
        expect(testInformation.id.length, equals(36)); // UUID v4 length
        expect(testInformation.createdAt, isNotNull);
        expect(testInformation.updatedAt, isNotNull);
      });
      
      test('should create Information with all optional fields', () {
        final information = Information(
          title: 'Test Title',
          content: 'Test content',
          type: InformationType.bookmark,
          source: 'Test Source',
          url: 'https://example.com',
          importance: 5,
          isFavorite: true,
          isArchived: true,
          metadata: {'key': 'value'},
        );
        
        expect(information.source, equals('Test Source'));
        expect(information.url, equals('https://example.com'));
        expect(information.importance, equals(5));
        expect(information.isFavorite, isTrue);
        expect(information.isArchived, isTrue);
        expect(information.metadata, equals({'key': 'value'}));
      });
      
      test('should generate unique IDs for different instances', () {
        final info1 = Information(title: 'Title 1', content: 'Content 1', type: InformationType.note);
        final info2 = Information(title: 'Title 2', content: 'Content 2', type: InformationType.note);
        
        expect(info1.id, isNot(equals(info2.id)));
      });
      
      test('should allow custom ID when provided', () {
        const customId = 'custom-uuid-string';
        final information = Information(
          id: customId,
          title: 'Test Title',
          content: 'Test content',
          type: InformationType.note,
        );
        
        expect(information.id, equals(customId));
      });
    });
    
    group('Validation Tests', () {
      test('should validate title is not empty', () {
        expect(
          () => Information(title: '', content: 'Content', type: InformationType.note),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('should validate content is not empty', () {
        expect(
          () => Information(title: 'Title', content: '', type: InformationType.note),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('should validate importance range', () {
        expect(
          () => Information(title: 'Title', content: 'Content', type: InformationType.note, importance: -1),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => Information(title: 'Title', content: 'Content', type: InformationType.note, importance: 11),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('should validate URL format when provided', () {
        expect(
          () => Information(title: 'Title', content: 'Content', type: InformationType.note, url: 'invalid-url'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
    
    group('JSON Serialization Tests', () {
      test('should convert to JSON correctly', () {
        final json = testInformation.toJson();
        
        expect(json['id'], equals(testInformation.id));
        expect(json['title'], equals('Test Title'));
        expect(json['content'], equals('Test content for information model'));
        expect(json['type'], equals('note'));
        expect(json['importance'], equals(0));
        expect(json['is_favorite'], equals(0));
        expect(json['is_archived'], equals(0));
        expect(json['created_at'], isNotNull);
        expect(json['updated_at'], isNotNull);
      });
      
      test('should convert from JSON correctly', () {
        final json = {
          'id': 'test-uuid',
          'title': 'JSON Title',
          'content': 'JSON Content',
          'type': 'bookmark',
          'source': 'JSON Source',
          'url': 'https://example.com',
          'importance': 3,
          'is_favorite': 1,
          'is_archived': 0,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'accessed_at': '2024-01-01T00:00:00.000Z',
          'metadata': '{"key": "value"}',
        };
        
        final information = Information.fromJson(json);
        
        expect(information.id, equals('test-uuid'));
        expect(information.title, equals('JSON Title'));
        expect(information.content, equals('JSON Content'));
        expect(information.type, equals(InformationType.bookmark));
        expect(information.source, equals('JSON Source'));
        expect(information.url, equals('https://example.com'));
        expect(information.importance, equals(3));
        expect(information.isFavorite, isTrue);
        expect(information.isArchived, isFalse);
        expect(information.metadata, equals({'key': 'value'}));
      });
      
      test('should handle JSON roundtrip correctly', () {
        final json = testInformation.toJson();
        final recreated = Information.fromJson(json);
        
        expect(recreated.id, equals(testInformation.id));
        expect(recreated.title, equals(testInformation.title));
        expect(recreated.content, equals(testInformation.content));
        expect(recreated.type, equals(testInformation.type));
        expect(recreated.importance, equals(testInformation.importance));
        expect(recreated.isFavorite, equals(testInformation.isFavorite));
        expect(recreated.isArchived, equals(testInformation.isArchived));
      });
    });
    
    group('Copy and Update Tests', () {
      test('should create copy with updated fields', () {
        final updated = testInformation.copyWith(
          title: 'Updated Title',
          importance: 5,
          isFavorite: true,
        );
        
        expect(updated.id, equals(testInformation.id)); // ID should remain same
        expect(updated.title, equals('Updated Title'));
        expect(updated.content, equals(testInformation.content)); // Unchanged
        expect(updated.importance, equals(5));
        expect(updated.isFavorite, isTrue);
        expect(updated.createdAt, equals(testInformation.createdAt)); // Should remain same
        expect(updated.updatedAt.isAfter(testInformation.updatedAt), isTrue); // Should be updated
      });
      
      test('should update accessed timestamp', () {
        final originalAccessedAt = testInformation.accessedAt;
        
        // Wait a bit to ensure different timestamp
        Future.delayed(Duration(milliseconds: 1));
        
        final accessed = testInformation.markAsAccessed();
        
        expect(accessed.id, equals(testInformation.id));
        expect(accessed.accessedAt, isNotNull);
        if (originalAccessedAt != null) {
          expect(accessed.accessedAt!.isAfter(originalAccessedAt), isTrue);
        }
      });
    });
    
    group('Equality and HashCode Tests', () {
      test('should be equal when IDs are same', () {
        final info1 = Information(
          id: 'same-id',
          title: 'Title 1',
          content: 'Content 1',
          type: InformationType.note,
        );
        
        final info2 = Information(
          id: 'same-id',
          title: 'Title 2',
          content: 'Content 2',
          type: InformationType.bookmark,
        );
        
        expect(info1, equals(info2));
        expect(info1.hashCode, equals(info2.hashCode));
      });
      
      test('should not be equal when IDs are different', () {
        final info1 = Information(
          title: 'Same Title',
          content: 'Same Content',
          type: InformationType.note,
        );
        
        final info2 = Information(
          title: 'Same Title',
          content: 'Same Content',
          type: InformationType.note,
        );
        
        expect(info1, isNot(equals(info2)));
        expect(info1.hashCode, isNot(equals(info2.hashCode)));
      });
    });
    
    group('InformationType Enum Tests', () {
      test('should convert InformationType to string correctly', () {
        expect(InformationType.note.toString(), equals('InformationType.note'));
        expect(InformationType.bookmark.toString(), equals('InformationType.bookmark'));
        expect(InformationType.reminder.toString(), equals('InformationType.reminder'));
        expect(InformationType.task.toString(), equals('InformationType.task'));
      });
      
      test('should get InformationType value correctly', () {
        expect(InformationType.note.value, equals('note'));
        expect(InformationType.bookmark.value, equals('bookmark'));
        expect(InformationType.reminder.value, equals('reminder'));
        expect(InformationType.task.value, equals('task'));
      });
      
      test('should create InformationType from string', () {
        expect(InformationType.fromString('note'), equals(InformationType.note));
        expect(InformationType.fromString('bookmark'), equals(InformationType.bookmark));
        expect(InformationType.fromString('reminder'), equals(InformationType.reminder));
        expect(InformationType.fromString('task'), equals(InformationType.task));
      });
      
      test('should throw error for invalid InformationType string', () {
        expect(
          () => InformationType.fromString('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}