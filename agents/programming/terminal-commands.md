# Terminal Commands Reference

## Overview
This file records all terminal commands used during development with explanations for future reference.

## Commands Used

### Flutter Development Commands

#### fvm flutter doctor -v
**Purpose**: Check Flutter installation status and configuration with verbose output
**Usage**: `fvm flutter doctor -v`
**Explanation**: Provides detailed information about Flutter SDK installation, connected devices, and any configuration issues. The `-v` flag gives verbose output with additional details.

#### fvm flutter doctor
**Purpose**: Check Flutter installation status and configuration (summary)
**Usage**: `fvm flutter doctor`
**Explanation**: Provides a summary of Flutter SDK installation status and any configuration issues. Shows checkmarks for properly configured components and warnings/errors for issues that need attention.

#### fvm flutter devices
**Purpose**: List all connected devices compatible with Flutter
**Usage**: `fvm flutter devices`
**Explanation**: Shows all available devices for Flutter development including physical devices, emulators, and simulators. Each device shows its ID, name, and platform type.

#### fvm flutter test
**Purpose**: Run Flutter tests using the fvm-managed Flutter version
**Usage**: `fvm flutter test`
**Explanation**: Executes all test files in the test directory. Uses the Flutter version managed by fvm to ensure consistency across environments. REQUIRED for every development task completion.

#### fvm flutter test --coverage
**Purpose**: Run Flutter tests with coverage report
**Usage**: `fvm flutter test --coverage`
**Explanation**: Runs all tests and generates a coverage report. Target coverage is >80% for the Mind Map application.

#### fvm flutter test test/database/
**Purpose**: Run specific test directory
**Usage**: `fvm flutter test test/database/`
**Explanation**: Runs only tests in the specified directory. Useful for testing specific components like database operations, models, or widgets.

#### fvm flutter test integration_test/
**Purpose**: Run integration tests
**Usage**: `fvm flutter test integration_test/`
**Explanation**: Executes end-to-end integration tests that test complete workflows across the app.

#### fvm flutter test --update-goldens
**Purpose**: Update golden file tests for visual regression
**Usage**: `fvm flutter test --update-goldens`
**Explanation**: Updates golden files used for UI component visual regression testing. Run this when UI components are intentionally changed.

#### fvm dart
**Purpose**: Run Dart commands using the fvm-managed Dart version
**Usage**: `fvm dart [command]`
**Explanation**: Executes Dart commands using the version bundled with the fvm-managed Flutter installation.

#### fvm flutter create
**Purpose**: Create a new Flutter project with proper structure
**Usage**: `fvm flutter create project_name`
**Explanation**: Creates a new Flutter project with the specified name. Generates all necessary files and folders for a complete Flutter application including iOS, Android, web, and desktop platform support.

#### fvm flutter build apk --debug
**Purpose**: Build debug APK for Android
**Usage**: `fvm flutter build apk --debug`
**Explanation**: Compiles the Flutter app into a debug APK for Android. Useful for testing on Android devices and verifying Android platform configuration.

#### fvm flutter build ios --debug --simulator
**Purpose**: Build debug iOS app for simulator
**Usage**: `fvm flutter build ios --debug --simulator`
**Explanation**: Compiles the Flutter app for iOS simulator. Verifies iOS platform configuration and builds the app for testing on iOS simulators.

#### fvm flutter pub get
**Purpose**: Install Flutter project dependencies
**Usage**: `fvm flutter pub get`
**Explanation**: Downloads and installs all dependencies listed in pubspec.yaml file. Must be run after adding new dependencies or when setting up a project for the first time.

### iOS Development Commands

#### xcrun simctl list devices
**Purpose**: List all available iOS simulators
**Usage**: `xcrun simctl list devices`
**Explanation**: Shows all iOS simulators installed on the system, their UUIDs, and current status (Shutdown, Booted, etc.). Part of Xcode command line tools.

