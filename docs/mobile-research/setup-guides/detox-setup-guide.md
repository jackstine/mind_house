# Detox React Native E2E Testing Setup Guide

## Overview

Detox is a gray box end-to-end testing and automation framework specifically designed for React Native applications. This guide provides complete setup instructions for 2025.

## Prerequisites

- Node.js v16 or higher
- React Native 0.73.x - 0.78.x
- Xcode (for iOS testing)
- Android Studio (for Android testing)
- macOS (recommended for full platform support)

## Installation

### 1. Global Dependencies

```bash
# Install Detox CLI globally
npm install detox-cli --global

# Install Apple Simulator Utils (iOS)
brew tap wix/brew
brew install applesimutils

# Verify installation
detox --version
```

### 2. Project Dependencies

```bash
# Install Jest and Detox
npm install "jest@^29" --save-dev
npm install detox --save-dev

# Initialize Detox configuration
npx detox init
```

## Configuration

### 1. Detox Configuration File

Create `detox.config.js` in your project root:

```javascript
module.exports = {
  testRunner: 'jest',
  runnerConfig: 'e2e/config.json',
  
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/YourApp.app',
      build: 'xcodebuild -workspace ios/YourApp.xcworkspace -scheme YourApp -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build'
    },
    'ios.release': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Release-iphonesimulator/YourApp.app',
      build: 'xcodebuild -workspace ios/YourApp.xcworkspace -scheme YourApp -configuration Release -sdk iphonesimulator -derivedDataPath ios/build'
    },
    'android.debug': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/debug/app-debug.apk',
      build: 'cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug'
    },
    'android.release': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/release/app-release.apk',
      build: 'cd android && ./gradlew assembleRelease assembleAndroidTest -DtestBuildType=release'
    }
  },

  devices: {
    'ios.simulator': {
      type: 'ios.simulator',
      device: {
        type: 'iPhone 14'
      }
    },
    'android.emulator': {
      type: 'android.emulator',
      device: {
        avdName: 'Pixel_4_API_30'
      }
    }
  },

  configurations: {
    'ios.sim.debug': {
      device: 'ios.simulator',
      app: 'ios.debug'
    },
    'ios.sim.release': {
      device: 'ios.simulator',
      app: 'ios.release'
    },
    'android.emu.debug': {
      device: 'android.emulator',
      app: 'android.debug'
    },
    'android.emu.release': {
      device: 'android.emulator',
      app: 'android.release'
    }
  }
};
```

### 2. Jest Configuration

Create `e2e/config.json`:

```json
{
  "maxWorkers": 1,
  "testTimeout": 120000,
  "testRegex": "\\.e2e\\.js$",
  "reporters": ["detox/runners/jest/streamlineReporter"],
  "verbose": true
}
```

### 3. Package.json Scripts

Add test scripts to your `package.json`:

```json
{
  "scripts": {
    "e2e:build:ios": "detox build --configuration ios.sim.debug",
    "e2e:test:ios": "detox test --configuration ios.sim.debug --cleanup",
    "e2e:build:android": "detox build --configuration android.emu.debug",
    "e2e:test:android": "detox test --configuration android.emu.debug --cleanup",
    "e2e:test": "npm run e2e:build:ios && npm run e2e:test:ios"
  }
}
```

## iOS Setup

### 1. Xcode Configuration

1. Open your iOS project in Xcode
2. Disable animations in iOS Simulator:
   - Hardware → Device → Settings → Accessibility → Motion → Reduce Motion: ON

### 2. Test ID Configuration

Add test IDs to your React Native components:

```javascript
// Example component
export const LoginScreen = () => {
  return (
    <View>
      <TextInput
        testID="usernameInput"
        placeholder="Username"
        onChangeText={setUsername}
      />
      <TextInput
        testID="passwordInput"
        placeholder="Password"
        onChangeText={setPassword}
        secureTextEntry
      />
      <TouchableOpacity
        testID="loginButton"
        onPress={handleLogin}
      >
        <Text>Login</Text>
      </TouchableOpacity>
    </View>
  );
};
```

## Android Setup

### 1. Android Configuration

1. Disable animations in Android emulator:
   - Settings → Developer Options → Animation scales (set all to 0x)

2. Add to `android/app/build.gradle`:

```gradle
android {
  ...
  
  defaultConfig {
    ...
    testBuildType System.getProperty('testBuildType', 'debug')
    testInstrumentationRunner 'androidx.test.runner.AndroidJUnitRunner'
  }
}

dependencies {
  androidTestImplementation('com.wix:detox:+') { transitive = true }
  androidTestImplementation 'junit:junit:4.12'
}
```

