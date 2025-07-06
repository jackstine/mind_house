# Local Development and Testing Design Document

## Overview
This document outlines the local development setup for the Mind Map Flutter application on macOS, covering Android and iOS development, testing strategies, and app size optimization considerations.

## Local Development Environment Setup

### macOS Development Requirements

#### For iOS Development
**Link**: https://docs.flutter.dev/platform-integration/ios/setup
- **Xcode Required**: Mac with Xcode is essential for iOS app testing on device or simulator
- **Apple ID Setup**: 
  - Open Xcode → Preferences → Accounts
  - Sign in with Apple ID (or Developer Account)
  - Manage Certificates → Click "+" → Select "iOS Development"
- **Device Testing**: Real iPhone testing requires code signing through Xcode

#### For Android Development  
**Link**: https://docs.flutter.dev/get-started/install/macos
- **Android Studio**: Install Android Studio with Flutter plugin
- **Android SDK**: Configure Android SDK path in Flutter
- **Physical Device Setup**:
  - Enable Developer Options (tap Build number 7 times)
  - Enable USB Debugging in Developer Options
  - Connect via USB and authorize computer

### Development Workflow

#### Hot Reload and Hot Restart
**Link**: https://docs.flutter.dev/tools/hot-reload
- **Hot Reload**: Updates UI instantly without losing app state
- **Hot Restart**: Recompiles and reloads entire app, resetting state
- **Commands**: 
  - `flutter run` for initial launch
  - `r` key for hot reload during development
  - `R` key for hot restart

#### Device Testing Commands
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d "<device_id>"
flutter run -d "<device_name>"

# Run on iOS simulator
flutter run -d "iPhone 15 Pro"

# Run on Android emulator
flutter run -d "Android SDK built for x86_64"
```

## Testing Strategy

### Testing Framework Architecture
**Link**: https://docs.flutter.dev/testing

Flutter provides three types of testing:
1. **Unit Tests**: Test individual functions, methods, classes
2. **Widget Tests**: Test individual widgets in isolation
3. **Integration Tests**: Test complete app or large parts

### BDD Testing Libraries

#### Core BDD Frameworks
**bdd_widget_test**: https://pub.dev/packages/bdd_widget_test
- BDD-style widget testing library
- Generates Flutter widget tests from *.feature files
- Gherkin syntax support

**gherkin**: https://pub.dev/packages/gherkin
- Gherkin parser and runner for Dart
- Similar to Cucumber for other platforms
- Platform-agnostic BDD functionality

**given_when_then_unit_test**: https://pub.dev/packages/given_when_then_unit_test
- BDD framework for Dart/Flutter
- Create BDD tests in code with readable error messages
- Exports to Gherkin/Cucumber feature files

**shouldly**: https://pub.dev/packages/shouldly
- Simple, extensible BDD assertion library
- Focuses on great error messages when assertions fail

### Snapshot Testing

#### Approval Testing
**approval_tests**: https://pub.dev/packages/approval_tests
- Approval Tests implementation in Dart
- Snapshot testing capabilities for Flutter applications
- Compare current output with previously approved versions

#### Golden File Testing (Built-in)
```dart
// Flutter's built-in golden file testing
testWidgets('Golden test for tag input widget', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  await expectLater(
    find.byType(TagInputWidget),
    matchesGoldenFile('tag_input_widget.png'),
  );
});
```

### Integration Testing Setup

#### End-to-End Testing
**Link**: https://docs.flutter.dev/testing/integration-tests

```dart
// Example integration test for our app
void main() {
  group('Mind Map App Integration Tests', () {
    testWidgets('Create and search for information with tags', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test tag input and information creation
      await tester.enterText(find.byKey(Key('content_input')), 'Test information');
      await tester.enterText(find.byKey(Key('tag_input')), 'work project');
      await tester.tap(find.byKey(Key('save_button')));
      await tester.pumpAndSettle();
      
      // Test navigation to list page
      await tester.tap(find.byKey(Key('list_page_tab')));
      await tester.pumpAndSettle();
      
      // Test tag filtering
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();
      
      // Verify filtered results
      expect(find.text('Test information'), findsOneWidget);
    });
  });
}
```

### Testing Best Practices for Tag-Based App

#### Tag Component Testing
```dart
// Example widget test for tag input component
testWidgets('Tag input shows suggestions', (WidgetTester tester) async {
  await tester.pumpWidget(TagInputWidget(
    suggestions: ['work', 'personal', 'project'],
  ));
  
  await tester.enterText(find.byType(TextField), 'w');
  await tester.pump();
  
  expect(find.text('work'), findsOneWidget);
  expect(find.text('personal'), findsNothing);
});
```

#### Database Testing
```dart
// Example test for SQLite operations
test('Tag database operations', () async {
  final database = await openTestDatabase();
  final tagRepo = TagRepository(database);
  
  // Test tag creation
  final tag = await tagRepo.createTag('test-tag');
  expect(tag.name, 'test-tag');
  
  // Test tag suggestions
  final suggestions = await tagRepo.getSuggestions('te');
  expect(suggestions, contains('test-tag'));
});
```

## App Size Optimization

### Current Flutter App Sizes (2025)
**Link**: https://docs.flutter.dev/perf/app-size

- **Typical Download Size**: ~5.4 MB
- **Typical Installation Size**: ~13.7 MB on iOS
- **Android Release Builds**: ~7-8 MB
- **iOS Builds**: Can be significantly larger (up to 83.7 MB for same app)

### Size Optimization Strategies

#### Build Configuration Optimization
```bash
# Android App Bundle (recommended)
flutter build appbundle --release

