# Android Testing Setup Guide - Espresso, UI Automator & Robolectric

## Overview

This guide covers the setup and configuration of Android's primary testing frameworks: Espresso for UI testing, UI Automator for system-level testing, and Robolectric for unit testing with Android dependencies.

## Prerequisites

- Android Studio Arctic Fox (2020.3.1) or later
- Android SDK API level 21 or higher
- Java 8 or higher
- Gradle 7.0 or higher

## Espresso Setup

### 1. Module Dependencies

Add to `app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
        
        // Essential for Espresso
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    
    testOptions {
        unitTests {
            includeAndroidResources = true
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    // Core Espresso dependencies
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
    androidTestImplementation 'androidx.test:runner:1.5.2'
    androidTestImplementation 'androidx.test:rules:1.5.0'
    
    // Additional Espresso modules
    androidTestImplementation 'androidx.test.espresso:espresso-contrib:3.5.1'
    androidTestImplementation 'androidx.test.espresso:espresso-intents:3.5.1'
    androidTestImplementation 'androidx.test.espresso:espresso-idling-resource:3.5.1'
    androidTestImplementation 'androidx.test.espresso:espresso-web:3.5.1'
    
    // UI Automator
    androidTestImplementation 'androidx.test.uiautomator:uiautomator:2.4.0-alpha05'
    
    // Robolectric (for unit tests)
    testImplementation 'junit:junit:4.13.2'
    testImplementation 'org.robolectric:robolectric:4.13'
    testImplementation 'androidx.test:core:1.5.0'
    testImplementation 'androidx.test.ext:junit:1.1.5'
}
```

### 2. ProGuard Configuration

If using ProGuard, add to `proguard-rules.pro`:

```proguard
# Espresso
-keep class androidx.test.espresso.** { *; }
-keep interface androidx.test.espresso.** { *; }
-dontwarn androidx.test.espresso.**
```

### 3. Basic Espresso Test Structure

Create `app/src/androidTest/java/.../ExampleInstrumentedTest.java`:

```java
package com.example.app;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.LargeTest;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.typeText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class LoginActivityTest {

    @Rule
    public ActivityScenarioRule<LoginActivity> activityRule = 
        new ActivityScenarioRule<>(LoginActivity.class);

    @Test
    public void testSuccessfulLogin() {
        // Type username
        onView(withId(R.id.username_edittext))
            .perform(typeText("testuser"));

        // Type password
        onView(withId(R.id.password_edittext))
            .perform(typeText("password123"));

        // Click login button
        onView(withId(R.id.login_button))
            .perform(click());

        // Verify navigation to main activity
        onView(withId(R.id.main_content))
            .check(matches(isDisplayed()));
    }

    @Test
    public void testInvalidLogin() {
        onView(withId(R.id.username_edittext))
            .perform(typeText("invalid"));
        
        onView(withId(R.id.password_edittext))
            .perform(typeText("invalid"));
        
        onView(withId(R.id.login_button))
            .perform(click());

        // Verify error message
        onView(withText("Invalid credentials"))
            .check(matches(isDisplayed()));
    }
}
```

## UI Automator Setup

### 1. Basic UI Automator Test

Create `app/src/androidTest/java/.../SystemTest.java`:

