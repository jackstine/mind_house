# Programming Agent Instructions

## Overview
This document contains workflows and processes for programming tasks, including error handling and learning management.

## Error Handling and Learning Process

### Error Documentation
When completing todos, if you encounter any errors or make mistakes, please document them in the `agents/programming/learnings.md` file. This helps build a knowledge base of common issues and solutions.

### Learning Documentation Format
- **Issue**: Brief description of the problem
- **Context**: What task was being performed
- **Error**: Specific error message or issue encountered
- **Solution**: How the issue was resolved
- **Prevention**: How to avoid this issue in the future

## Development Workflow

### Testing Requirements for All Development Tasks

**CRITICAL**: Every todo item that involves development MUST include comprehensive testing. This is non-negotiable for the Mind Map application.

#### Testing Types Required by Category

**Category A (Environment Setup)**: 
- Verification tests for environment configuration
- Basic Flutter build tests
- Device connectivity tests

**Category B (Database Layer)**:
- Unit tests for all database operations
- Schema validation tests
- Migration testing
- Error handling tests
- Performance tests for large datasets

**Category C (Core Models)**:
- Unit tests for all model classes
- Repository pattern tests
- Data validation tests
- CRUD operation tests
- UUID generation and handling tests

**Category D (State Management - BLoC)**:
- Unit tests for all BLoC classes
- Event handling tests
- State transition tests
- Error state tests
- Async operation tests

**Category E (Core UI Components)**:
- Widget tests for every component
- Golden file tests for visual regression
- Interaction tests (tap, input, selection)
- Accessibility tests
- Platform-specific tests (iOS/Android)

**Category F (Page Components)**:
- Widget tests for complete pages
- Integration tests for page workflows
- Navigation tests
- State persistence tests
- Form validation tests

**Category G (Navigation)**:
- Navigation flow tests
- Deep linking tests
- Back button handling tests
- Tab switching tests
- Lifecycle management tests

**Category H (Business Logic)**:
- End-to-end workflow tests
- Tag suggestion algorithm tests
- Search and filtering tests
- Data consistency tests
- Performance tests under load

**Category I (Testing Infrastructure)**:
- Test framework configuration tests
- Mock data generation tests
- Test database setup/teardown verification
- CI/CD pipeline tests

**Category J (Testing Implementation)**:
- Comprehensive test suite execution
- Coverage verification (target >80%)
- BDD scenario tests with Gherkin
- Integration test execution
- Performance benchmark tests

#### Testing Standards by Technology

**Flutter Testing**:
- Use flutter_test for widget tests
- Use integration_test package for E2E tests
- Implement golden file tests for UI consistency
- BDD testing with gherkin package
- Test on both iOS and Android platforms

**SQLite Testing**:
- Test database operations with in-memory databases
- Validate schema migrations
- Test data integrity constraints
- Performance testing for tag queries
- Concurrent access testing

**BLoC Testing**:
- Test all events and states
- Mock repository dependencies
- Test error handling and loading states
- Verify state transitions
- Test async operations and cancellation

#### Testing Commands to Execute

For every development task completion:
```bash
# Run all tests
fvm flutter test

# Run specific test files
fvm flutter test test/database/
fvm flutter test test/models/
fvm flutter test test/widgets/

# Run integration tests
fvm flutter test integration_test/

# Run with coverage
fvm flutter test --coverage

# Golden file testing
fvm flutter test --update-goldens
```

#### Required Testing for Each Todo Category

**When completing ANY todo item that involves code development:**

1. **Write tests FIRST** (Test-Driven Development approach)
2. **Implement the feature** to make tests pass
3. **Run full test suite** to ensure no regressions
4. **Verify test coverage** meets minimum requirements
5. **Update golden files** if UI components changed
6. **Document test scenarios** in learnings.md if complex

#### Flutter App-Specific Testing Focus

**Tag Input Component Testing**:
- Tag suggestion algorithm accuracy
- Autocomplete functionality
- Tag chip creation and removal
- Input validation and sanitization
- Performance with large tag datasets

**SQLite Database Testing**:
- Information table CRUD operations
- Tag table operations with usage counting
- Junction table relationship integrity
- Database migration scenarios
- Concurrent access handling
- Query performance optimization

**Material Design Component Testing**:
- Chip widget behavior and styling
- Text input field validation
- Navigation between pages
- State management across app lifecycle
- Platform-specific UI differences

### Environment Setup Tasks
When completing environment setup tasks (Category A), follow these guidelines:

#### A4. Android Emulator Setup
**Task**: Set up Android emulator for testing
**Process**:
1. Verify Android SDK installation via `fvm flutter doctor -v`
2. List available AVDs: `/Users/jake/Library/Android/sdk/emulator/emulator -list-avds`
3. Check running devices: `/Users/jake/Library/Android/sdk/platform-tools/adb devices`
4. Verify Flutter compatibility: `fvm flutter devices`
5. Ensure emulator appears in Flutter devices list

**Success Criteria**:
- Android emulator appears in `fvm flutter devices` output
- Emulator status shows as "device" in adb devices
- Flutter doctor shows no Android-related issues

### Flutter Development Commands
Always use `fvm` prefix for Flutter commands:
- `fvm flutter doctor` - Check Flutter installation
- `fvm flutter devices` - List available devices
- `fvm flutter test` - Run tests (REQUIRED for every development task)
- `fvm flutter test --coverage` - Run tests with coverage report
- `fvm flutter test test/database/` - Run specific test directory
- `fvm flutter test integration_test/` - Run integration tests
- `fvm flutter test --update-goldens` - Update golden file tests
- `fvm dart` - Run Dart commands

