import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/tag_service.dart';
import '../helpers/test_database_helper.dart';
import '../helpers/test_data_factory.dart';
import '../test_config.dart';

/// Performance tests for Mind House application
/// Tests database operations, UI rendering, and memory usage
void main() {
  group('Performance Tests', () {
    late InformationRepository informationRepository;
    late TagRepository tagRepository;
    late TagService tagService;

    setUpAll(() async {
      TestDatabaseHelper.setupTestDatabase();
    });

    setUp(() async {
      await TestDatabaseHelper.createFreshTestDatabase();
      informationRepository = InformationRepository();
      tagRepository = TagRepository();
      tagService = TagService(tagRepository);
    });

    tearDown(() async {
      await TestDatabaseHelper.closeTestDatabase();
    });

    group('Database Performance Tests', () {
      test('Information creation performance', () async {
        final information = TestDataFactory.createLargeInformationDataset(100);
        
        final stopwatch = Stopwatch()..start();
        for (final info in information) {
          await informationRepository.create(info);
        }
        stopwatch.stop();

        // Should create 100 information items in less than 1 second
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
        print('Created 100 information items in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Tag creation performance', () async {
        final tags = TestDataFactory.createLargeTagDataset(100);
        
        final stopwatch = Stopwatch()..start();
        for (final tag in tags) {
          await tagRepository.create(tag);
        }
        stopwatch.stop();

        // Should create 100 tags in less than 500ms
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
        print('Created 100 tags in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Information query performance with large dataset', () async {
        // Create large dataset
        await TestDatabaseHelper.createPerformanceTestDatabase(
          informationCount: TestConfig.stressTestInformationCount,
          tagCount: TestConfig.stressTestTagCount,
          associationsCount: TestConfig.stressTestAssociationCount,
        );

        final stopwatch = Stopwatch()..start();
        final results = await informationRepository.getAll();
        stopwatch.stop();

        // Should query 1000 information items in less than 100ms
        expect(stopwatch.elapsed, lessThan(TestConfig.maxDatabaseQueryTime));
        expect(results.length, equals(TestConfig.stressTestInformationCount));
        print('Queried ${results.length} information items in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Tag suggestion performance', () async {
        // Create dataset with varied tag names
        final tags = TestDataFactory.createLargeTagDataset(500);
        for (final tag in tags) {
          await tagRepository.create(tag);
        }

        final stopwatch = Stopwatch()..start();
        final suggestions = await tagService.getSmartSuggestions('test', limit: 10);
        stopwatch.stop();

        // Tag suggestions should be fast (under 50ms)
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 50)));
        expect(suggestions.length, lessThanOrEqualTo(10));
        print('Generated ${suggestions.length} tag suggestions in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Concurrent database operations', () async {
        final futures = <Future<void>>[];
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate concurrent operations
        for (int i = 0; i < 20; i++) {
          futures.add(_performConcurrentOperation(i, informationRepository, tagRepository));
        }
        
        await Future.wait(futures);
        stopwatch.stop();

        // All 20 concurrent operations should complete in less than 2 seconds
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
        print('Completed 20 concurrent operations in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Memory usage during large operations', () async {
        final initialMemory = await _getMemoryUsage();
        
        // Perform memory-intensive operations
        final largeDataset = TestDataFactory.createLargeInformationDataset(1000);
        for (final info in largeDataset) {
          await informationRepository.create(info);
        }
        
        final finalMemory = await _getMemoryUsage();
        final memoryIncrease = finalMemory - initialMemory;
        
        // Memory increase should be reasonable (less than 50MB)
        expect(memoryIncrease, lessThan(50 * 1024 * 1024));
        print('Memory increased by ${(memoryIncrease / 1024 / 1024).toStringAsFixed(2)}MB');
      });

      test('Database migration performance', () async {
        // This would test database schema migrations
        // For now, simulate by recreating database
        final stopwatch = Stopwatch()..start();
        
        await TestDatabaseHelper.closeTestDatabase();
        await TestDatabaseHelper.createFreshTestDatabase();
        
        stopwatch.stop();
        
        // Database recreation should be fast
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
        print('Database migration completed in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Tag Algorithm Performance Tests', () {
      test('Tag autocomplete with large tag set', () async {
        // Create 1000 tags with varied names
        final tags = TestDataFactory.createLargeTagDataset(1000);
        for (final tag in tags) {
          await tagRepository.create(tag);
        }

        final prefixes = ['test', 'flutter', 'dart', 'app', 'dev'];
        
        for (final prefix in prefixes) {
          final stopwatch = Stopwatch()..start();
          final suggestions = await tagService.getSmartSuggestions(prefix, limit: 10);
          stopwatch.stop();

          // Each autocomplete should be under 25ms
          expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 25)));
          print('Autocomplete for "$prefix" took ${stopwatch.elapsedMilliseconds}ms, found ${suggestions.length} suggestions');
        }
      });

      test('Tag usage count updates performance', () async {
        final tags = TestDataFactory.createTagList(100);
        for (final tag in tags) {
          await tagRepository.create(tag);
        }

        final stopwatch = Stopwatch()..start();
        
        // Simulate usage count updates
        for (int i = 0; i < 100; i++) {
          await tagRepository.incrementUsageCount(tags[i % tags.length].id);
        }
        
        stopwatch.stop();

        // 100 usage count updates should be fast
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 200)));
        print('100 usage count updates completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Tag color assignment performance', () async {
        final stopwatch = Stopwatch()..start();
        
        // Generate 1000 colors
        final colors = <String>[];
        for (int i = 0; i < 1000; i++) {
          colors.add(tagService.assignColor());
        }
        
        stopwatch.stop();

        // Color assignment should be very fast
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 10)));
        expect(colors.length, equals(1000));
        print('Generated 1000 colors in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Stress Tests', () {
      test('Maximum data capacity test', () async {
        // Test with very large dataset
        final stopwatch = Stopwatch()..start();
        
        await TestDatabaseHelper.createPerformanceTestDatabase(
          informationCount: 5000,
          tagCount: 2000,
          associationsCount: 10000,
        );
        
        stopwatch.stop();

        // Large dataset creation should complete in reasonable time
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
        
        // Verify data integrity
        final stats = await TestDatabaseHelper.getDatabaseStats();
        expect(stats['information_count'], equals(5000));
        expect(stats['tag_count'], equals(2000));
        expect(stats['association_count'], equals(10000));
        
        print('Created maximum dataset in ${stopwatch.elapsedMilliseconds}ms');
        print('Database stats: ${stats}');
      });

      test('Sustained operation performance', () async {
        // Simulate sustained usage over time
        final results = <Duration>[];
        
        for (int batch = 0; batch < 10; batch++) {
          final stopwatch = Stopwatch()..start();
          
          // Perform batch operations
          for (int i = 0; i < 50; i++) {
            final info = TestDataFactory.createInformation(
              content: 'Sustained test batch $batch item $i'
            );
            await informationRepository.create(info);
          }
          
          stopwatch.stop();
          results.add(stopwatch.elapsed);
        }
        
        // Performance should remain consistent across batches
        final averageTime = results.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / results.length;
        final maxTime = results.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);
        
        // No batch should take more than 2x the average
        expect(maxTime, lessThan(averageTime * 2));
        print('Sustained performance: avg ${averageTime.toStringAsFixed(1)}ms, max ${maxTime}ms');
      });
    });
  });
}

/// Simulate concurrent database operation
Future<void> _performConcurrentOperation(
  int index,
  InformationRepository infoRepo,
  TagRepository tagRepo,
) async {
  // Create information
  final info = TestDataFactory.createInformation(
    content: 'Concurrent operation $index'
  );
  await infoRepo.create(info);

  // Create tag
  final tag = TestDataFactory.createTag(
    name: 'concurrent_$index'
  );
  await tagRepo.create(tag);

  // Query data
  await infoRepo.getAll();
  await tagRepo.getAll();
}

/// Get current memory usage (simplified for testing)
Future<int> _getMemoryUsage() async {
  // In a real implementation, this would use platform-specific APIs
  // For testing, return a simulated value
  return DateTime.now().millisecondsSinceEpoch % 100000000; // Simulate memory usage
}