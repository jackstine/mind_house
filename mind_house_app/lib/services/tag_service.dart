import 'dart:math';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';

class TagService {
  final TagRepository _tagRepository;
  
  // Color palette for auto-assigning tag colors
  static const List<String> _colorPalette = [
    'FF6B73', // Red
    'FF8E53', // Orange  
    'FF9F40', // Orange-Yellow
    'FFD93D', // Yellow
    '6BCF7F', // Green
    '4D96FF', // Blue
    '9B59B6', // Purple
    'E67E22', // Orange
    '1ABC9C', // Teal
    'F39C12', // Orange
    '3498DB', // Light Blue
    'E74C3C', // Red
    '2ECC71', // Green
    '9B59B6', // Purple
    'F1C40F', // Yellow
  ];

  TagService(this._tagRepository);

  /// Generate tag suggestions with intelligent algorithm
  Future<List<Tag>> getSmartSuggestions(String prefix, {int limit = 10}) async {
    if (prefix.trim().isEmpty) {
      return await _tagRepository.getMostUsed(limit: limit);
    }

    final suggestions = await _tagRepository.getSuggestions(prefix, limit: limit * 2);
    
    // Sort by relevance: exact matches first, then by usage count
    suggestions.sort((a, b) {
      final aExact = a.name.toLowerCase() == prefix.toLowerCase() ? 1 : 0;
      final bExact = b.name.toLowerCase() == prefix.toLowerCase() ? 1 : 0;
      
      if (aExact != bExact) {
        return bExact - aExact; // Exact matches first
      }
      
      final aStarts = a.name.toLowerCase().startsWith(prefix.toLowerCase()) ? 1 : 0;
      final bStarts = b.name.toLowerCase().startsWith(prefix.toLowerCase()) ? 1 : 0;
      
      if (aStarts != bStarts) {
        return bStarts - aStarts; // Starts with prefix next
      }
      
      // Then by usage count
      return b.usageCount.compareTo(a.usageCount);
    });

    return suggestions.take(limit).toList();
  }

  /// Auto-assign a color to a new tag
  String assignColor() {
    final random = Random();
    return _colorPalette[random.nextInt(_colorPalette.length)];
  }

  /// Create or get existing tag with automatic color assignment
  Future<Tag> createOrGetTag(String name) async {
    final normalizedName = name.trim().toLowerCase();
    
    if (normalizedName.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }

    // Check if tag already exists
    final existingTag = await _tagRepository.findByName(normalizedName);
    if (existingTag != null) {
      return existingTag;
    }

    // Create new tag with auto-assigned color
    final newTag = Tag(
      name: normalizedName,
      color: assignColor(),
    );

    return await _tagRepository.create(newTag);
  }

  /// Increment usage count for multiple tags
  Future<void> incrementUsageForTags(List<String> tagNames) async {
    for (final tagName in tagNames) {
      final tag = await _tagRepository.findByName(tagName.trim().toLowerCase());
      if (tag != null && tag.id != null) {
        await _tagRepository.incrementUsageCount(tag.id!);
      }
    }
  }

  /// Get or create tags for information
  Future<List<Tag>> processTagsForInformation(List<String> tagNames) async {
    final List<Tag> processedTags = [];

    for (final tagName in tagNames) {
      final normalizedName = tagName.trim();
      if (normalizedName.isNotEmpty) {
        try {
          final tag = await createOrGetTag(normalizedName);
          processedTags.add(tag);
        } catch (e) {
          // Skip invalid tags but continue processing
          continue;
        }
      }
    }

    return processedTags;
  }

  /// Remove duplicates from tag names
  List<String> deduplicateTagNames(List<String> tagNames) {
    final Set<String> seen = {};
    return tagNames
        .map((name) => name.trim().toLowerCase())
        .where((name) => name.isNotEmpty && seen.add(name))
        .toList();
  }

  /// Validate tag name
  bool isValidTagName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 50) return false; // Max length
    
    // Allow alphanumeric, spaces, hyphens, underscores
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    return validPattern.hasMatch(trimmed);
  }

  /// Get trending tags (most used in last period)
  Future<List<Tag>> getTrendingTags({int limit = 10}) async {
    // For now, return most used tags
    // In future, could implement time-based trending
    return await _tagRepository.getMostUsed(limit: limit);
  }

  /// Clean up unused tags (with usage count 0)
  Future<int> cleanupUnusedTags() async {
    final allTags = await _tagRepository.getAll();
    int deletedCount = 0;

    for (final tag in allTags) {
      if (tag.usageCount == 0 && tag.id != null) {
        await _tagRepository.delete(tag.id!);
        deletedCount++;
      }
    }

    return deletedCount;
  }
}