```java
package com.example.app;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.SdkSuppress;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject2;
import androidx.test.uiautomator.Until;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertNotNull;

@RunWith(AndroidJUnit4.class)
@SdkSuppress(minSdkVersion = 18)
public class SystemInteractionTest {

    private UiDevice device;
    private static final String PACKAGE_NAME = "com.example.app";
    private static final int TIMEOUT = 5000;

    @Before
    public void setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        device.pressHome();
        
        // Launch the app
        device.pressRecentApps();
        device.wait(Until.hasObject(By.pkg(PACKAGE_NAME).depth(0)), TIMEOUT);
    }

    @Test
    public void testSystemNavigation() {
        // Test system back button
        device.pressBack();
        
        // Test opening notification panel
        device.openNotification();
        
        // Test quick settings
        device.openQuickSettings();
        
        // Return to app
        device.pressHome();
        launchApp();
    }

    @Test
    public void testPermissionDialog() {
        // Trigger permission request in your app
        UiObject2 allowButton = device.wait(
            Until.findObject(By.text("ALLOW")), TIMEOUT);
        
        if (allowButton != null) {
            allowButton.click();
        }
        
        // Verify app continues normally
        UiObject2 mainContent = device.wait(
            Until.findObject(By.res(PACKAGE_NAME, "main_content")), TIMEOUT);
        assertNotNull(mainContent);
    }

    private void launchApp() {
        device.pressHome();
        device.wait(Until.hasObject(By.pkg("com.android.launcher3").depth(0)), TIMEOUT);
        
        UiObject2 appIcon = device.findObject(By.text("YourApp"));
        if (appIcon != null) {
            appIcon.click();
        }
    }
}
```

### 2. Modern UI Automator 2.4 DSL

```java
package com.example.app;

import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.Until;

import static androidx.test.uiautomator.DeviceTestActions.*;
import static androidx.test.uiautomator.ElementActions.*;

public class ModernUIAutomatorTest {

    @Test
    public void testWithModernAPI() {
        UiDevice device = getDevice();
        
        // Modern DSL approach
        device.findObject(By.res("com.example.app", "button"))
            .click()
            .wait(Until.newWindow(), 2000);
            
        // Predicate-based finding
        device.findObjects(By.clazz("android.widget.Button"))
            .stream()
            .filter(obj -> obj.getText().contains("Submit"))
            .findFirst()
            .ifPresent(UiObject2::click);
    }
}
```

## Robolectric Setup

### 1. Basic Robolectric Configuration

Create `app/src/test/java/.../RobolectricTest.java`:

```java
package com.example.app;

import android.content.Context;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.annotation.Config;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

@RunWith(AndroidJUnit4.class)
@Config(sdk = {28})
public class LoginActivityRobolectricTest {

    private LoginActivity activity;

    @Before
    public void setUp() {
        activity = Robolectric.buildActivity(LoginActivity.class)
            .create()
            .resume()
            .get();
    }

    @Test
    public void testActivityCreation() {
        assertNotNull(activity);
    }

    @Test
    public void testButtonClick() {
        Button loginButton = activity.findViewById(R.id.login_button);
        TextView statusText = activity.findViewById(R.id.status_text);

        loginButton.performClick();

        assertEquals("Button clicked", statusText.getText().toString());
    }

    @Test
    public void testContextAvailability() {
        Context context = ApplicationProvider.getApplicationContext();
        assertEquals("com.example.app", context.getPackageName());
    }
}
```

### 2. Advanced Robolectric Features

```java
@RunWith(AndroidJUnit4.class)
@Config(sdk = {28}, manifest = Config.NONE)
public class AdvancedRobolectricTest {

    @Test
    public void testSharedPreferences() {
        Context context = ApplicationProvider.getApplicationContext();
        SharedPreferences prefs = context.getSharedPreferences("test", Context.MODE_PRIVATE);
        
        prefs.edit().putString("key", "value").apply();
        
        assertEquals("value", prefs.getString("key", null));
    }

    @Test
    public void testSQLiteDatabase() {
        Context context = ApplicationProvider.getApplicationContext();
        DatabaseHelper helper = new DatabaseHelper(context);
        SQLiteDatabase db = helper.getWritableDatabase();
        
        ContentValues values = new ContentValues();
        values.put("name", "Test");
        
        long id = db.insert("users", null, values);
        assertTrue(id > 0);
        
        // Use shadow to access internals
        ShadowSQLiteDatabase shadowDb = Shadows.shadowOf(db);
        assertEquals(1, shadowDb.getTable("users").size());
    }
}
```

## Page Object Model Implementation

### 1. Base Page Class

