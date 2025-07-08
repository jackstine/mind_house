import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart' show TagSortField, SortOrder;

/// Abstract interface for Tag repository operations
/// 
/// This interface defines the contract for all Tag repository implementations,
/// enabling dependency injection, testing, and multiple implementations (e.g., local database,
/// remote API, in-memory cache).
/// 
/// The interface follows the Repository pattern to abstract data access logic from
/// business logic, providing a clean separation of concerns and enabling:
/// - Easy unit testing through mocking
/// - Swappable data sources (SQLite, remote API, etc.)
/// - Consistent API across different implementations
/// - Dependency injection for better architecture
/// - Advanced tag suggestion algorithms
/// - Usage analytics and smart recommendations
abstract class ITagRepository {
  
  // ============================================================================
  // Core CRUD Operations
  // ============================================================================
  
  /// Create a new tag in the repository
  /// 
  /// Returns the ID of the created tag.
  /// Throws exception if creation fails.
  /// Throws exception if tag name already exists.
  Future<String> create(Tag tag);

  /// Retrieve a tag by its ID
  /// 
  /// Returns the Tag object if found, null otherwise.
  /// Throws exception if query fails.
  Future<Tag?> getById(String id);

  /// Update an existing tag
  /// 
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws exception if update fails.
  Future<bool> update(Tag tag);

  /// Delete a tag by its ID
  /// 
  /// Returns true if the deletion was successful, false if no rows were affected.
  /// This will also cascade delete any associations in the information_tags table.
  /// Throws exception if deletion fails.
  Future<bool> delete(String id);

  // ============================================================================
  // Query and Retrieval Operations
  // ============================================================================

  /// Retrieve all tags with optional pagination
  /// 
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects ordered by name (alphabetical).
  /// Throws exception if query fails.
  Future<List<Tag>> getAll({int? limit, int? offset});

  /// Retrieve all tags with custom sorting
  /// 
  /// [sortBy] - Field to sort by
  /// [sortOrder] - Sort direction (ascending or descending)
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects ordered by the specified criteria.
  /// Throws exception if query fails.
  Future<List<Tag>> getAllSorted({
    required TagSortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  });

  /// Search tags by name or display name
  /// 
  /// [query] - Search query string
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Performs case-insensitive search on both name and display_name fields.
  /// Returns a list of Tag objects matching the search criteria, ordered by usage count.
  /// Throws exception if query fails.
  Future<List<Tag>> searchByName(
    String query, {
    int? limit,
    int? offset,
  });

  /// Find a tag by its exact name (case-insensitive)
  /// 
  /// [name] - The name to search for
  /// 
  /// Returns the Tag object if found, null otherwise.
  /// Useful for preventing duplicate tag creation.
  /// Throws exception if query fails.
  Future<Tag?> getByName(String name);

  // ============================================================================
  // Filtering and Categorization Operations
  // ============================================================================

  /// Retrieve tags by color
  /// 
  /// [color] - The hex color code to filter by
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects with the specified color.
  /// Throws exception if query fails.
  Future<List<Tag>> getByColor(
    String color, {
    int? limit,
    int? offset,
  });

  /// Retrieve frequently used tags
  /// 
  /// [threshold] - Minimum usage count to be considered frequently used (default: 10)
  /// [limit] - Maximum number of tags to return (optional)
  /// 
  /// Returns a list of Tag objects with usage count >= threshold, ordered by usage count.
  /// Throws exception if query fails.
  Future<List<Tag>> getFrequentlyUsed({
    int threshold = 10,
    int? limit,
  });

  /// Retrieve unused tags (usage count = 0)
  /// 
  /// [limit] - Maximum number of tags to return (optional)
  /// 
  /// Returns a list of Tag objects that have never been used.
  /// Throws exception if query fails.
  Future<List<Tag>> getUnused({int? limit});

  /// Retrieve recently used tags
  /// 
  /// [days] - Number of days to look back (default: 7)
  /// [limit] - Maximum number of tags to return (default: 10)
  /// 
  /// Returns a list of Tag objects updated within the specified time period.
  /// Throws exception if query fails.
  Future<List<Tag>> getRecentlyUsed({
    int days = 7,
    int limit = 10,
  });

