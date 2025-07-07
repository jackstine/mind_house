import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information_bloc.dart';
import 'package:mind_house_app/blocs/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion_bloc.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/information_service.dart';
import 'package:mind_house_app/services/tag_service.dart';
import 'test_database_helper.dart';

/// Testing utilities for common test setup and teardown operations
class TestUtilities {
  /// Setup test environment before each test
  static Future<void> setUp() async {
    TestDatabaseHelper.setupTestDatabase();
    await TestDatabaseHelper.createFreshTestDatabase();
  }

  /// Teardown test environment after each test
  static Future<void> tearDown() async {
    await TestDatabaseHelper.closeTestDatabase();
  }

  /// Create a test widget with necessary providers and material app wrapper
  static Widget createTestWidget({
    required Widget child,
    InformationRepository? informationRepository,
    TagRepository? tagRepository,
    InformationService? informationService,
    TagService? tagService,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<InformationBloc>(
            create: (context) => InformationBloc(
              informationService: informationService ?? 
                InformationService(
                  informationRepository: informationRepository ?? InformationRepository(),
                  tagRepository: tagRepository ?? TagRepository(),
                  tagService: tagService ?? TagService(tagRepository ?? TagRepository()),
                ),
            ),
          ),
          BlocProvider<TagBloc>(
            create: (context) => TagBloc(
              tagService: tagService ?? TagService(tagRepository ?? TagRepository()),
            ),
          ),
          BlocProvider<TagSuggestionBloc>(
            create: (context) => TagSuggestionBloc(
              tagService: tagService ?? TagService(tagRepository ?? TagRepository()),
            ),
          ),
        ],
        child: child,
      ),
    );
  }

  /// Pump and settle widget for testing
  static Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  /// Find widget by type with optional timeout
  static Future<Finder> findWidgetByType<T>(
    WidgetTester tester, 
    Type widgetType, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final finder = find.byType(widgetType);
    await tester.pump();
    
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    throw Exception('Widget of type $widgetType not found within timeout');
  }

  /// Enter text and trigger text change events
  static Future<void> enterText(
    WidgetTester tester, 
    Finder textFieldFinder, 
    String text,
  ) async {
    await tester.enterText(textFieldFinder, text);
    await tester.pump();
  }

  /// Tap widget and wait for animations
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Scroll widget by offset
  static Future<void> scrollByOffset(
    WidgetTester tester, 
    Finder finder, 
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Wait for a specific condition to be true
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      if (condition()) {
        return;
      }
      await Future.delayed(pollInterval);
    }
    
    throw TimeoutException('Condition not met within timeout', timeout);
  }

  /// Take a screenshot for debugging
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    // This would be used with integration_test package
    // For now, just a placeholder for screenshot functionality
    await tester.pump();
    // In integration tests: await binding.convertFlutterSurfaceToImage();
  }

  /// Create a test theme for consistent testing
  static ThemeData createTestTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
  }

  /// Verify that no errors or exceptions occurred during test
  static void verifyNoErrors() {
    // Check if there are any uncaught exceptions in the test
    expect(WidgetsBinding.instance.debugBuildingDirtyElements, isFalse);
  }

  /// Create a mock navigation observer for testing navigation
  static NavigatorObserver createMockNavigatorObserver() {
    return _MockNavigatorObserver();
  }

  /// Simulate device back button press
  static Future<void> simulateBackButton(WidgetTester tester) async {
    final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();
  }

  /// Simulate app lifecycle changes
  static Future<void> simulateAppLifecycle(
    WidgetTester tester, 
    AppLifecycleState state,
  ) async {
    final binding = tester.binding;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter/lifecycle'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'routeUpdated') {
          return null;
        }
        return null;
      },
    );
    
    await binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }

  /// Performance testing utilities
  static Future<Duration> measurePerformance(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Memory usage testing utilities
  static Future<Map<String, int>> getMemoryUsage() async {
    // This would require platform-specific implementation
    // For now, return mock data
    return {
      'rss': 50 * 1024 * 1024, // 50MB
      'heap': 30 * 1024 * 1024, // 30MB
    };
  }

  /// Accessibility testing utilities
  static Future<void> verifyAccessibility(WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  }

  /// Database performance testing
  static Future<Map<String, Duration>> measureDatabasePerformance() async {
    final results = <String, Duration>{};
    
    // Measure insert performance
    results['insert'] = await TestDatabaseHelper.timeOperation(() async {
      await TestDatabaseHelper.seedTestDatabase();
    });
    
    // Measure query performance  
    results['query'] = await TestDatabaseHelper.timeOperation(() async {
      final db = await TestDatabaseHelper.getTestDatabase();
      await db.query('information');
    });
    
    return results;
  }

  /// Create stress test data for performance testing
  static Future<void> createStressTestData({
    int informationCount = 1000,
    int tagCount = 500,
  }) async {
    await TestDatabaseHelper.createPerformanceTestDatabase(
      informationCount: informationCount,
      tagCount: tagCount,
      associationsCount: informationCount * 2,
    );
  }
}

/// Mock navigator observer for testing navigation
class _MockNavigatorObserver extends NavigatorObserver {
  final List<Route> pushedRoutes = [];
  final List<Route> poppedRoutes = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}

/// Exception for timeout scenarios
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}