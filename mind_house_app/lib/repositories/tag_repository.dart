import 'package:sqflite/sqflite.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/exceptions/database_exception.dart';

class TagRepository {
  final Database _database;

  TagRepository(this._database);

  static const String _tableName = 'tags';

  /// Create a new tag
  Future<Tag> create(Tag tag) async {
    try {
      final id = await _database.insert(_tableName, tag.toMap());
      return tag.copyWith(id: id);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw RepositoryException('Tag with name "${tag.name}" already exists');
      }
      throw RepositoryException('Failed to create tag: $e');
    }
  }

  /// Retrieve tag by ID
  Future<Tag?> getById(int id) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return Tag.fromMap(results.first);
    } catch (e) {
      throw RepositoryException('Failed to get tag by id: $e');
    }
  }

  /// Retrieve all tags ordered by usage count (most used first)
  Future<List<Tag>> getAll() async {
    try {
      final results = await _database.query(
        _tableName,
        orderBy: 'usage_count DESC, name ASC',
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get all tags: $e');
    }
  }

  /// Update an existing tag
  Future<Tag> update(Tag tag) async {
    try {
      final rowsAffected = await _database.update(
        _tableName,
        tag.toMap(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );

      if (rowsAffected == 0) {
        throw RepositoryException('No tag found with id: ${tag.id}');
      }

      return tag;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw RepositoryException('Tag with name "${tag.name}" already exists');
      }
      throw RepositoryException('Failed to update tag: $e');
    }
  }

  /// Delete a tag
  Future<void> delete(int id) async {
    try {
      final rowsAffected = await _database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw RepositoryException('No tag found with id: $id');
      }
    } catch (e) {
      throw RepositoryException('Failed to delete tag: $e');
    }
  }

  /// Find tag by name (case-insensitive)
  Future<Tag?> findByName(String name) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [name],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return Tag.fromMap(results.first);
    } catch (e) {
      throw RepositoryException('Failed to find tag by name: $e');
    }
  }

  /// Get tag suggestions based on prefix (for autocomplete)
  Future<List<Tag>> getSuggestions(String prefix, {int limit = 10}) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'LOWER(name) LIKE LOWER(?)',
        whereArgs: ['$prefix%'],
        orderBy: 'usage_count DESC, name ASC',
        limit: limit,
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get tag suggestions: $e');
    }
  }

  /// Increment usage count for a tag
  Future<void> incrementUsageCount(int tagId) async {
    try {
      await _database.rawUpdate(
        'UPDATE $_tableName SET usage_count = usage_count + 1 WHERE id = ?',
        [tagId],
      );
    } catch (e) {
      throw RepositoryException('Failed to increment usage count: $e');
    }
  }

  /// Get most used tags
  Future<List<Tag>> getMostUsed({int limit = 10}) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'usage_count > 0',
        orderBy: 'usage_count DESC, name ASC',
        limit: limit,
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get most used tags: $e');
    }
  }

  /// Get unused tags (usage_count = 0)
  Future<List<Tag>> getUnused() async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'usage_count = 0',
        orderBy: 'name ASC',
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get unused tags: $e');
    }
  }

  /// Count total number of tags
  Future<int> count() async {
    try {
      final result = await _database.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to count tags: $e');
    }
  }

  /// Search tags by name pattern
  Future<List<Tag>> searchByName(String searchTerm) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$searchTerm%'],
        orderBy: 'usage_count DESC, name ASC',
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to search tags: $e');
    }
  }

  /// Get tags by color
  Future<List<Tag>> getByColor(String color) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'color = ?',
        whereArgs: [color],
        orderBy: 'usage_count DESC, name ASC',
      );

      return results.map((map) => Tag.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get tags by color: $e');
    }
  }

  /// Bulk increment usage counts for multiple tags
  Future<void> bulkIncrementUsage(List<int> tagIds) async {
    try {
      final batch = _database.batch();
      for (final tagId in tagIds) {
        batch.rawUpdate(
          'UPDATE $_tableName SET usage_count = usage_count + 1 WHERE id = ?',
          [tagId],
        );
      }
      await batch.commit();
    } catch (e) {
      throw RepositoryException('Failed to bulk increment usage: $e');
    }
  }
}