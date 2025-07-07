import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Performance optimization utilities for Mind House application
class PerformanceOptimizer {
  static const int _defaultBatchSize = 100;
  static const int _maxCacheSize = 500;
  
  // Cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static final List<String> _cacheKeys = [];

  /// Optimize database queries with indexing
  static Future<void> optimizeDatabaseIndexes(Database db) async {
    try {
      // Create indexes for frequently queried columns
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_created_at 
        ON information(created_at DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_updated_at 
        ON information(updated_at DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_is_deleted 
        ON information(is_deleted)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_name 
        ON tags(name)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_usage_count 
        ON tags(usage_count DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_last_used_at 
        ON tags(last_used_at DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_info_id 
        ON information_tags(information_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_tag_id 
        ON information_tags(tag_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_information_tags_composite 
        ON information_tags(information_id, tag_id)
      ''');

      if (kDebugMode) {
        print('Database indexes optimized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error optimizing database indexes: $e');
      }
    }
  }

  /// Batch insert operations for better performance
  static Future<List<T>> batchInsert<T>(
    Database db,
    String table,
    List<Map<String, dynamic>> records,
    T Function(Map<String, dynamic>) fromMap, {
    int batchSize = _defaultBatchSize,
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < records.length; i += batchSize) {
      final batch = db.batch();
      final endIndex = (i + batchSize < records.length) ? i + batchSize : records.length;
      
      for (int j = i; j < endIndex; j++) {
        batch.insert(table, records[j]);
      }
      
      final batchResults = await batch.commit();
      
      // Convert results back to objects
      for (int j = i; j < endIndex; j++) {
        results.add(fromMap(records[j]));
      }
    }
    
    return results;
  }

  /// Optimize query performance with pagination
  static Future<List<Map<String, dynamic>>> getPaginatedResults(
    Database db,
    String query,
    List<dynamic> arguments, {
    int offset = 0,
    int limit = 50,
  }) async {
    final paginatedQuery = '$query LIMIT $limit OFFSET $offset';
    return await db.rawQuery(paginatedQuery, arguments);
  }

  /// Cache frequently accessed data
  static void cacheData(String key, dynamic data) {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entries
      final oldestKey = _cacheKeys.removeAt(0);
      _cache.remove(oldestKey);
    }
    
    _cache[key] = data;
    _cacheKeys.add(key);
  }

  /// Retrieve cached data
  static T? getCachedData<T>(String key) {
    final data = _cache[key];
    if (data != null) {
      // Move to end (most recently used)
      _cacheKeys.remove(key);
      _cacheKeys.add(key);
      return data as T;
    }
    return null;
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
    _cacheKeys.clear();
  }

  /// Clear specific cache entry
  static void clearCacheEntry(String key) {
    _cache.remove(key);
    _cacheKeys.remove(key);
  }

  /// Optimize tag suggestions query
  static Future<List<Map<String, dynamic>>> getOptimizedTagSuggestions(
    Database db,
    String prefix, {
    int limit = 10,
  }) async {
    // Use cache for common prefixes
    final cacheKey = 'tag_suggestions_${prefix}_$limit';
    final cached = getCachedData<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Optimized query with proper indexing
    final results = await db.rawQuery('''
      SELECT * FROM tags 
      WHERE name LIKE ? 
      ORDER BY usage_count DESC, last_used_at DESC 
      LIMIT ?
    ''', ['$prefix%', limit]);

    // Cache results for 5 minutes worth of operations
    cacheData(cacheKey, results);
    
    return results;
  }

  /// Optimize information search by tags
  static Future<List<Map<String, dynamic>>> getOptimizedInformationByTags(
    Database db,
    List<String> tagNames,
  ) async {
    if (tagNames.isEmpty) {
      return await db.rawQuery('''
        SELECT * FROM information 
        WHERE is_deleted = 0 
        ORDER BY updated_at DESC
      ''');
    }

    // Use cache for common tag combinations
    final cacheKey = 'info_by_tags_${tagNames.join('_')}';
    final cached = getCachedData<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Optimized query using EXISTS for better performance
    final placeholders = List.filled(tagNames.length, '?').join(',');
    final results = await db.rawQuery('''
      SELECT DISTINCT i.* 
      FROM information i
      WHERE i.is_deleted = 0
        AND EXISTS (
          SELECT 1 FROM information_tags it
          JOIN tags t ON it.tag_id = t.id
          WHERE it.information_id = i.id
            AND t.name IN ($placeholders)
        )
      ORDER BY i.updated_at DESC
    ''', tagNames);

    cacheData(cacheKey, results);
    return results;
  }

  /// Optimize database maintenance operations
  static Future<void> performDatabaseMaintenance(Database db) async {
    try {
      // Analyze tables for query optimization
      await db.execute('ANALYZE');
      
      // Vacuum to reclaim space and defragment
      await db.execute('VACUUM');
      
      // Update statistics
      await db.execute('PRAGMA optimize');

      if (kDebugMode) {
        print('Database maintenance completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during database maintenance: $e');
      }
    }
  }

  /// Monitor query performance
  static Future<T> measureQueryPerformance<T>(
    String queryName,
    Future<T> Function() query,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await query();
      stopwatch.stop();
      
      if (kDebugMode) {
        print('Query "$queryName" took ${stopwatch.elapsedMilliseconds}ms');
      }
      
      // Log slow queries
      if (stopwatch.elapsedMilliseconds > 100) {
        if (kDebugMode) {
          print('SLOW QUERY WARNING: "$queryName" took ${stopwatch.elapsedMilliseconds}ms');
        }
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('Query "$queryName" failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Optimize memory usage by limiting result sets
  static List<T> limitResults<T>(List<T> results, {int maxResults = 1000}) {
    if (results.length <= maxResults) {
      return results;
    }
    
    if (kDebugMode) {
      print('Limiting results from ${results.length} to $maxResults for memory optimization');
    }
    
    return results.take(maxResults).toList();
  }

  /// Debounce function calls to improve performance
  static Timer? _debounceTimer;
  
  static void debounce(
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleTime;
  
  static bool throttle(Duration interval) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      return true;
    }
    return false;
  }

  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'cache_size': _cache.length,
      'max_cache_size': _maxCacheSize,
      'cache_hit_ratio': _calculateCacheHitRatio(),
      'memory_usage': _getApproximateMemoryUsage(),
    };
  }

  /// Calculate cache hit ratio (simplified)
  static double _calculateCacheHitRatio() {
    // This would require tracking hits/misses in a real implementation
    return _cache.isNotEmpty ? 0.8 : 0.0; // Placeholder
  }

  /// Get approximate memory usage of cache
  static int _getApproximateMemoryUsage() {
    // Rough estimation - would need more sophisticated calculation in production
    return _cache.length * 1024; // Approximate 1KB per cached item
  }

  /// Cleanup resources
  static void dispose() {
    clearCache();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastThrottleTime = null;
  }
}

/// Timer import for debouncing
import 'dart:async';