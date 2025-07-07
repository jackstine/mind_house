import 'package:flutter/foundation.dart';

/// Application configuration and build settings
class AppConfig {
  // App information
  static const String appName = 'Mind House';
  static const String packageName = 'com.mindhouse.app';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  // Database configuration
  static const String databaseName = 'mind_house.db';
  static const int databaseVersion = 1;
  
  // Performance settings
  static const int maxCachedItems = 500;
  static const int maxSearchResults = 100;
  static const int tagSuggestionLimit = 10;
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  
  // UI configuration
  static const int maxTagsPerInformation = 50;
  static const int maxContentLength = 100000; // 100k characters
  static const int maxTagNameLength = 50;
  
  // Color configuration
  static const List<String> defaultTagColors = [
    'FF6B73', 'FF8E53', 'FF6B35', 'F7931E', 'FFD23F',
    'BFDB38', '06D6A0', '118AB2', '073B4C', '8B5CF6',
    'EC4899', 'F59E0B', '10B981', '3B82F6', '6366F1',
  ];
  
  // Feature flags
  static const bool enableAnalytics = false; // Disabled for privacy
  static const bool enableCrashReporting = false; // Disabled for privacy
  static const bool enablePerformanceMonitoring = kDebugMode;
  static const bool enableDebugLogging = kDebugMode;
  
  // Build configuration
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;
  
  // Platform configuration
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWeb => kIsWeb;
  
  // Environment-specific settings
  static String get environmentName {
    if (isDebug) return 'development';
    if (isProfile) return 'staging';
    return 'production';
  }
  
  // API configuration (for future backend integration)
  static String get baseApiUrl {
    switch (environmentName) {
      case 'development':
        return 'http://localhost:8080/api';
      case 'staging':
        return 'https://staging-api.mindhouse.app';
      case 'production':
        return 'https://api.mindhouse.app';
      default:
        return 'http://localhost:8080/api';
    }
  }
  
  // Logging configuration
  static bool get shouldLogToConsole => isDebug;
  static bool get shouldLogToFile => !isDebug;
  static bool get shouldLogNetworkRequests => isDebug;
  
  // Security configuration
  static bool get enableBiometricAuth => !isDebug; // Disabled in debug for testing
  static bool get requirePinCode => false; // Not implemented in v1
  static Duration get sessionTimeout => const Duration(hours: 24);
  
  // Storage configuration
  static int get maxLocalStorageSize => 1024 * 1024 * 1024; // 1GB
  static bool get enableAutoBackup => false; // Not implemented in v1
  static Duration get backupInterval => const Duration(days: 7);
  
  // Performance thresholds
  static Duration get maxDatabaseQueryTime => const Duration(milliseconds: 100);
  static Duration get maxUIRenderTime => const Duration(milliseconds: 16); // 60fps
  static int get maxMemoryUsageMB => 256;
  
  // App store configuration
  static Map<String, String> get appStoreMetadata => {
    'title': 'Mind House - Personal Information Manager',
    'subtitle': 'Tags-first information storage',
    'description': '''
Mind House is a simple, offline-first personal information manager that focuses on quick capture and tag-based organization.

Key Features:
• Quick information capture with rich text support
• Tag-based organization for easy retrieval
• Offline-first design - no internet required
• Clean, intuitive interface
• Fast search and filtering
• Privacy-focused - all data stays on your device

Perfect for:
• Note-taking and idea capture
• Personal knowledge management
• Quick information storage
• Tag-based organization
''',
    'keywords': 'notes,tags,personal,information,manager,offline,privacy',
    'category': 'Productivity',
    'contentRating': '4+',
  };
  
  // Build optimization settings
  static Map<String, dynamic> get buildOptimizations => {
    'enable_tree_shaking': true,
    'enable_dead_code_elimination': true,
    'enable_obfuscation': isRelease,
    'enable_split_debug_info': isRelease,
    'enable_bitcode': isIOS && isRelease,
    'enable_proguard': isAndroid && isRelease,
    'target_size_mb': 10, // Target app size
  };
  
  // Testing configuration
  static Map<String, dynamic> get testConfig => {
    'enable_integration_tests': true,
    'enable_performance_tests': true,
    'enable_accessibility_tests': true,
    'test_timeout_seconds': 30,
    'performance_threshold_ms': 100,
    'memory_threshold_mb': 50,
  };
  
  // Accessibility configuration
  static Map<String, dynamic> get accessibilityConfig => {
    'enable_screen_reader': true,
    'enable_high_contrast': true,
    'enable_large_text': true,
    'min_tap_target_size': 48.0,
    'enable_voice_control': true,
  };
  
  // Development tools configuration
  static Map<String, dynamic> get devToolsConfig => {
    'enable_inspector': isDebug,
    'enable_performance_overlay': false,
    'enable_debug_banner': isDebug,
    'enable_hot_reload': isDebug,
    'enable_timeline': isDebug,
  };
  
  // Get app info for about page
  static Map<String, String> get appInfo => {
    'name': appName,
    'version': version,
    'build': buildNumber.toString(),
    'environment': environmentName,
    'platform': defaultTargetPlatform.name,
    'dart_version': 'Dart SDK',
    'flutter_version': 'Flutter SDK',
  };
  
  // Validate configuration
  static List<String> validateConfig() {
    final errors = <String>[];
    
    if (appName.isEmpty) {
      errors.add('App name cannot be empty');
    }
    
    if (packageName.isEmpty || !packageName.contains('.')) {
      errors.add('Invalid package name format');
    }
    
    if (version.isEmpty) {
      errors.add('Version cannot be empty');
    }
    
    if (buildNumber <= 0) {
      errors.add('Build number must be positive');
    }
    
    if (maxContentLength <= 0) {
      errors.add('Max content length must be positive');
    }
    
    if (defaultTagColors.isEmpty) {
      errors.add('Default tag colors cannot be empty');
    }
    
    return errors;
  }
  
  // Initialize configuration
  static Future<void> initialize() async {
    final errors = validateConfig();
    if (errors.isNotEmpty) {
      throw Exception('Configuration validation failed: ${errors.join(', ')}');
    }
    
    if (shouldLogToConsole) {
      print('AppConfig initialized for $environmentName environment');
      print('Platform: ${defaultTargetPlatform.name}');
      print('Version: $version ($buildNumber)');
    }
  }
}

// Import required for TargetPlatform
import 'package:flutter/material.dart';