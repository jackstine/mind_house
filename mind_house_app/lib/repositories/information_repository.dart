import 'package:sqflite/sqflite.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/exceptions/database_exception.dart';

class InformationRepository {
  final Database _database;

  InformationRepository(this._database);

  static const String _tableName = 'information';

  /// Create a new information item
  Future<Information> create(Information information) async {
    try {
      await _database.insert(_tableName, information.toMap());
      return information;
    } catch (e) {
      throw RepositoryException('Failed to create information: $e');
    }
  }

  /// Retrieve information by ID
  Future<Information?> getById(String id) async {
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

      return Information.fromMap(results.first);
    } catch (e) {
      throw RepositoryException('Failed to get information by id: $e');
    }
  }

  /// Retrieve all information items ordered by creation date (newest first)
  Future<List<Information>> getAll() async {
    try {
      final results = await _database.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return results.map((map) => Information.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get all information: $e');
    }
  }

  /// Update an existing information item
  Future<Information> update(Information information) async {
    try {
      final rowsAffected = await _database.update(
        _tableName,
        information.toMap(),
        where: 'id = ?',
        whereArgs: [information.id],
      );

      if (rowsAffected == 0) {
        throw RepositoryException('No information found with id: ${information.id}');
      }

      return information;
    } catch (e) {
      throw RepositoryException('Failed to update information: $e');
    }
  }

  /// Delete an information item
  Future<void> delete(String id) async {
    try {
      final rowsAffected = await _database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw RepositoryException('No information found with id: $id');
      }
    } catch (e) {
      throw RepositoryException('Failed to delete information: $e');
    }
  }

  /// Search information by content (case-insensitive)
  Future<List<Information>> searchByContent(String searchTerm) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'content LIKE ?',
        whereArgs: ['%$searchTerm%'],
        orderBy: 'created_at DESC',
      );

      return results.map((map) => Information.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to search information: $e');
    }
  }

  /// Count total number of information items
  Future<int> count() async {
    try {
      final result = await _database.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to count information: $e');
    }
  }

  /// Get information items with pagination
  Future<List<Information>> getWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final results = await _database.query(
        _tableName,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      return results.map((map) => Information.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get paginated information: $e');
    }
  }

  /// Get information items created within a date range
  Future<List<Information>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = await _database.query(
        _tableName,
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'created_at DESC',
      );

      return results.map((map) => Information.fromMap(map)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get information by date range: $e');
    }
  }
}