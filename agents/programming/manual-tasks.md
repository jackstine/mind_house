# Manual Tasks

## Overview
This file contains tasks that require manual intervention or cannot be completed automatically through commands.

## Physical Device Configuration Tasks

### Manual Task: Connect Physical Android Device
**Task ID**: A6 (Physical Android Device Configuration)
**Instructions**:
1. Connect Android device to Mac via USB cable
2. On Android device, enable Developer Options:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
3. Enable USB Debugging in Developer Options
4. When prompted on device, allow USB debugging for this computer
5. Verify connection with: `/Users/jake/Library/Android/sdk/platform-tools/adb devices`
6. Device should appear as "device" status (not "unauthorized")

### Manual Task: Connect Physical iOS Device
**Task ID**: A7 (Physical iOS Device Configuration)
**Instructions**:
1. Connect iOS device to Mac via USB cable
2. On iOS device, tap "Trust This Computer" when prompted
3. Enter device passcode if required
4. Verify connection with: `xcrun devicectl list devices`
5. Device should appear in the list with proper identifier
6. For development, may need to configure provisioning profiles in Xcode

## Project Structure Tasks

### Manual Task: Create Flutter Project Structure
**Task ID**: A9 (Create new Flutter project with proper structure)
**Instructions**:
1. Navigate to desired project directory
2. Run: `fvm flutter create mind_house_app`
3. Navigate into project: `cd mind_house_app`
4. Verify project structure includes:
   - `lib/` directory for Dart code
   - `android/` directory for Android-specific files
   - `ios/` directory for iOS-specific files
   - `test/` directory for test files
   - `pubspec.yaml` for dependencies
5. Test project builds: `fvm flutter build apk --debug`

### Manual Task: Configure Project for Platforms
**Task ID**: A10 (Configure project for iOS and Android platforms)
**Instructions**:
1. For iOS configuration:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Set up signing certificates and provisioning profiles
   - Configure bundle identifier
   - Set deployment target to iOS 12.0 or higher
2. For Android configuration:
   - Update `android/app/build.gradle` with proper app ID
   - Set minimum SDK version to 21 or higher
   - Configure signing for release builds
   - Update `android/app/src/main/AndroidManifest.xml` with app details

## Database Setup Tasks

### Manual Task: Database Schema Design
**Task ID**: B4, B5, B6 (Database table creation)
**Instructions**:
1. Design information table schema:
   - id (UUID primary key)
   - content (TEXT, required)
   - created_at (TIMESTAMP)
   - updated_at (TIMESTAMP)
2. Design tags table schema:
   - id (INTEGER primary key)
   - name (TEXT unique, required)
   - color (TEXT, hex color code)
   - usage_count (INTEGER default 0)
   - created_at (TIMESTAMP)
3. Design information_tags junction table:
   - information_id (UUID, foreign key)
   - tag_id (INTEGER, foreign key)
   - created_at (TIMESTAMP)
   - Primary key: (information_id, tag_id)

### Manual Task: Database Migration Strategy
**Task ID**: B7, B9 (Database version management and migrations)
**Instructions**:
1. Create migration system:
   - Version 1: Initial schema creation
   - Version 2+: Future schema changes
2. Implement upgrade logic:
   - Check current database version
   - Apply migrations sequentially
   - Handle rollback scenarios
3. Test migration paths:
   - Fresh installation
   - Upgrade from each previous version
   - Data preservation during upgrades

## Testing Infrastructure Tasks

### Manual Task: Test Database Setup
**Task ID**: I6 (Configure test database setup and teardown)
**Instructions**:
1. Create separate test database configuration
2. Implement test database creation before each test
3. Implement test database cleanup after each test
4. Create test data factories for consistent test data
5. Ensure test isolation (no shared state between tests)

### Manual Task: CI/CD Configuration
**Task ID**: I8 (Set up continuous integration testing)
**Instructions**:
1. Configure GitHub Actions or similar CI system
2. Set up automated testing on code commits
3. Configure multiple test environments:
   - Unit tests
   - Widget tests
   - Integration tests
4. Set up test result reporting
5. Configure automated builds for multiple platforms

## Development Environment Tasks

### Manual Task: IDE Configuration
**Instructions**:
1. Install Flutter extension in VS Code or IntelliJ
2. Configure Flutter SDK path in IDE
3. Set up debugging configuration
4. Configure code formatting (dartfmt)
5. Set up linting rules
6. Configure test running from IDE

### Manual Task: Version Control Setup
**Instructions**:
1. Initialize Git repository if not already done
2. Create appropriate .gitignore file for Flutter
3. Set up branch protection rules
4. Configure commit message templates
5. Set up pre-commit hooks for code quality

## Completion Verification

### How to Mark Manual Tasks Complete
1. Complete the manual steps as described
2. Verify the task meets success criteria
3. Test the configuration works as expected
4. Document any issues encountered in `learnings.md`
5. Mark the corresponding todo item as complete with ✅

### Success Criteria Templates
- **Device Configuration**: Device appears in `fvm flutter devices` output
- **Project Setup**: Project builds successfully without errors
- **Database Setup**: Database operations work correctly in tests
- **Testing Setup**: All test types can be executed successfully

## Notes
- Always test manual configurations with actual Flutter commands
- Document any platform-specific issues encountered
- Update this file with new manual tasks as they are discovered
- Reference this file when automating previously manual tasks