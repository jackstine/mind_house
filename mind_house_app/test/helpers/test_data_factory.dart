import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/models/information_tag.dart';

/// Test data factory for creating consistent test data
class TestDataFactory {
  // Sample information content for testing
  static const List<String> _sampleContents = [
    'This is a sample information item for testing',
    'Another test information with different content',
    'Long form information that contains multiple sentences and provides good test data for various scenarios.',
    'Short info',
    'Testing special characters: @#\$%^&*()_+-=[]{}|;:",.<>?',
  ];

  // Sample tag names for testing
  static const List<String> _sampleTagNames = [
    'flutter',
    'dart',
    'testing',
    'important',
    'work',
    'personal',
    'project',
    'idea',
    'todo',
    'research',
  ];

  // Sample tag colors for testing
  static const List<String> _sampleColors = [
    'FF6B73',
    'FF8E53',
    'FF6B35',
    'F7931E',
    'FFD23F',
    'BFDB38',
    '06D6A0',
    '118AB2',
    '073B4C',
    '8B5CF6',
  ];

  /// Creates a sample Information object for testing
  static Information createInformation({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Information(
      id: id,
      content: content ?? _sampleContents[0],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted ?? false,
    );
  }

  /// Creates a list of sample Information objects for testing
  static List<Information> createInformationList(int count) {
    return List.generate(count, (index) {
      return Information(
        content: _sampleContents[index % _sampleContents.length],
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }

  /// Creates a sample Tag object for testing
  static Tag createTag({
    String? id,
    String? name,
    String? displayName,
    String? color,
    int? usageCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    final tagName = name ?? _sampleTagNames[0];
    return Tag(
      id: id,
      name: tagName,
      displayName: displayName ?? tagName,
      color: color ?? _sampleColors[0],
      usageCount: usageCount ?? 0,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
    );
  }

  /// Creates a list of sample Tag objects for testing
  static List<Tag> createTagList(int count) {
    return List.generate(count, (index) {
      final tagName = _sampleTagNames[index % _sampleTagNames.length];
      return Tag(
        name: '$tagName$index',
        displayName: tagName,
        color: _sampleColors[index % _sampleColors.length],
        usageCount: index,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        lastUsedAt: DateTime.now().subtract(Duration(hours: index * 2)),
      );
    });
  }

  /// Creates a sample InformationTag association for testing
  static InformationTag createInformationTag({
    String? informationId,
    String? tagId,
    DateTime? createdAt,
  }) {
    return InformationTag(
      informationId: informationId ?? 'test-info-id',
      tagId: tagId ?? 'test-tag-id',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Creates a list of InformationTag associations for testing
  static List<InformationTag> createInformationTagList({
    required List<String> informationIds,
    required List<String> tagIds,
  }) {
    final associations = <InformationTag>[];
    for (int i = 0; i < informationIds.length; i++) {
      for (int j = 0; j < tagIds.length; j++) {
        if ((i + j) % 3 == 0) { // Create sparse associations
          associations.add(InformationTag(
            informationId: informationIds[i],
            tagId: tagIds[j],
            createdAt: DateTime.now().subtract(Duration(minutes: i * j)),
          ));
        }
      }
    }
    return associations;
  }

  /// Creates test data for large dataset performance testing
  static List<Information> createLargeInformationDataset(int count) {
    return List.generate(count, (index) {
      return Information(
        content: 'Performance test information item #$index: ${_sampleContents[index % _sampleContents.length]}',
        createdAt: DateTime.now().subtract(Duration(minutes: index)),
        updatedAt: DateTime.now().subtract(Duration(seconds: index * 10)),
      );
    });
  }

  /// Creates test data for large tag dataset performance testing
  static List<Tag> createLargeTagDataset(int count) {
    return List.generate(count, (index) {
      final baseTag = _sampleTagNames[index % _sampleTagNames.length];
      return Tag(
        name: '${baseTag}_$index',
        displayName: '$baseTag $index',
        color: _sampleColors[index % _sampleColors.length],
        usageCount: count - index, // Vary usage counts
        createdAt: DateTime.now().subtract(Duration(minutes: index * 2)),
        lastUsedAt: DateTime.now().subtract(Duration(seconds: index * 30)),
      );
    });
  }

  /// Creates test data with edge cases for robust testing
  static List<Information> createEdgeCaseInformation() {
    return [
      Information(content: ''), // Empty content
      Information(content: ' '), // Whitespace only
      Information(content: 'a'), // Single character
      Information(content: 'A' * 10000), // Very long content
      Information(content: '🎉💻📱🚀'), // Unicode/emoji content
      Information(content: '\n\t\r'), // Special whitespace characters
      Information(content: 'Multi\nLine\nContent\nWith\nBreaks'),
      Information(content: 'Content with "quotes" and \'apostrophes\''),
      Information(content: 'Content with <tags> and &amp; entities'),
    ];
  }

  /// Creates test data with edge case tags
  static List<Tag> createEdgeCaseTags() {
    return [
      Tag(name: '', displayName: 'Empty Name', color: 'FF0000'),
      Tag(name: 'a', displayName: 'Single Char', color: '00FF00'),
      Tag(name: 'very-long-tag-name-that-exceeds-normal-limits-and-tests-ui-boundaries', 
           displayName: 'Very Long Tag', color: '0000FF'),
      Tag(name: '🏷️', displayName: 'Emoji Tag', color: 'FF00FF'),
      Tag(name: 'tag with spaces', displayName: 'Spaced Tag', color: '00FFFF'),
      Tag(name: 'special!@#\$%chars', displayName: 'Special Chars', color: 'FFFF00'),
      Tag(name: 'UPPERCASE', displayName: 'Upper Case', color: 'FF8080'),
      Tag(name: 'lowercase', displayName: 'Lower Case', color: '80FF80'),
      Tag(name: 'MiXeD-CaSe_123', displayName: 'Mixed Case', color: '8080FF'),
    ];
  }

  /// Creates mock data for database stress testing
  static Map<String, dynamic> createStressTestData({
    int informationCount = 1000,
    int tagCount = 500,
    double associationDensity = 0.1,
  }) {
    final information = createLargeInformationDataset(informationCount);
    final tags = createLargeTagDataset(tagCount);
    
    final informationIds = information.map((i) => i.id).toList();
    final tagIds = tags.map((t) => t.id).toList();
    
    // Create associations based on density
    final associations = <InformationTag>[];
    for (int i = 0; i < informationIds.length; i++) {
      for (int j = 0; j < tagIds.length; j++) {
        if ((i * j) % (1 / associationDensity).round() == 0) {
          associations.add(InformationTag(
            informationId: informationIds[i],
            tagId: tagIds[j],
            createdAt: DateTime.now().subtract(Duration(milliseconds: i + j)),
          ));
        }
      }
    }

    return {
      'information': information,
      'tags': tags,
      'associations': associations,
    };
  }
}