import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/information_tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart' show SortField, SortOrder;

/// Abstract interface for Information repository operations
/// 
/// This interface defines the contract for all Information repository implementations,
/// enabling dependency injection, testing, and multiple implementations (e.g., local database,
/// remote API, in-memory cache).
/// 
/// The interface follows the Repository pattern to abstract data access logic from
/// business logic, providing a clean separation of concerns and enabling:
/// - Easy unit testing through mocking
/// - Swappable data sources (SQLite, remote API, etc.)
/// - Consistent API across different implementations
/// - Dependency injection for better architecture
abstract class IInformationRepository {
  
  // ============================================================================
  // Core CRUD Operations
  // ============================================================================
  
  /// Create a new information item
  /// 
  /// Returns the ID of the created information item.
  /// Throws exception if creation fails.
  Future<String> create(Information information);

  /// Retrieve an information item by its ID
  /// 
  /// Returns the Information object if found, null otherwise.
  /// Throws exception if query fails.
  Future<Information?> getById(String id);

  /// Update an existing information item
  /// 
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws exception if update fails.
  Future<bool> update(Information information);

  /// Delete an information item by its ID
  /// 
  /// Returns true if the deletion was successful, false if no rows were affected.
  /// Throws exception if deletion fails.
  Future<bool> delete(String id);

  // ============================================================================
  // Query and Retrieval Operations
  // ============================================================================

  /// Retrieve all information items with optional pagination
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects ordered by creation date (newest first).
  /// Throws exception if query fails.
  Future<List<Information>> getAll({int? limit, int? offset});

  /// Retrieve all information items with custom sorting
  /// 
  /// [sortBy] - Field to sort by
  /// [sortOrder] - Sort direction (ascending or descending)
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects ordered by the specified criteria.
  /// Throws exception if query fails.
  Future<List<Information>> getAllSorted({
    required SortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  });

  /// Retrieve information items by type
  /// 
  /// [type] - The information type to filter by
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects of the specified type.
  /// Throws exception if query fails.
  Future<List<Information>> getByType(
    InformationType type, {
    int? limit,
    int? offset,
  });

  /// Retrieve favorite information items
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects marked as favorites.
  /// Throws exception if query fails.
  Future<List<Information>> getFavorites({int? limit, int? offset});

  /// Retrieve archived information items
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects marked as archived.
  /// Throws exception if query fails.
  Future<List<Information>> getArchived({int? limit, int? offset});

  /// Search information items by title and content
  /// 
  /// [query] - Search query string
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Performs case-insensitive search on title and content fields.
  /// Returns a list of Information objects matching the search criteria.
  /// Throws exception if query fails.
  Future<List<Information>> search(
    String query, {
    int? limit,
    int? offset,
  });

  /// Mark an information item as accessed
  /// 
  /// Updates the accessedAt timestamp for the specified information item.
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws exception if update fails.
  Future<bool> markAsAccessed(String id);

  /// Get count of information items by various criteria
  /// 
  /// [type] - Filter by information type (optional)
  /// [isFavorite] - Filter by favorite status (optional)
  /// [isArchived] - Filter by archived status (optional)
  /// 
  /// Returns the count of information items matching the criteria.
  /// Throws exception if query fails.
  Future<int> getCount({
    InformationType? type,
    bool? isFavorite,
    bool? isArchived,
  });

  /// Get recently accessed information items
  /// 
  /// [limit] - Maximum number of items to return (default: 10)
  /// 
  /// Returns a list of Information objects ordered by most recently accessed.
  /// Throws exception if query fails.
  Future<List<Information>> getRecentlyAccessed({int limit = 10});

  /// Get information items by importance level
  /// 
  /// [minImportance] - Minimum importance level (0-10)
  /// [maxImportance] - Maximum importance level (0-10, optional)
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects within the importance range.
  /// Throws exception if query fails.
  Future<List<Information>> getByImportance(
    int minImportance, {
    int? maxImportance,
    int? limit,
    int? offset,
  });

  // ============================================================================
  // Tag Management Operations
  // ============================================================================

  /// Add tags to an information item with automatic usage count updates
  /// 
  /// [informationId] - ID of the information item
  /// [tagIds] - List of tag IDs to add
  /// 
  /// This method creates associations and automatically increments 
  /// the usage count for each tag.
  /// Throws exception if operation fails.
  Future<void> addTags(String informationId, List<String> tagIds);

  /// Remove tags from an information item with automatic usage count updates
  /// 
  /// [informationId] - ID of the information item
  /// [tagIds] - List of tag IDs to remove
  /// 
  /// This method removes associations and automatically decrements 
  /// the usage count for each tag (minimum 0).
  /// Throws exception if operation fails.
  Future<void> removeTags(String informationId, List<String> tagIds);

  /// Update tags for an information item by replacing all existing tags
  /// 
  /// [informationId] - ID of the information item
  /// [newTagIds] - List of tag IDs that should be associated with the information
  /// 
  /// This method efficiently updates tag associations by:
  /// 1. Finding tags to remove (existing but not in new list)
  /// 2. Finding tags to add (in new list but not existing)
  /// 3. Updating usage counts accordingly
  /// 
  /// Throws exception if operation fails.
  Future<void> updateTags(String informationId, List<String> newTagIds);

  /// Get all tag assignments for an information item
  /// 
  /// [informationId] - ID of the information item
  /// 
  /// Returns a list of InformationTag associations for the given information.
  /// Throws exception if query fails.
  Future<List<InformationTag>> getTagAssignments(String informationId);

  /// Get all tag IDs associated with an information item
  /// 
  /// [informationId] - ID of the information item
  /// 
  /// Returns a list of tag IDs associated with the information.
  /// Throws exception if query fails.
  Future<List<String>> getTagIds(String informationId);

  /// Get information items by tag IDs
  /// 
  /// [tagIds] - List of tag IDs to filter by
  /// [requireAllTags] - If true, information must have ALL specified tags.
  ///                    If false, information must have AT LEAST ONE tag (default: false)
  /// [limit] - Maximum number of information items to return (optional)
  /// [offset] - Number of information items to skip (optional)
  /// 
  /// Returns information items that are associated with the specified tags.
  /// Throws exception if query fails.
  Future<List<Information>> getByTagIds(
    List<String> tagIds, {
    bool requireAllTags = false,
    int? limit,
    int? offset,
  });
}