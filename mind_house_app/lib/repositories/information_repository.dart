import 'package:sqflite/sqflite.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/information_tag.dart';

/// Enumeration for sorting fields
enum SortField {
  createdAt,
  updatedAt,
  title,
  importance,
  accessedAt,
}

/// Enumeration for sort order
enum SortOrder {
  ascending,
  descending,
}

/// Repository class for managing Information entities in the database
/// 
/// Provides comprehensive CRUD operations, search functionality, filtering,
/// sorting, and pagination for Information objects. Follows repository pattern
/// to abstract database operations from business logic.
class InformationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  /// Table and column constants
  static const String _tableName = 'information';
  static const String _colId = 'id';
  static const String _colTitle = 'title';
  static const String _colContent = 'content';
  static const String _colType = 'type';
  static const String _colSource = 'source';
  static const String _colUrl = 'url';
  static const String _colImportance = 'importance';
  static const String _colIsFavorite = 'is_favorite';
  static const String _colIsArchived = 'is_archived';
  static const String _colCreatedAt = 'created_at';
  static const String _colUpdatedAt = 'updated_at';
  static const String _colAccessedAt = 'accessed_at';
  static const String _colMetadata = 'metadata';

  /// Create a new information item in the database
  /// 
  /// Returns the ID of the created information item.
  /// Throws [MindHouseDatabaseException] if creation fails.
  Future<String> create(Information information) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final Map<String, dynamic> data = information.toJson();
      
      await db.insert(
        _tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      return information.id;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to create information item',
        type: DatabaseErrorType.query,
        operation: 'create',
        context: {'information_id': information.id, 'title': information.title},
        originalError: e,
      );
    }
  }

  /// Retrieve an information item by its ID
  /// 
  /// Returns the Information object if found, null otherwise.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<Information?> getById(String id) async {
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
      
      return Information.fromJson(results.first);
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve information item by ID',
        type: DatabaseErrorType.query,
        operation: 'getById',
        context: {'information_id': id},
        originalError: e,
      );
    }
  }

  /// Update an existing information item
  /// 
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws [MindHouseDatabaseException] if update fails.
  Future<bool> update(Information information) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final Map<String, dynamic> data = information.toJson();
      
      final int rowsAffected = await db.update(
        _tableName,
        data,
        where: '$_colId = ?',
        whereArgs: [information.id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to update information item',
        type: DatabaseErrorType.query,
        operation: 'update',
        context: {'information_id': information.id, 'title': information.title},
        originalError: e,
      );
    }
  }

  /// Delete an information item by its ID
  /// 
  /// Returns true if the deletion was successful, false if no rows were affected.
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
        message: 'Failed to delete information item',
        type: DatabaseErrorType.query,
        operation: 'delete',
        context: {'information_id': id},
        originalError: e,
      );
    }
  }

  /// Retrieve all information items with optional pagination
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects ordered by creation date (newest first).
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getAll({int? limit, int? offset}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve all information items',
        type: DatabaseErrorType.query,
        operation: 'getAll',
        context: {'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve all information items with custom sorting
  /// 
  /// [sortBy] - Field to sort by
  /// [sortOrder] - Sort direction (ascending or descending)
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects ordered by the specified criteria.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getAllSorted({
    required SortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      String orderByColumn;
      switch (sortBy) {
        case SortField.createdAt:
          orderByColumn = _colCreatedAt;
          break;
        case SortField.updatedAt:
          orderByColumn = _colUpdatedAt;
          break;
        case SortField.title:
          orderByColumn = _colTitle;
          break;
        case SortField.importance:
          orderByColumn = _colImportance;
          break;
        case SortField.accessedAt:
          orderByColumn = _colAccessedAt;
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
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve sorted information items',
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

  /// Retrieve information items by type
  /// 
  /// [type] - The information type to filter by
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects of the specified type.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getByType(
    InformationType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colType = ?',
        whereArgs: [type.value],
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve information items by type',
        type: DatabaseErrorType.query,
        operation: 'getByType',
        context: {'type': type.value, 'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve favorite information items
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects marked as favorites.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getFavorites({int? limit, int? offset}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colIsFavorite = ?',
        whereArgs: [1],
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve favorite information items',
        type: DatabaseErrorType.query,
        operation: 'getFavorites',
        context: {'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Retrieve archived information items
  /// 
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects marked as archived.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getArchived({int? limit, int? offset}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colIsArchived = ?',
        whereArgs: [1],
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve archived information items',
        type: DatabaseErrorType.query,
        operation: 'getArchived',
        context: {'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Search information items by title and content
  /// 
  /// [query] - Search query string
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Performs case-insensitive search on title and content fields.
  /// Returns a list of Information objects matching the search criteria.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> search(
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
        where: '$_colTitle LIKE ? OR $_colContent LIKE ?',
        whereArgs: [searchPattern, searchPattern],
        orderBy: '$_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to search information items',
        type: DatabaseErrorType.query,
        operation: 'search',
        context: {'query': query, 'limit': limit, 'offset': offset},
        originalError: e,
      );
    }
  }

  /// Mark an information item as accessed
  /// 
  /// Updates the accessedAt timestamp for the specified information item.
  /// Returns true if the update was successful, false if no rows were affected.
  /// Throws [MindHouseDatabaseException] if update fails.
  Future<bool> markAsAccessed(String id) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final int rowsAffected = await db.update(
        _tableName,
        {_colAccessedAt: DateTime.now().toIso8601String()},
        where: '$_colId = ?',
        whereArgs: [id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to mark information as accessed',
        type: DatabaseErrorType.query,
        operation: 'markAsAccessed',
        context: {'information_id': id},
        originalError: e,
      );
    }
  }

  /// Get count of information items by various criteria
  /// 
  /// [type] - Filter by information type (optional)
  /// [isFavorite] - Filter by favorite status (optional)
  /// [isArchived] - Filter by archived status (optional)
  /// 
  /// Returns the count of information items matching the criteria.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<int> getCount({
    InformationType? type,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];
      
      if (type != null) {
        whereConditions.add('$_colType = ?');
        whereArgs.add(type.value);
      }
      
      if (isFavorite != null) {
        whereConditions.add('$_colIsFavorite = ?');
        whereArgs.add(isFavorite ? 1 : 0);
      }
      
      if (isArchived != null) {
        whereConditions.add('$_colIsArchived = ?');
        whereArgs.add(isArchived ? 1 : 0);
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
        message: 'Failed to get information count',
        type: DatabaseErrorType.query,
        operation: 'getCount',
        context: {
          'type': type?.value,
          'isFavorite': isFavorite,
          'isArchived': isArchived,
        },
        originalError: e,
      );
    }
  }

  /// Get recently accessed information items
  /// 
  /// [limit] - Maximum number of items to return (default: 10)
  /// 
  /// Returns a list of Information objects ordered by most recently accessed.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getRecentlyAccessed({int limit = 10}) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: '$_colAccessedAt IS NOT NULL',
        orderBy: '$_colAccessedAt DESC',
        limit: limit,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve recently accessed information items',
        type: DatabaseErrorType.query,
        operation: 'getRecentlyAccessed',
        context: {'limit': limit},
        originalError: e,
      );
    }
  }

  /// Get information items by importance level
  /// 
  /// [minImportance] - Minimum importance level (0-10)
  /// [maxImportance] - Maximum importance level (0-10, optional)
  /// [limit] - Maximum number of items to return (optional)
  /// [offset] - Number of items to skip (optional)
  /// 
  /// Returns a list of Information objects within the importance range.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getByImportance(
    int minImportance, {
    int? maxImportance,
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      String whereClause;
      List<dynamic> whereArgs;
      
      if (maxImportance != null) {
        whereClause = '$_colImportance >= ? AND $_colImportance <= ?';
        whereArgs = [minImportance, maxImportance];
      } else {
        whereClause = '$_colImportance >= ?';
        whereArgs = [minImportance];
      }
      
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: '$_colImportance DESC, $_colCreatedAt DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to retrieve information items by importance',
        type: DatabaseErrorType.query,
        operation: 'getByImportance',
        context: {
          'minImportance': minImportance,
          'maxImportance': maxImportance,
          'limit': limit,
          'offset': offset,
        },
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Tag Management Methods with Usage Count Triggers
  // ============================================================================

  /// Add tags to an information item with automatic usage count updates
  /// 
  /// [informationId] - ID of the information item
  /// [tagIds] - List of tag IDs to add
  /// 
  /// This method creates associations in the information_tags table and
  /// automatically increments the usage count for each tag.
  /// Throws [MindHouseDatabaseException] if operation fails.
  Future<void> addTags(String informationId, List<String> tagIds) async {
    if (tagIds.isEmpty) return;

    try {
      final Database db = await _databaseHelper.database;
      
      await db.transaction((txn) async {
        for (final tagId in tagIds) {
          // Verify information exists
          final infoExists = await txn.query(
            _tableName,
            where: '$_colId = ?',
            whereArgs: [informationId],
            limit: 1,
          );
          
          if (infoExists.isEmpty) {
            throw MindHouseDatabaseException(
              message: 'Information item not found',
              type: DatabaseErrorType.query,
              operation: 'addTags',
              context: {'information_id': informationId},
            );
          }

          // Verify tag exists
          final tagExists = await txn.query(
            'tags',
            where: 'id = ?',
            whereArgs: [tagId],
            limit: 1,
          );
          
          if (tagExists.isEmpty) {
            throw MindHouseDatabaseException(
              message: 'Tag not found',
              type: DatabaseErrorType.query,
              operation: 'addTags',
              context: {'tag_id': tagId},
            );
          }

          // Check if association already exists
          final existingAssociation = await txn.query(
            'information_tags',
            where: 'information_id = ? AND tag_id = ?',
            whereArgs: [informationId, tagId],
            limit: 1,
          );

          if (existingAssociation.isEmpty) {
            // Create association
            final association = InformationTag(
              informationId: informationId,
              tagId: tagId,
            );
            
            await txn.insert('information_tags', association.toJson());
            
            // Increment tag usage count
            await txn.rawUpdate(
              'UPDATE tags SET usage_count = usage_count + 1, updated_at = ? WHERE id = ?',
              [DateTime.now().toIso8601String(), tagId],
            );
          }
        }
      });
    } catch (e) {
      if (e is MindHouseDatabaseException) {
        rethrow;
      }
      throw MindHouseDatabaseException(
        message: 'Failed to add tags to information',
        type: DatabaseErrorType.query,
        operation: 'addTags',
        context: {'information_id': informationId, 'tag_ids': tagIds},
        originalError: e,
      );
    }
  }

  /// Remove tags from an information item with automatic usage count updates
  /// 
  /// [informationId] - ID of the information item
  /// [tagIds] - List of tag IDs to remove
  /// 
  /// This method removes associations from the information_tags table and
  /// automatically decrements the usage count for each tag (minimum 0).
  /// Throws [MindHouseDatabaseException] if operation fails.
  Future<void> removeTags(String informationId, List<String> tagIds) async {
    if (tagIds.isEmpty) return;

    try {
      final Database db = await _databaseHelper.database;
      
      await db.transaction((txn) async {
        for (final tagId in tagIds) {
          // Remove association if it exists
          final deletedRows = await txn.delete(
            'information_tags',
            where: 'information_id = ? AND tag_id = ?',
            whereArgs: [informationId, tagId],
          );

          // Only decrement usage count if association was actually removed
          if (deletedRows > 0) {
            // Decrement tag usage count (with minimum 0 protection)
            await txn.rawUpdate(
              'UPDATE tags SET usage_count = MAX(0, usage_count - 1), updated_at = ? WHERE id = ?',
              [DateTime.now().toIso8601String(), tagId],
            );
          }
        }
      });
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to remove tags from information',
        type: DatabaseErrorType.query,
        operation: 'removeTags',
        context: {'information_id': informationId, 'tag_ids': tagIds},
        originalError: e,
      );
    }
  }

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
  /// Throws [MindHouseDatabaseException] if operation fails.
  Future<void> updateTags(String informationId, List<String> newTagIds) async {
    try {
      final Database db = await _databaseHelper.database;
      
      await db.transaction((txn) async {
        // Get current tag associations
        final currentAssociations = await txn.query(
          'information_tags',
          columns: ['tag_id'],
          where: 'information_id = ?',
          whereArgs: [informationId],
        );
        
        final currentTagIds = currentAssociations
            .map((row) => row['tag_id'] as String)
            .toSet();
        final newTagIdsSet = newTagIds.toSet();
        
        // Find tags to remove and add
        final tagsToRemove = currentTagIds.difference(newTagIdsSet).toList();
        final tagsToAdd = newTagIdsSet.difference(currentTagIds).toList();
        
        // Remove tags that are no longer needed
        for (final tagId in tagsToRemove) {
          await txn.delete(
            'information_tags',
            where: 'information_id = ? AND tag_id = ?',
            whereArgs: [informationId, tagId],
          );
          
          // Decrement usage count
          await txn.rawUpdate(
            'UPDATE tags SET usage_count = MAX(0, usage_count - 1), updated_at = ? WHERE id = ?',
            [DateTime.now().toIso8601String(), tagId],
          );
        }
        
        // Add new tags
        for (final tagId in tagsToAdd) {
          // Verify tag exists
          final tagExists = await txn.query(
            'tags',
            where: 'id = ?',
            whereArgs: [tagId],
            limit: 1,
          );
          
          if (tagExists.isEmpty) {
            throw MindHouseDatabaseException(
              message: 'Tag not found',
              type: DatabaseErrorType.query,
              operation: 'updateTags',
              context: {'tag_id': tagId},
            );
          }
          
          // Create association
          final association = InformationTag(
            informationId: informationId,
            tagId: tagId,
          );
          
          await txn.insert('information_tags', association.toJson());
          
          // Increment usage count
          await txn.rawUpdate(
            'UPDATE tags SET usage_count = usage_count + 1, updated_at = ? WHERE id = ?',
            [DateTime.now().toIso8601String(), tagId],
          );
        }
      });
    } catch (e) {
      if (e is MindHouseDatabaseException) {
        rethrow;
      }
      throw MindHouseDatabaseException(
        message: 'Failed to update tags for information',
        type: DatabaseErrorType.query,
        operation: 'updateTags',
        context: {'information_id': informationId, 'new_tag_ids': newTagIds},
        originalError: e,
      );
    }
  }

  /// Get all tag assignments for an information item
  /// 
  /// [informationId] - ID of the information item
  /// 
  /// Returns a list of InformationTag associations for the given information.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<InformationTag>> getTagAssignments(String informationId) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        'information_tags',
        where: 'information_id = ?',
        whereArgs: [informationId],
        orderBy: 'assigned_at ASC',
      );
      
      return results.map((json) => InformationTag.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to get tag assignments for information',
        type: DatabaseErrorType.query,
        operation: 'getTagAssignments',
        context: {'information_id': informationId},
        originalError: e,
      );
    }
  }

  /// Get all tag IDs associated with an information item
  /// 
  /// [informationId] - ID of the information item
  /// 
  /// Returns a list of tag IDs associated with the information.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<String>> getTagIds(String informationId) async {
    try {
      final Database db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        'information_tags',
        columns: ['tag_id'],
        where: 'information_id = ?',
        whereArgs: [informationId],
        orderBy: 'assigned_at ASC',
      );
      
      return results.map((row) => row['tag_id'] as String).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to get tag IDs for information',
        type: DatabaseErrorType.query,
        operation: 'getTagIds',
        context: {'information_id': informationId},
        originalError: e,
      );
    }
  }

  /// Get information items by tag IDs
  /// 
  /// [tagIds] - List of tag IDs to filter by
  /// [requireAllTags] - If true, information must have ALL specified tags.
  ///                    If false, information must have AT LEAST ONE tag (default: false)
  /// [limit] - Maximum number of information items to return (optional)
  /// [offset] - Number of information items to skip (optional)
  /// 
  /// Returns information items that are associated with the specified tags.
  /// Throws [MindHouseDatabaseException] if query fails.
  Future<List<Information>> getByTagIds(
    List<String> tagIds, {
    bool requireAllTags = false,
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await _databaseHelper.database;
      
      if (tagIds.isEmpty) {
        return [];
      }
      
      final String placeholders = tagIds.map((_) => '?').join(',');
      
      String query;
      List<dynamic> args;
      
      if (requireAllTags) {
        // Information must have ALL specified tags
        query = '''
          SELECT DISTINCT i.*
          FROM $_tableName i
          INNER JOIN information_tags it ON i.id = it.information_id
          WHERE it.tag_id IN ($placeholders)
          GROUP BY i.id
          HAVING COUNT(DISTINCT it.tag_id) = ?
          ORDER BY i.updated_at DESC
        ''';
        args = [...tagIds, tagIds.length];
      } else {
        // Information must have AT LEAST ONE of the specified tags
        query = '''
          SELECT DISTINCT i.*
          FROM $_tableName i
          INNER JOIN information_tags it ON i.id = it.information_id
          WHERE it.tag_id IN ($placeholders)
          ORDER BY i.updated_at DESC
        ''';
        args = tagIds;
      }
      
      if (limit != null) {
        query += ' LIMIT $limit';
      }
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
      
      final List<Map<String, dynamic>> results = await db.rawQuery(query, args);
      
      return results.map((json) => Information.fromJson(json)).toList();
    } catch (e) {
      throw MindHouseDatabaseException(
        message: 'Failed to get information by tag IDs',
        type: DatabaseErrorType.query,
        operation: 'getByTagIds',
        context: {
          'tag_ids': tagIds,
          'require_all_tags': requireAllTags,
          'limit': limit,
          'offset': offset,
        },
        originalError: e,
      );
    }
  }
}