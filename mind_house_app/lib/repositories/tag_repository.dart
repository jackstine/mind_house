import 'package:sqflite/sqflite.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/models/tag.dart';

/// Enumeration for tag sorting fields
enum TagSortField {
  name,
  displayName,
  color,
  usageCount,
  createdAt,
  updatedAt,
  lastUsedAt,
}

/// Enumeration for sort order
enum SortOrder {
  ascending,
  descending,
}

/// Repository class for managing Tag entities in the database
/// 
/// Provides comprehensive CRUD operations, search functionality, filtering,
/// sorting, usage tracking, and color management for Tag objects. Follows 
/// repository pattern to abstract database operations from business logic.
/// 
/// This repository supports the tags-first approach of the Mind House app,
/// providing efficient tag management and usage analytics.
class TagRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  /// Table and column constants - using DatabaseHelper constants
  static const String _tableName = 'tags';
  static const String _colId = 'id';
  static const String _colName = 'name';
  static const String _colColor = 'color';
  static const String _colDescription = 'description';
  static const String _colUsageCount = 'usage_count';
  static const String _colCreatedAt = 'created_at';
  static const String _colUpdatedAt = 'updated_at';
  // Note: display_name and last_used_at not yet in database schema

  /// Create a new tag in the database
  /// 
  /// Returns the ID of the created tag.
  /// Throws [MindHouseDatabaseException] if creation fails.
  /// Throws [MindHouseDatabaseException] if tag name already exists.
  Future<String> create(Tag tag) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final Map<String, dynamic> data = tag.toJson();
      
      await db.insert(
        _tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      return tag.id;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to create tag',
        type: DatabaseErrorType.query,
        operation: 'create',
        context: {'tag_id': tag.id, 'name': tag.name},
        originalError: e,
      );
    }
  }

  /// Retrieve a tag by its ID
  /// 
  /// Returns the Tag object if found, null otherwise.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<Tag?> getById(String id) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colId = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return Tag.fromJson(results.first);
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve tag by ID',
        type: DatabaseErrorType.query,
        operation: 'getById',
        context: {'tag_id': id},
        originalError: e,
      );
    }
  }

  /// Update an existing tag
  /// 
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws [MindHouseDatabaseException] if update fails.
  Future<bool> update(Tag tag) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final Map<String, dynamic> data = tag.toJson();
      
      final int rowsAffected = await db.update(
        _tableName,
        data,
        where: '$_colId = ?',
        whereArgs: [tag.id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to update tag',
        type: DatabaseErrorType.query,
        operation: 'update',
        context: {'tag_id': tag.id, 'name': tag.name},
        originalError: e,
      );
    }
  }

  /// Delete a tag by its ID
  /// 
  /// Returns true if the deletion was successful, false if no rows were affected.
  /// This will also cascade delete any associations in the information_tags table.
  /// Throws [MindHouseDatabaseException] if deletion fails.
  Future<bool> delete(String id) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final int rowsAffected = await db.delete(
        _tableName,
        where: '$_colId = ?',
        whereArgs: [id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to delete tag',
        type: DatabaseErrorType.query,
        operation: 'delete',
        context: {'tag_id': id},
        originalError: e,
      );
    }
  }

  /// Retrieve all tags with optional pagination
  /// 
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects ordered by name (alphabetical).
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getAll({int? limit, int? offset}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        orderBy: '$_colName ASC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve all tags',
        type: DatabaseErrorType.query,
        operation: 'getAll',
        context: {'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve all tags with custom sorting
  /// 
  /// [sortBy] - Field to sort by
  /// [sortOrder] - Sort direction (ascending or descending)
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects ordered by the specified criteria.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getAllSorted({
    required TagSortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      String orderByColumn;
      switch (sortBy) {
        case TagSortField.name:
          orderByColumn = _colName;
          break;
        case TagSortField.displayName:
          orderByColumn = _colName; // Use name since display_name not in schema yet
          break;
        case TagSortField.color:
          orderByColumn = _colColor;
          break;
        case TagSortField.usageCount:
          orderByColumn = _colUsageCount;
          break;
        case TagSortField.createdAt:
          orderByColumn = _colCreatedAt;
          break;
        case TagSortField.updatedAt:
          orderByColumn = _colUpdatedAt;
          break;
        case TagSortField.lastUsedAt:
          orderByColumn = _colUpdatedAt; // Use updated_at as proxy since last_used_at not in schema yet
          break;
      }
      
      final String sortDirection = sortOrder == SortOrder.ascending ? 'ASC' : 'DESC';
      final String orderBy = '$orderByColumn $sortDirection';
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve sorted tags',
        type: DatabaseErrorType.query,
        operation: 'getAllSorted',
        context: {
          'sortBy': sortBy.name,
          'sortOrder': sortOrder.name,
          'limit': limit,
          'offset': offset,
        },
        originalError: e,
      );
    }
  }

  /// Search tags by name or display name
  /// 
  /// [query] - Search query string
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Performs case-insensitive search on both name and display_name fields.
  /// Returns a list of Tag objects matching the search criteria, ordered by usage count.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> searchByName(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      if (query.trim().isEmpty) {
        return [];
      }
      
      final String searchPattern = '%${query.trim()}%';
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colName LIKE ?',
        whereArgs: [searchPattern],
        orderBy: '$_colUsageCount DESC, $_colName ASC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to search tags by name',
        type: DatabaseErrorType.query,
        operation: 'searchByName',
        context: {'query': query, 'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve tags by color
  /// 
  /// [color] - The hex color code to filter by
  /// [limit] - Maximum number of tags to return (optional)
  /// [offset] - Number of tags to skip (optional)
  /// 
  /// Returns a list of Tag objects with the specified color.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getByColor(
    String color, {
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colColor = ?',
        whereArgs: [color],
        orderBy: '$_colUsageCount DESC, $_colName ASC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve tags by color',
        type: DatabaseErrorType.query,
        operation: 'getByColor',
        context: {'color': color, 'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve frequently used tags
  /// 
  /// [threshold] - Minimum usage count to be considered frequently used (default: 10)
  /// [limit] - Maximum number of tags to return (optional)
  /// 
  /// Returns a list of Tag objects with usage count >= threshold, ordered by usage count.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getFrequentlyUsed({
    int threshold = 10,
    int? limit,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colUsageCount >= ?',
        whereArgs: [threshold],
        orderBy: '$_colUsageCount DESC, $_colName ASC',
        limit: limit,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve frequently used tags',
        type: DatabaseErrorType.query,
        operation: 'getFrequentlyUsed',
        context: {'threshold': threshold, 'limit': limit},
        originalError: e,
      );
    }
  }

  /// Retrieve unused tags (usage count = 0)
  /// 
  /// [limit] - Maximum number of tags to return (optional)
  /// 
  /// Returns a list of Tag objects that have never been used.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getUnused({int? limit}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colUsageCount = ?',
        whereArgs: [0],
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve unused tags',
        type: DatabaseErrorType.query,
        operation: 'getUnused',
        context: {'limit': limit},
        originalError: e,
      );
    }
  }

  /// Retrieve recently used tags
  /// 
  /// [days] - Number of days to look back (default: 7)
  /// [limit] - Maximum number of tags to return (default: 10)
  /// 
  /// Returns a list of Tag objects updated within the specified time period.
  /// Note: Uses updated_at as proxy for last_used_at until database schema is updated.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getRecentlyUsed({
    int days = 7,
    int limit = 10,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final DateTime threshold = DateTime.now().subtract(Duration(days: days));
      final String thresholdString = threshold.toIso8601String();
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colUpdatedAt >= ?',
        whereArgs: [thresholdString],
        orderBy: '$_colUpdatedAt DESC',
        limit: limit,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve recently used tags',
        type: DatabaseErrorType.query,
        operation: 'getRecentlyUsed',
        context: {'days': days, 'limit': limit},
        originalError: e,
      );
    }
  }

  /// Get count of tags by various criteria
  /// 
  /// [hasUsage] - Filter by whether tag has been used (optional)
  /// [color] - Filter by color (optional)
  /// [minUsageCount] - Minimum usage count (optional)
  /// 
  /// Returns the count of tags matching the criteria.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<int> getCount({
    bool? hasUsage,
    String? color,
    int? minUsageCount,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];
      
      if (hasUsage != null) {
        if (hasUsage) {
          whereConditions.add('$_colUsageCount > 0');
        } else {
          whereConditions.add('$_colUsageCount = 0');
        }
      }
      
      if (color != null) {
        whereConditions.add('$_colColor = ?');
        whereArgs.add(color);
      }
      
      if (minUsageCount != null) {
        whereConditions.add('$_colUsageCount >= ?');
        whereArgs.add(minUsageCount);
      }
      
      final String? whereClause = whereConditions.isNotEmpty 
          ? whereConditions.join(' AND ')
          : null;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        columns: ['COUNT(*) as count'],
        where: whereClause?.isNotEmpty == true ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );
      
      return results.first['count'] as int;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to get tag count',
        type: DatabaseErrorType.query,
        operation: 'getCount',
        context: {
          'hasUsage': hasUsage,
          'color': color,
          'minUsageCount': minUsageCount,
        },
        originalError: e,
      );
    }
  }

  /// Get all unique colors used by tags
  /// 
  /// Returns a list of hex color codes currently in use.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<String>> getUsedColors() async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        columns: ['DISTINCT $_colColor as color'],
        orderBy: '$_colColor ASC',
      );
      
      return results
          .map((row) => row['color'] as String)
          .toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve used colors',
        type: DatabaseErrorType.query,
        operation: 'getUsedColors',
        context: {},
        originalError: e,
      );
    }
  }

  /// Increment the usage count for a tag and update last used timestamp
  /// 
  /// [id] - ID of the tag to increment usage for
  /// 
  /// Returns true if the increment was successful, false if tag doesn't exist.
  /// This method should be called whenever a tag is applied to information.
  /// Throws [MindHouseDatabaseException] if update fails.
  Future<bool> incrementUsage(String id) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final DateTime now = DateTime.now();
      
      // First get current usage count
      final List<Map<String, dynamic>> current = await db.query(
        _tableName,
        columns: [_colUsageCount],
        where: '$_colId = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (current.isEmpty) {
        return false;
      }
      
      final int currentUsage = current.first[_colUsageCount] as int;
      
      final int rowsAffected = await db.update(
        _tableName,
        {
          _colUsageCount: currentUsage + 1,
          _colUpdatedAt: now.toIso8601String(),
        },
        where: '$_colId = ?',
        whereArgs: [id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to increment tag usage',
        type: DatabaseErrorType.query,
        operation: 'incrementUsage',
        context: {'tag_id': id},
        originalError: e,
      );
    }
  }

  /// Update the last used timestamp for a tag
  /// 
  /// [id] - ID of the tag to update
  /// 
  /// Note: Currently only updates updated_at timestamp until database schema includes last_used_at.
  /// Returns true if the update was successful, false if tag doesn't exist.
  /// Throws [MindHouseDatabaseException] if update fails.
  Future<bool> updateLastUsed(String id) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final DateTime now = DateTime.now();
      
      final int rowsAffected = await db.update(
        _tableName,
        {
          _colUpdatedAt: now.toIso8601String(),
        },
        where: '$_colId = ?',
        whereArgs: [id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to update tag last used timestamp',
        type: DatabaseErrorType.query,
        operation: 'updateLastUsed',
        context: {'tag_id': id},
        originalError: e,
      );
    }
  }

  /// Find a tag by its exact name (case-insensitive)
  /// 
  /// [name] - The name to search for
  /// 
  /// Returns the Tag object if found, null otherwise.
  /// Useful for preventing duplicate tag creation.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<Tag?> getByName(String name) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: 'LOWER($_colName) = LOWER(?)',
        whereArgs: [name.trim()],
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return Tag.fromJson(results.first);
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve tag by name',
        type: DatabaseErrorType.query,
        operation: 'getByName',
        context: {'name': name},
        originalError: e,
      );
    }
  }

  /// Get tag suggestions based on partial name input
  /// 
  /// [partialName] - Partial tag name to search for
  /// [limit] - Maximum number of suggestions to return (default: 5)
  /// 
  /// Returns a list of Tag objects that start with or contain the partial name,
  /// ordered by usage count to prioritize frequently used tags.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Tag>> getSuggestions(
    String partialName, {
    int limit = 5,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      if (partialName.trim().isEmpty) {
        return [];
      }
      
      final String searchPattern = '%${partialName.trim()}%';
      final String startsWithPattern = '${partialName.trim()}%';
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colName LIKE ? OR $_colName LIKE ?',
        whereArgs: [startsWithPattern, searchPattern],
        orderBy: '$_colUsageCount DESC, $_colName ASC',
        limit: limit,
      );
      
      return results.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to get tag suggestions',
        type: DatabaseErrorType.query,
        operation: 'getSuggestions',
        context: {'partialName': partialName, 'limit': limit},
        originalError: e,
      );
    }
  }
}