```java
public abstract class BasePage {
    protected static final int DEFAULT_TIMEOUT = 5000;
    
    protected void waitForElement(ViewInteraction element) {
        onView(isRoot()).perform(waitId(element, DEFAULT_TIMEOUT));
    }
    
    protected void typeTextSafely(ViewInteraction element, String text) {
        waitForElement(element);
        element.perform(clearText(), typeText(text));
    }
    
    protected void clickSafely(ViewInteraction element) {
        waitForElement(element);
        element.perform(click());
    }
}
```

### 2. Login Page Object

```java
public class LoginPage extends BasePage {
    private final ViewInteraction usernameField = onView(withId(R.id.username_edittext));
    private final ViewInteraction passwordField = onView(withId(R.id.password_edittext));
    private final ViewInteraction loginButton = onView(withId(R.id.login_button));
    private final ViewInteraction errorMessage = onView(withId(R.id.error_message));

    public LoginPage enterUsername(String username) {
        typeTextSafely(usernameField, username);
        return this;
    }

    public LoginPage enterPassword(String password) {
        typeTextSafely(passwordField, password);
        return this;
    }

    public HomePage clickLogin() {
        clickSafely(loginButton);
        return new HomePage();
    }

    public LoginPage verifyErrorMessage(String expectedError) {
        errorMessage.check(matches(withText(expectedError)));
        return this;
    }

    public static LoginPage open() {
        // Launch activity or navigate to login
        return new LoginPage();
    }
}
```

## Device Configuration

### 1. Disable Animations

```bash
# Via ADB
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
```

Or programmatically in tests:

```java
@Before
public void disableAnimations() {
    UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    
    try {
        device.executeShellCommand("settings put global window_animation_scale 0");
        device.executeShellCommand("settings put global transition_animation_scale 0");
        device.executeShellCommand("settings put global animator_duration_scale 0");
    } catch (IOException e) {
        throw new RuntimeException("Failed to disable animations", e);
    }
}
```

## Running Tests

### 1. Gradle Commands

```bash
# Run all unit tests
./gradlew test

# Run all instrumented tests
./gradlew connectedAndroidTest

# Run specific test class
./gradlew connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.LoginActivityTest

# Run with coverage
./gradlew createDebugCoverageReport

# Run Robolectric tests only
./gradlew testDebugUnitTest
```

### 2. Android Studio Integration

1. **Run Configuration**:
   - Right-click test class → Run
   - Use Run/Debug configurations for advanced options

2. **Test Results**:
   - View in Test Results panel
   - Generate HTML reports

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Android Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
        
    - name: Cache Gradle packages
      uses: actions/cache@v3
      with:
        path: ~/.gradle/caches
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle') }}
        
    - name: Run unit tests
      run: ./gradlew test
      
    - name: Setup Android SDK
      uses: android-actions/setup-android@v2
      
    - name: Create AVD
      run: |
        echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-29;google_apis;x86"
        $ANDROID_HOME/tools/bin/avdmanager create avd -n test -k "system-images;android-29;google_apis;x86"
        
    - name: Launch emulator
      run: |
        $ANDROID_HOME/emulator/emulator -avd test -no-audio -no-window -disable-animations &
        adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed | tr -d '\r') ]]; do sleep 1; done'
        
    - name: Run instrumented tests
      run: ./gradlew connectedAndroidTest
```

## Best Practices

### 1. Test Organization

```
app/src/
  androidTest/java/
    com/example/app/
      pages/          # Page objects
        LoginPage.java
        HomePage.java
      tests/          # Test classes
        LoginTest.java
        NavigationTest.java
      utils/          # Test utilities
        TestUtils.java
  test/java/
    com/example/app/  # Robolectric tests
      LoginActivityTest.java
```

### 2. Common Patterns

- **Use Page Object Model** for maintainable tests
- **Implement proper waits** instead of Thread.sleep()
- **Create reusable test utilities** for common actions
- **Use meaningful test names** that describe the scenario
- **Group related tests** in test suites
- **Mock external dependencies** in unit tests

This comprehensive setup guide provides everything needed to implement robust Android testing with Espresso, UI Automator, and Robolectric.