# Split APKs by architecture
flutter build apk --release --split-per-abi

# Enable tree-shaking for icons
flutter build apk --release --tree-shake-icons

# Code obfuscation
flutter build apk --release --obfuscate --split-debug-info=debug_info/
```

#### Asset Optimization
- **Use SVG instead of raster images** for scalable graphics
- **Compress images** using pngquant, zopflipng, or pngcrush
- **Remove unused assets** from pubspec.yaml
- **Use google_fonts plugin** instead of bundling font files

#### Code Optimization
- **Tree-shaking**: Automatic removal of unused Dart code during AOT compilation
- **ProGuard**: Enable minification for Android builds
- **Remove unused dependencies** from pubspec.yaml
- **Platform-specific dependencies**: Exclude unnecessary plugins per platform

### Size Analysis Tools
**Link**: https://docs.flutter.dev/tools/devtools/app-size

```bash
# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Generate detailed size report
flutter build apk --release --analyze-size --target-platform android-arm64
```

### Size Monitoring
- **Target Size**: Aim for <10MB download size for good user experience
- **Monitor Growth**: Regular size analysis during development
- **User Impact**: Larger apps have higher abandonment rates and more uninstalls

## Performance Considerations for Our App

### SQLite Performance on Mobile
**Link**: https://developer.android.com/topic/performance/sqlite-performance-best-practices

- **Read Optimization**: Minimize rows and columns retrieved
- **Indexing**: Create indexes for tag name searches
- **Prepared Statements**: Use for repeated tag queries
- **Write-Ahead Logging**: Enable WAL mode for better concurrency

### Tag Input Performance
- **Debounced Search**: 150ms delay after typing stops
- **Result Limiting**: Maximum 10 suggestions
- **Local Database**: All tag operations stay local for speed
- **Caching**: Cache recent suggestion results

### Memory Management
- **Lazy Loading**: Load suggestions only when needed
- **Cleanup**: Regular cleanup of old usage statistics
- **State Management**: Use BLoC pattern for efficient state updates

## Development Workflow for Our App

### Daily Development Process
1. **Start Development**:
   ```bash
   flutter run -d "iPhone 15 Pro"  # iOS testing
   flutter run -d "Pixel_7_API_34"  # Android testing
   ```

2. **Feature Development**:
   - Write widget tests for tag components
   - Use hot reload for UI iterations
   - Test on both platforms regularly

3. **Testing Cycle**:
   ```bash
   flutter test                    # Run unit tests
   flutter test integration_test/  # Run integration tests
   flutter drive --target=test_driver/app.py  # E2E tests
   ```

4. **Size Monitoring**:
   ```bash
   flutter build apk --analyze-size  # Check Android size
   flutter build ios --analyze-size  # Check iOS size
   ```

### Continuous Integration Setup

#### Automated Testing Pipeline
```yaml
# Example GitHub Actions workflow
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: flutter build apk --analyze-size
      - run: flutter build ios --analyze-size --no-codesign
```

## Device-Specific Considerations

### iPhone Testing
- **Simulator Testing**: Use various iPhone models in iOS Simulator
- **Real Device Testing**: Required for final validation
- **Memory Constraints**: Test on older devices (iPhone 8, etc.)
- **Screen Sizes**: Test tag input on various screen sizes

### Android Testing  
- **Emulator Testing**: Use different Android versions and screen densities
- **Physical Device Testing**: Test on various OEM devices
- **Performance Variance**: Test on low-end and high-end devices
- **Memory Management**: Monitor memory usage on devices with limited RAM

## Success Metrics

### Development Metrics
- **Build Time**: Target <2 minutes for debug builds
- **Test Execution**: <30 seconds for full test suite
- **Hot Reload Time**: <1 second for UI changes
- **App Size**: <10MB final bundle size

### Quality Metrics
- **Test Coverage**: >80% code coverage
- **Performance**: <100ms tag suggestion response
- **Stability**: <1% crash rate during testing
- **Compatibility**: 100% feature parity across iOS/Android

This comprehensive development and testing strategy ensures our tag-focused Mind Map application delivers excellent performance and user experience across both iOS and Android platforms.