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
- `fvm flutter test` - Run tests
- `fvm dart` - Run Dart commands

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

## Task Completion Process

### Before Starting
1. Read the task requirements carefully
2. Check if similar tasks have been completed before
3. Review any relevant learnings from previous errors

### During Execution
1. Document each step taken
2. Note any errors or unexpected behavior
3. Keep track of successful commands and configurations

### After Completion
1. Verify the task meets all success criteria
2. Document any errors or learnings in `learnings.md`
3. Update this file if new processes were discovered
4. Mark the task as complete in the todo system
5. **IMPORTANT**: When completing a task in the todo list, check it off with a checkmark ✅

### Todo List Management
- Always use checkmark ✅ when marking tasks as complete
- Format: `- [✅] Task description`
- This provides clear visual indication of completed work
- Helps track progress across the development workflow

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