3. Add to `android/app/src/androidTest/java/.../DetoxTest.java`:

```java
package com.yourpackage;

import com.wix.detox.Detox;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.LargeTest;
import androidx.test.rule.ActivityTestRule;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class DetoxTest {

    @Rule
    public ActivityTestRule<MainActivity> mActivityRule = new ActivityTestRule<>(MainActivity.class, false, false);

    @Test
    public void runDetoxTests() {
        Detox.runTests(mActivityRule);
    }
}
```

## Writing Tests

### 1. Basic Test Structure

Create `e2e/firstTest.e2e.js`:

```javascript
describe('Example', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have welcome screen', async () => {
    await expect(element(by.id('welcome'))).toBeVisible();
  });

  it('should show hello screen after tap', async () => {
    await element(by.id('hello_button')).tap();
    await expect(element(by.text('Hello!!!'))).toBeVisible();
  });

  it('should show world screen after tap', async () => {
    await element(by.id('world_button')).tap();
    await expect(element(by.text('World!!!'))).toBeVisible();
  });
});
```

### 2. Advanced Test Patterns

```javascript
describe('Login Flow', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should login successfully', async () => {
    // Wait for elements to appear
    await waitFor(element(by.id('usernameInput'))).toBeVisible().withTimeout(5000);
    
    // Type credentials
    await element(by.id('usernameInput')).typeText('testuser');
    await element(by.id('passwordInput')).typeText('password123');
    
    // Tap login button
    await element(by.id('loginButton')).tap();
    
    // Verify navigation to home screen
    await expect(element(by.id('homeScreen'))).toBeVisible();
  });

  it('should handle login error', async () => {
    await element(by.id('usernameInput')).typeText('invalid');
    await element(by.id('passwordInput')).typeText('invalid');
    await element(by.id('loginButton')).tap();
    
    // Wait for error message
    await waitFor(element(by.text('Invalid credentials')))
      .toBeVisible()
      .withTimeout(3000);
  });
});
```

### 3. Page Object Model

```javascript
// e2e/pages/LoginPage.js
class LoginPage {
  constructor() {
    this.usernameInput = element(by.id('usernameInput'));
    this.passwordInput = element(by.id('passwordInput'));
    this.loginButton = element(by.id('loginButton'));
    this.errorMessage = element(by.id('errorMessage'));
  }

  async login(username, password) {
    await this.usernameInput.typeText(username);
    await this.passwordInput.typeText(password);
    await this.loginButton.tap();
  }

  async expectErrorMessage(message) {
    await expect(this.errorMessage).toHaveText(message);
  }

  async waitForVisible() {
    await waitFor(this.usernameInput).toBeVisible().withTimeout(5000);
  }
}

module.exports = LoginPage;
```

## Running Tests

### 1. Build and Test Commands

```bash
# iOS
npm run e2e:build:ios
npm run e2e:test:ios

# Android
npm run e2e:build:android
npm run e2e:test:android

# With specific configuration
detox test --configuration ios.sim.debug --cleanup

# Run specific test file
detox test --configuration ios.sim.debug e2e/login.e2e.js

# Debug mode
detox test --configuration ios.sim.debug --loglevel verbose
```

### 2. CI/CD Integration

GitHub Actions workflow:

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm install
      
    - name: Build for testing
      run: detox build --configuration ios.sim.debug
      
    - name: Run E2E tests
      run: detox test --configuration ios.sim.debug --cleanup --headless
```

## Troubleshooting

### Common Issues

1. **App doesn't load**: Ensure correct binary path in configuration
2. **Simulator issues**: Reset simulator and disable animations
3. **Android build failures**: Check gradle configuration and test runner
4. **Flaky tests**: Add proper wait strategies and element visibility checks

### Debug Tips

```bash
# Verbose logging
detox test --configuration ios.sim.debug --loglevel verbose

# Keep simulator open after tests
detox test --configuration ios.sim.debug --debug-synchronization

# Record test artifacts
detox test --configuration ios.sim.debug --record-videos failing
```

## Best Practices

1. **Test IDs**: Use consistent, descriptive test IDs
2. **Wait Strategies**: Always wait for elements to be visible/ready
3. **Test Independence**: Each test should be independent and resettable
4. **Page Objects**: Use page object model for maintainable tests
5. **Assertions**: Make specific, meaningful assertions
6. **Cleanup**: Clean up test data after each test run

This setup guide provides everything needed to implement Detox E2E testing in your React Native application effectively.