  // ============================================================================
  // Analytics and Counting Operations
  // ============================================================================

  /// Get count of tags by various criteria
  /// 
  /// [hasUsage] - Filter by whether tag has been used (optional)
  /// [color] - Filter by color (optional)
  /// [minUsageCount] - Minimum usage count (optional)
  /// 
  /// Returns the count of tags matching the criteria.
  /// Throws exception if query fails.
  Future<int> getCount({
    bool? hasUsage,
    String? color,
    int? minUsageCount,
  });

  /// Get all unique colors used by tags
  /// 
  /// Returns a list of hex color codes currently in use.
  /// Throws exception if query fails.
  Future<List<String>> getUsedColors();

  // ============================================================================
  // Usage Tracking Operations
  // ============================================================================

  /// Increment the usage count for a tag and update last used timestamp
  /// 
  /// [id] - ID of the tag to increment usage for
  /// 
  /// Returns true if the increment was successful, false if tag doesn't exist.
  /// This method should be called whenever a tag is applied to information.
  /// Throws exception if update fails.
  Future<bool> incrementUsage(String id);

  /// Update the last used timestamp for a tag
  /// 
  /// [id] - ID of the tag to update
  /// 
  /// Returns true if the update was successful, false if tag doesn't exist.
  /// Throws exception if update fails.
  Future<bool> updateLastUsed(String id);

  // ============================================================================
  // Smart Suggestion Operations
  // ============================================================================

  /// Get tag suggestions based on partial name input
  /// 
  /// [partialName] - Partial tag name to search for
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// 
  /// Returns a list of Tag objects that start with or contain the partial name,
  /// ordered by usage count to prioritize frequently used tags.
  /// Throws exception if query fails.
  Future<List<Tag>> getSuggestions(
    String partialName, {
    int limit = 5,
  });

  /// Get smart tag suggestions based on context and usage patterns
  /// 
  /// [partialName] - Partial tag name to search for
  /// [existingTagIds] - IDs of tags already selected (for context-aware suggestions)
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// [includeRecentlyUsed] - Whether to boost recently used tags in ranking (default: true)
  /// 
  /// This method implements advanced suggestion logic that:
  /// - Prioritizes exact prefix matches over partial matches
  /// - Boosts frequently used tags
  /// - Considers recently used tags if enabled
  /// - Excludes already selected tags from suggestions
  /// - Uses intelligent ranking algorithm for optimal suggestions
  /// 
  /// Throws exception if query fails.
  Future<List<Tag>> getSmartSuggestions(
    String partialName, {
    List<String> existingTagIds = const [],
    int limit = 5,
    bool includeRecentlyUsed = true,
  });

  /// Get contextual tag suggestions based on co-occurrence patterns
  /// 
  /// [baseTagIds] - IDs of tags already selected to find related tags
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// 
  /// This method finds tags that are frequently used together with the provided tags.
  /// It queries the information_tags junction table to find co-occurrence patterns
  /// and suggests tags that are commonly used with the base tags.
  /// 
  /// Throws exception if query fails.
  Future<List<Tag>> getContextualSuggestions(
    List<String> baseTagIds, {
    int limit = 5,
  });

  /// Get trending tag suggestions based on recent usage patterns
  /// 
  /// [days] - Number of days to look back for trending analysis (default: 30)
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// 
  /// This method identifies tags that have seen increased usage in the recent period
  /// compared to their historical average. Good for discovering emerging topics.
  /// 
  /// Throws exception if query fails.
  Future<List<Tag>> getTrendingSuggestions({
    int days = 30,
    int limit = 5,
  });

  /// Get diverse tag suggestions to promote tag discovery
  /// 
  /// [excludeTagIds] - IDs of tags to exclude from suggestions
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// [maxPerColor] - Maximum tags per color to ensure diversity (default: 2)
  /// 
  /// This method returns a diverse set of tags across different colors and usage levels
  /// to help users discover new tags and avoid over-reliance on frequently used ones.
  /// 
  /// Throws exception if query fails.
  Future<List<Tag>> getDiverseSuggestions({
    List<String> excludeTagIds = const [],
    int limit = 5,
    int maxPerColor = 2,
  });
}