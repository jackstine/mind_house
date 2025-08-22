# 🚀 Patrol Testing Setup for Mind House App

## Overview
Patrol is an enhanced UI testing framework for Flutter that provides better error messages, native UI interactions, and advanced testing capabilities.

## Setup Complete ✅
The following has been configured for your Mind House app:

### 1. Dependencies Added
- `patrol: ^3.13.0` - Enhanced testing framework
- `test: ^1.25.0` - Test utilities

### 2. Configuration Files
- **Android**: `android/app/build.gradle.kts` configured with PatrolJUnitRunner
- **Test Files**: `integration_test/simple_patrol_test.dart` - Simple navigation tests
- **Config**: `integration_test/patrol_test_config.dart` - Test utilities and helpers
- **Script**: `scripts/run_patrol_tests.sh` - Automated test runner (FVM compatible)

## Running Tests

### Using FVM (Recommended)
```bash
# Navigate to the app directory
cd mind_house_app

# Install dependencies
fvm flutter pub get

# Run tests on specific device
fvm flutter test integration_test/simple_patrol_test.dart -d macos
fvm flutter test integration_test/simple_patrol_test.dart -d chrome

# Or use the script (automatically detects FVM)
./scripts/run_patrol_tests.sh
```

### Available Devices
To see available devices:
```bash
fvm flutter devices
```

Common device IDs:
- `macos` - macOS desktop
- `chrome` - Chrome web browser
- `ios` - iOS Simulator (macOS only)
- `android` - Android emulator

## Test Structure

### Simple Patrol Test (`simple_patrol_test.dart`)
This test file contains 3 test cases:

1. **Simple navigation test**
   - Launches the app
   - Clicks "List Information" tab
   - Clicks "Information" tab
   - Verifies navigation works

2. **Enter text and interact**
   - Enters text in content field
   - Adds tags
   - Clicks Save button

3. **UI responsiveness**
   - Rapidly navigates between tabs
   - Verifies app remains responsive

## Patrol Benefits

### Enhanced Features
- ✅ Better error messages and debugging
- ✅ Native UI interaction support (permissions, system dialogs)
- ✅ Screenshot capabilities
- ✅ Simplified API compared to raw integration_test
- ✅ Parallel test execution support

### Patrol API Examples
```dart
// Simple tap
await $('Button Text').tap();

// Enter text
await $(TextField).first.enterText('Hello');

// Verify element exists
expect($('Expected Text'), findsOneWidget);

// Take screenshot (when configured)
await $.takeScreenshot(name: 'test_screenshot');
```

## Troubleshooting

### No Devices Connected
If you see "No devices are connected", run:
```bash
fvm flutter devices
```
Then specify a device:
```bash
fvm flutter test integration_test/simple_patrol_test.dart -d chrome
```

### FVM Not Found
If FVM is not installed, install it first:
```bash
dart pub global activate fvm
fvm install stable
fvm use stable
```

### Test Fails to Launch
Ensure you have:
1. Run `fvm flutter pub get`
2. Selected a valid device
3. The app builds successfully

## Next Steps

### Add More Tests
Create new test files in `integration_test/` following the pattern in `simple_patrol_test.dart`.

### CI/CD Integration
Patrol tests can be integrated into CI/CD pipelines:
```yaml
# GitHub Actions example
- name: Run Patrol Tests
  run: |
    fvm flutter pub get
    fvm flutter test integration_test/
```

### Advanced Features
- Add screenshot testing
- Configure test reporting
- Set up parallel test execution
- Add custom test matchers

## Resources
- [Patrol Documentation](https://patrol.leancode.co/)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mind House Test Files](./integration_test/)

---

Your Mind House app is now configured with Patrol testing! 🎉