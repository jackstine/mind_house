/// Test configuration and constants for the Mind House application
class TestConfig {
  // Test database configuration
  static const String testDatabaseName = ':memory:';
  static const int testDatabaseVersion = 1;
  
  // Performance test thresholds
  static const Duration maxDatabaseInsertTime = Duration(milliseconds: 100);
  static const Duration maxDatabaseQueryTime = Duration(milliseconds: 50);
  static const Duration maxWidgetBuildTime = Duration(milliseconds: 16); // 60fps
  static const Duration maxNavigationTime = Duration(milliseconds: 300);
  
  // Stress test parameters
  static const int stressTestInformationCount = 1000;
  static const int stressTestTagCount = 500;
  static const int stressTestAssociationCount = 2000;
  
  // UI test parameters
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(seconds: 1);
  static const Duration testTimeout = Duration(seconds: 30);
  
  // Accessibility test parameters
  static const double minimumTapTargetSize = 48.0;
  static const double minimumContrastRatio = 4.5;
  
  // Memory test thresholds (in bytes)
  static const int maxMemoryUsage = 100 * 1024 * 1024; // 100MB
  static const int maxHeapSize = 50 * 1024 * 1024; // 50MB
  
  // Test data limits
  static const int maxContentLength = 10000;
  static const int maxTagNameLength = 50;
  static const int maxTagCount = 100;
  
  // Integration test configuration
  static const String integrationTestGroup = 'integration_tests';
  static const String performanceTestGroup = 'performance_tests';
  static const String accessibilityTestGroup = 'accessibility_tests';
  
  // Screenshot test configuration
  static const String screenshotDirectory = 'test/screenshots';
  static const String screenshotFormat = 'png';
  
  // Coverage configuration
  static const double minimumCoverageThreshold = 80.0;
  
  // Test environment variables
  static const Map<String, String> testEnvironment = {
    'FLUTTER_TEST': 'true',
    'TESTING_MODE': 'true',
  };
  
  // Test delays and timeouts
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);
  
  // Widget test finders
  static const String saveButtonKey = 'save_button';
  static const String contentInputKey = 'content_input';
  static const String tagInputKey = 'tag_input';
  static const String tagChipKey = 'tag_chip';
  static const String searchButtonKey = 'search_button';
  
  // Test routes
  static const String storeInformationRoute = '/store';
  static const String informationRoute = '/information';
  static const String listInformationRoute = '/list';
}