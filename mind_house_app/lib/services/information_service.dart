import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/tag_service.dart';

class InformationService {
  final InformationRepository _informationRepository;
  final TagRepository _tagRepository;
  final TagService _tagService;

  InformationService({
    required InformationRepository informationRepository,
    required TagRepository tagRepository,
    required TagService tagService,
  })  : _informationRepository = informationRepository,
        _tagRepository = tagRepository,
        _tagService = tagService;

  /// Create information with associated tags
  Future<Information> createInformation({
    required String content,
    required List<String> tagNames,
  }) async {
    // Validate content
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }

    // Create the information
    final information = Information(content: trimmedContent);
    final createdInfo = await _informationRepository.create(information);

    // Process tags
    if (tagNames.isNotEmpty) {
      await _associateTagsWithInformation(createdInfo.id, tagNames);
    }

    return createdInfo;
  }

  /// Update information and its tags
  Future<Information> updateInformation({
    required Information information,
    required List<String> tagNames,
  }) async {
    // Validate content
    final trimmedContent = information.content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }

    // Update the information
    final updatedInfo = await _informationRepository.update(information);

    // TODO: Remove existing tag associations and create new ones
    // This would require implementing InformationTag repository
    await _associateTagsWithInformation(updatedInfo.id, tagNames);

    return updatedInfo;
  }

  /// Associate tags with information
  Future<void> _associateTagsWithInformation(String informationId, List<String> tagNames) async {
    // Deduplicate tag names
    final uniqueTagNames = _tagService.deduplicateTagNames(tagNames);

    // Process each tag
    for (final tagName in uniqueTagNames) {
      if (_tagService.isValidTagName(tagName)) {
        try {
          final tag = await _tagService.createOrGetTag(tagName);
          
          // Increment usage count
          if (tag.id != null) {
            await _tagRepository.incrementUsageCount(tag.id!);
          }

          // TODO: Create InformationTag association
          // This would require implementing InformationTag repository
        } catch (e) {
          // Log error but continue with other tags
          continue;
        }
      }
    }
  }

  /// Search information with advanced filtering
  Future<List<Information>> searchInformation({
    String? query,
    List<String>? tagNames,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    // If only query is provided, use simple content search
    if (query != null && query.trim().isNotEmpty && 
        (tagNames == null || tagNames.isEmpty) &&
        fromDate == null && toDate == null) {
      return await _informationRepository.searchByContent(query.trim());
    }

    // TODO: Implement advanced search with tag filtering and date ranges
    // For now, fall back to basic operations
    if (tagNames != null && tagNames.isNotEmpty) {
      // Get tag IDs for filtering
      final List<int> tagIds = [];
      for (final tagName in tagNames) {
        final tag = await _tagRepository.findByName(tagName.trim().toLowerCase());
        if (tag?.id != null) {
          tagIds.add(tag!.id!);
        }
      }
      
      if (tagIds.isNotEmpty) {
        return await _informationRepository.getByTagIds(tagIds);
      }
    }

    // Default to getting all with pagination
    return await _informationRepository.getWithPagination(
      limit: limit ?? 20,
      offset: offset ?? 0,
    );
  }

  /// Get information with its associated tags
  Future<Map<String, dynamic>> getInformationWithTags(String informationId) async {
    final information = await _informationRepository.getById(informationId);
    if (information == null) {
      throw ArgumentError('Information not found');
    }

    // TODO: Get associated tags
    // For now, return empty list
    final List<Tag> tags = [];

    return {
      'information': information,
      'tags': tags,
    };
  }

  /// Delete information and clean up tag associations
  Future<void> deleteInformation(String informationId) async {
    // TODO: Remove tag associations first
    // This would require implementing InformationTag repository

    // Delete the information
    await _informationRepository.delete(informationId);

    // TODO: Optionally clean up unused tags
    // await _tagService.cleanupUnusedTags();
  }

  /// Get recently created information
  Future<List<Information>> getRecentInformation({int limit = 10}) async {
    final allInfo = await _informationRepository.getAll();
    
    // Sort by creation date (newest first)
    allInfo.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allInfo.take(limit).toList();
  }

  /// Get recently updated information
  Future<List<Information>> getRecentlyUpdated({int limit = 10}) async {
    final allInfo = await _informationRepository.getAll();
    
    // Filter out information that hasn't been updated
    final updated = allInfo.where((info) => 
      info.createdAt != info.updatedAt
    ).toList();
    
    // Sort by update date (newest first)
    updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return updated.take(limit).toList();
  }

  /// Validate information content
  bool isValidContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 10000) return false; // Max length
    
    return true;
  }

  /// Get statistics about information
  Future<Map<String, dynamic>> getInformationStatistics() async {
    final allInfo = await _informationRepository.getAll();
    final allTags = await _tagRepository.getAll();

    return {
      'total_information': allInfo.length,
      'total_tags': allTags.length,
      'average_content_length': allInfo.isNotEmpty 
        ? allInfo.map((i) => i.content.length).reduce((a, b) => a + b) / allInfo.length
        : 0,
      'most_used_tags': await _tagRepository.getMostUsed(limit: 5),
      'recent_information_count': allInfo.where((info) =>
        DateTime.now().difference(info.createdAt).inDays < 7
      ).length,
    };
  }
}