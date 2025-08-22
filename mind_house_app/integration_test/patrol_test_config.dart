import 'dart:async';
import 'package:patrol/patrol.dart';

/// Patrol test configuration
/// 
/// This file configures the Patrol testing environment for the Mind House app.
/// It provides common setup, utilities, and configuration for all Patrol tests.

// Configure Patrol binding
void setupPatrolBinding() {
  patrolSetUp(() async {
    // Any global setup before tests run
    print('🚀 Starting Patrol tests for Mind House app');
  });

  patrolTearDown(() async {
    // Any global cleanup after tests complete
    print('✅ Patrol tests completed');
  });
}

// Test configuration constants
class PatrolTestConfig {
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration navigationTimeout = Duration(seconds: 5);
  static const Duration animationTimeout = Duration(milliseconds: 500);
  
  // Test data
  static const String testContent = 'Patrol test content';
  static const List<String> testTags = ['test', 'patrol', 'automated'];
  
  // Platform-specific settings
  static const bool takeScreenshots = true;
  static const bool enableDebugLogging = true;
}

// Common test utilities
extension PatrolTestUtils on PatrolTester {
  /// Navigate to a specific tab by name
  Future<void> navigateToTab(String tabName) async {
    await $(tabName).tap();
    await pumpAndSettle();
  }
  
  /// Enter text in a specific text field by index
  Future<void> enterTextInField(int fieldIndex, String text) async {
    final fields = $(TextField);
    if (fields.length > fieldIndex) {
      await fields.at(fieldIndex).enterText(text);
      await pumpAndSettle();
    }
  }
  
  /// Take a screenshot if enabled
  Future<void> takeScreenshotIfEnabled(String name) async {
    if (PatrolTestConfig.takeScreenshots) {
      // Note: Screenshot functionality requires additional setup
      // await takeScreenshot(name: name);
      print('📸 Would take screenshot: $name');
    }
  }
  
  /// Verify page navigation
  Future<void> verifyOnPage(String pageName) async {
    expect($(pageName), findsAtLeastNWidget(1));
  }
  
  /// Quick navigation through all tabs
  Future<void> navigateThroughAllTabs() async {
    await navigateToTab('List Information');
    await verifyOnPage('List Information');
    
    await navigateToTab('Information');
    await verifyOnPage('Information');
    
    await navigateToTab('Store Information');
    await verifyOnPage('Store Information');
  }
}

// Test data generators
class TestDataGenerator {
  static int _counter = 0;
  
  static String generateUniqueContent() {
    _counter++;
    return 'Test content #$_counter - Generated at ${DateTime.now()}';
  }
  
  static List<String> generateTags(int count) {
    return List.generate(count, (i) => 'tag${_counter}_$i');
  }
}

// Custom matchers for Mind House app
class MindHouseMatchers {
  static Finder findInformationCard(String content) {
    return find.text(content);
  }
  
  static Finder findTagChip(String tagName) {
    return find.text(tagName);
  }
  
  static Finder findSaveButton() {
    return find.text('Save');
  }
}