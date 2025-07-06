# Programming Learnings

## Overview
This file documents errors, mistakes, and learnings encountered during programming tasks to build a knowledge base for future reference.

## Task A4: Android Emulator Setup

### Successful Completion
**Date**: 2025-07-06
**Task**: Set up Android emulator for testing
**Context**: Completing development todo A4 for Flutter environment setup

**Key Learnings**:
- Android emulator was already properly configured and running
- Flutter doctor showed all green checkmarks for Android toolchain
- Emulator commands require full paths when not in system PATH:
  - `/Users/jake/Library/Android/sdk/emulator/emulator -list-avds`
  - `/Users/jake/Library/Android/sdk/platform-tools/adb devices`
- fvm flutter commands work correctly with existing Android setup

**Commands Used**:
```bash
fvm flutter doctor -v
/Users/jake/Library/Android/sdk/emulator/emulator -list-avds
/Users/jake/Library/Android/sdk/platform-tools/adb devices  
fvm flutter devices
```

**Success Criteria Met**:
- ✅ Android emulator appears in Flutter devices list
- ✅ Emulator status shows as "device" in adb devices  
- ✅ Flutter doctor shows no Android-related issues
- ✅ AVD "Medium_Phone_API_36.0" available and running

## Template for Future Entries

### [Task Name/Number]
**Date**: [YYYY-MM-DD]
**Task**: [Brief description]
**Context**: [What was being done]

**Issue**: [Problem encountered]
**Error**: [Specific error message]
**Solution**: [How it was resolved]
**Prevention**: [How to avoid in future]

**Commands Used**:
```bash
[List of commands that worked]
```

**Learnings**:
- [Key insights gained]
- [Best practices discovered]
- [Things to remember for next time]