### Testing-Specific Flutter Commands

#### For Database Testing (Category B & C):
```bash
# Test database operations
fvm flutter test test/database/database_helper_test.dart
fvm flutter test test/models/
fvm flutter test test/repositories/

# Run with verbose output for debugging
fvm flutter test --verbose test/database/
```

#### For Widget Testing (Category E & F):
```bash
# Test UI components
fvm flutter test test/widgets/
fvm flutter test test/pages/

# Update visual regression tests
fvm flutter test --update-goldens test/widgets/
```

#### For BLoC Testing (Category D):
```bash
# Test state management
fvm flutter test test/blocs/
fvm flutter test test/blocs/information_bloc_test.dart
```

#### For Integration Testing (Category H & J):
```bash
# Run end-to-end tests
fvm flutter test integration_test/
fvm flutter drive --target=test_driver/app.dart
```

## File Management

### Required Files
- `agents/programming/learnings.md` - Error documentation and learning repository
- `agents/programming/agent.md` - This file containing programming instructions

### Documentation Updates
When adding new instructions or processes:
1. Update this file with the new workflow
2. Document any errors encountered in `learnings.md`
3. Include specific commands and paths used
4. Note success criteria for task completion

### Git Commit Format Requirements

**CRITICAL**: All commits must follow the specified format based on the type of change:

#### Test Changes
- **Format**: `TEST_CHANGE: [description]`
- **When to use**: Every time you are about to run tests and you are changing test code
- **Example**: `TEST_CHANGE: Add unit tests for Information repository CRUD operations`

#### Code Changes  
- **Format**: `CODE_CHANGE: [description]`
- **When to use**: Every time you commit code that was developed (implementation code)
- **Example**: `CODE_CHANGE: Implement Information repository with CRUD operations`

#### Commit Workflow
1. Write/modify tests → Commit with `TEST_CHANGE:`
2. Implement code to pass tests → Commit with `CODE_CHANGE:`
3. Run `fvm flutter test` to verify all tests pass
4. Repeat cycle for next feature

## Task Completion Process

### Before Starting
1. Read the task requirements carefully
2. Check if similar tasks have been completed before
3. Review any relevant learnings from previous errors

### During Execution
1. Document each step taken
2. Note any errors or unexpected behavior
3. Keep track of successful commands and configurations
4. **CRITICAL**: Make sure that the application builds at the end of every completed todo sub section

### After Completion
1. **CRITICAL**: Run all applicable tests for the completed feature
2. **CRITICAL**: Verify the application builds successfully (`fvm flutter build` or `fvm flutter run`)
3. **CRITICAL**: Document any errors or learnings in `learnings.md` when you make an error or when a test fails
4. Update this file if new processes were discovered
5. **Run `fvm flutter test` to ensure no regressions**
6. Mark the task as complete in the todo system
7. **IMPORTANT**: When completing a task in the todo list, check it off with a checkmark ✅
8. **REQUIRED**: Commit every time you complete a sub step in the `development-todo.md` file
9. **REQUIRED**: Check off completed tasks in the development todo list

### Testing Verification Checklist
Before marking any development todo as complete ✅:

- [ ] Unit tests written and passing for new code
- [ ] Widget tests created for any UI components
- [ ] Integration tests updated if workflow changed
- [ ] `fvm flutter test` runs without errors
- [ ] Test coverage maintained or improved
- [ ] Golden files updated if UI changed
- [ ] Platform-specific testing completed (iOS & Android)
- [ ] Performance tests added for database operations
- [ ] Error handling scenarios tested

### Todo List Management
- Always use checkmark ✅ when marking tasks as complete
- Format: `- [✅] Task description`
- This provides clear visual indication of completed work
- Helps track progress across the development workflow
- **MANDATORY**: Check off the tasks that you have already performed in the development-todo.md file
- **MANDATORY**: Commit after completing each sub step in the development-todo.md file

### Build Verification Requirements
- **CRITICAL**: The application MUST build successfully at the end of every completed todo sub section
- Run `fvm flutter build` or `fvm flutter run` to verify build success
- If build fails, document the error in `learnings.md` and fix before proceeding
- Never mark a todo sub section as complete if the application doesn't build

### Error and Learning Documentation Requirements
- **MANDATORY**: Populate the `learnings.md` file whenever you make an error
- **MANDATORY**: Document in `learnings.md` when any test fails
- Include the specific error, context, and solution
- This builds institutional knowledge for future development

## Best Practices

### Error Prevention
- Always use full paths when commands are not in PATH
- Verify prerequisites before starting tasks
- Test commands in verbose mode when available
- Document successful command sequences for future reference

### Documentation Standards
- Include specific file paths and commands used
- Note macOS-specific considerations
- Document both successful and failed approaches
- Update instructions based on new discoveries

## Additional Development Workflow Requirements

### Command Recording
- When you use a new terminal command, record it in the appropriate documentation file
- This helps build a reference of useful commands for the project

### Planning Stage Requirements
- In the planning stages, identify ALL packages that will be needed in the project
- Add a todo item to install all of these packages as one of the first things to do
- This prevents package dependency issues later in development

### UI Development Approach
- When creating a UI-based application, create the skeleton layout first
- Ensure you can move between pages before implementing detailed functionality
- Consider implementing a playbook-style development approach
- This allows seeing UI component changes as they happen and provides better development feedback

### Code Layout Design
- Always perform code layout design structure planning
- This was identified as missing in previous projects
- Plan the overall architecture before starting implementation