#### xcrun simctl boot "Device Name"
**Purpose**: Boot a specific iOS simulator
**Usage**: `xcrun simctl boot "iPhone 16 Pro"`
**Explanation**: Starts the specified iOS simulator. The device name must match exactly as shown in the device list. Once booted, the simulator can be detected by Flutter.

#### xcrun devicectl list devices
**Purpose**: List connected physical iOS devices
**Usage**: `xcrun devicectl list devices`
**Explanation**: Shows all physical iOS devices connected via USB or wirelessly. Modern replacement for older iOS device detection methods.

### Android Development Commands

#### /Users/jake/Library/Android/sdk/emulator/emulator -list-avds
**Purpose**: List all available Android Virtual Devices
**Usage**: `/Users/jake/Library/Android/sdk/emulator/emulator -list-avds`
**Explanation**: Shows all configured Android emulators. Uses full path because emulator command may not be in system PATH.

#### /Users/jake/Library/Android/sdk/platform-tools/adb devices
**Purpose**: List all connected Android devices and emulators
**Usage**: `/Users/jake/Library/Android/sdk/platform-tools/adb devices`
**Explanation**: Shows all Android devices connected via USB or network, including running emulators. The `-l` flag provides additional device information.

#### /Users/jake/Library/Android/sdk/platform-tools/adb devices -l
**Purpose**: List Android devices with detailed information
**Usage**: `/Users/jake/Library/Android/sdk/platform-tools/adb devices -l`
**Explanation**: Extended version that shows device model, product, and transport information in addition to basic device list.

### System Information Commands

#### system_profiler SPUSBDataType | grep -i android
**Purpose**: Check for USB-connected Android devices
**Usage**: `system_profiler SPUSBDataType | grep -i android`
**Explanation**: Uses macOS system profiler to detect Android devices connected via USB. Helpful for debugging device connection issues.

#### system_profiler SPUSBDataType | grep -i iphone
**Purpose**: Check for USB-connected iOS devices
**Usage**: `system_profiler SPUSBDataType | grep -i iphone`
**Explanation**: Uses macOS system profiler to detect iOS devices connected via USB. Alternative method for iOS device detection.

### File System Commands

#### ls -la /path/to/directory
**Purpose**: List directory contents with detailed information
**Usage**: `ls -la /Users/jake/Library/Android/sdk/emulator/`
**Explanation**: Lists all files and directories including hidden ones (`-a`) with detailed permissions, ownership, and modification dates (`-l`).

## Command Categories

### Essential Flutter Commands
- `fvm flutter doctor -v` - System health check
- `fvm flutter devices` - Device detection
- `fvm flutter test` - Run tests
- `fvm dart` - Dart operations

### iOS Simulator Management
- `xcrun simctl list devices` - List simulators
- `xcrun simctl boot "Device Name"` - Start simulator
- `xcrun devicectl list devices` - List physical devices

### Android Device Management
- `adb devices` - List connected devices
- `emulator -list-avds` - List virtual devices
- `system_profiler SPUSBDataType` - USB device detection

## Best Practices

### Using Full Paths
When Android SDK tools are not in PATH, use full paths:
- `/Users/jake/Library/Android/sdk/platform-tools/adb`
- `/Users/jake/Library/Android/sdk/emulator/emulator`

### FVM Consistency
Always use `fvm` prefix for Flutter/Dart commands to ensure version consistency:
- `fvm flutter` instead of `flutter`
- `fvm dart` instead of `dart`

### Device Detection
Use multiple methods to verify device connectivity:
1. Flutter-specific: `fvm flutter devices`
2. Platform-specific: `adb devices` or `xcrun simctl list devices`
3. System-level: `system_profiler SPUSBDataType`

## Troubleshooting Commands

### When Flutter doesn't detect devices
1. Check `fvm flutter doctor -v` for issues
2. Verify device-specific commands show the device
3. Restart devices or simulators if needed
4. Check USB connections and permissions

### When simulators don't start
1. Use `xcrun simctl list devices` to check status
2. Boot explicitly with `xcrun simctl boot`
3. Check Xcode installation if iOS simulators missing
4. Verify Android SDK installation if AVDs missing