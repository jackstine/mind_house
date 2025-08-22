# Mobile Development Tools Documentation

## Table of Contents
1. [React Native Testing Tools](#react-native-testing-tools)
2. [Native Android Tools](#native-android-tools)
3. [Native iOS Tools](#native-ios-tools)
4. [Cross-Platform Solutions](#cross-platform-solutions)
5. [Development Debugging Tools](#development-debugging-tools)
6. [Setup Guides](#setup-guides)
7. [Implementation Examples](#implementation-examples)

## React Native Testing Tools

### React Native Testing Library
**Best for:** Component testing, user interaction simulation

```bash
# Installation
npm install --save-dev @testing-library/react-native
npm install --save-dev @testing-library/jest-native
```

```javascript
// Setup jest.config.js
module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|react-clone-referenced-element|@react-native-community|@react-navigation)/)',
  ],
};
```

**Example Test:**
```javascript
// __tests__/MemoryCard.test.js
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import MemoryCard from '../src/components/MemoryCard';

describe('MemoryCard', () => {
  const mockMemory = {
    id: '1',
    title: 'Test Memory',
    content: 'Test content',
    tags: ['tag1', 'tag2'],
    createdAt: new Date().toISOString(),
  };

  it('renders memory information correctly', () => {
    const { getByText } = render(<MemoryCard memory={mockMemory} />);
    
    expect(getByText('Test Memory')).toBeTruthy();
    expect(getByText('Test content')).toBeTruthy();
    expect(getByText('tag1')).toBeTruthy();
  });

  it('calls onEdit when edit button is pressed', () => {
    const mockOnEdit = jest.fn();
    const { getByTestId } = render(
      <MemoryCard memory={mockMemory} onEdit={mockOnEdit} />
    );
    
    fireEvent.press(getByTestId('edit-button'));
    expect(mockOnEdit).toHaveBeenCalledWith(mockMemory);
  });
});
```

### Detox (E2E Testing)
**Best for:** End-to-end mobile app testing

```bash
# Installation
npm install detox --save-dev
npm install detox-cli --global
```

**Configuration:**
```json
// detox.config.js
module.exports = {
  testRunner: 'jest',
  runnerConfig: 'e2e/config.json',
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/MindHouse.app',
      build: 'xcodebuild -workspace ios/MindHouse.xcworkspace -scheme MindHouse -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build'
    },
    'android.debug': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/debug/app-debug.apk',
      build: 'cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug'
    }
  },
  devices: {
    simulator: {
      type: 'ios.simulator',
      device: { type: 'iPhone 14' }
    },
    emulator: {
      type: 'android.emulator',
      device: { avdName: 'Pixel_4_API_30' }
    }
  },
  configurations: {
    'ios.sim.debug': {
      device: 'simulator',
      app: 'ios.debug'
    },
    'android.emu.debug': {
      device: 'emulator',
      app: 'android.debug'
    }
  }
};
```

**Detox Test Example:**
```javascript
// e2e/MemoryFlow.e2e.js
describe('Memory Management Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should create a new memory', async () => {
    // Navigate to memory creation
    await element(by.id('add-memory-button')).tap();
    
    // Fill in memory details
    await element(by.id('memory-title-input')).typeText('E2E Test Memory');
    await element(by.id('memory-content-input')).typeText('This is an E2E test memory');
    
    // Add tags
    await element(by.id('tag-input')).typeText('automated');
    await element(by.id('add-tag-button')).tap();
    
    // Save memory
    await element(by.id('save-memory-button')).tap();
    
    // Verify memory was created
    await expect(element(by.text('E2E Test Memory'))).toBeVisible();
    await expect(element(by.text('automated'))).toBeVisible();
  });

  it('should edit an existing memory', async () => {
    // Tap on existing memory
    await element(by.text('E2E Test Memory')).tap();
    
    // Tap edit button
    await element(by.id('edit-memory-button')).tap();
    
    // Update title
    await element(by.id('memory-title-input')).clearText();
    await element(by.id('memory-title-input')).typeText('Updated E2E Memory');
    
    // Save changes
    await element(by.id('save-memory-button')).tap();
    
    // Verify update
    await expect(element(by.text('Updated E2E Memory'))).toBeVisible();
  });

  it('should handle network errors gracefully', async () => {
    // Simulate network failure
    await device.setURLBlacklist(['https://api.mindhouse.com/*']);
    
    // Try to sync memories
    await element(by.id('sync-button')).tap();
    
    // Verify error handling
    await expect(element(by.text('Sync failed. Please try again.'))).toBeVisible();
    
    // Clear blacklist
    await device.setURLBlacklist([]);
  });
});
```

## Native Android Tools

### Espresso (UI Testing)
**Best for:** Android UI testing with type safety

**Setup:**
```gradle
// app/build.gradle
android {
    defaultConfig {
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
}

dependencies {
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
    androidTestImplementation 'androidx.test.espresso:espresso-contrib:3.5.1'
    androidTestImplementation 'androidx.test:runner:1.5.2'
    androidTestImplementation 'androidx.test:rules:1.5.0'
}
```

**Example Test:**
```java
// MemoryActivityTest.java
@RunWith(AndroidJUnit4.class)
@LargeTest
public class MemoryActivityTest {

    @Rule
    public ActivityScenarioRule<MainActivity> activityRule = 
        new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void createMemory_DisplaysInList() {
        // Click add memory button
        onView(withId(R.id.add_memory_fab))
            .perform(click());

        // Fill in memory details
        onView(withId(R.id.memory_title_edit))
            .perform(typeText("Test Memory"), closeSoftKeyboard());
        
        onView(withId(R.id.memory_content_edit))
            .perform(typeText("Test content"), closeSoftKeyboard());

        // Add tag
        onView(withId(R.id.tag_input_edit))
            .perform(typeText("test"), pressImeActionButton());

        // Save memory
        onView(withId(R.id.save_memory_button))
            .perform(click());

        // Verify memory appears in list
        onView(withText("Test Memory"))
            .check(matches(isDisplayed()));
        
        onView(withText("test"))
            .check(matches(isDisplayed()));
    }

    @Test
    public void searchMemories_FiltersResults() {
        // Create test memories first
        createTestMemories();

        // Open search
        onView(withId(R.id.search_icon))
            .perform(click());

        // Type search query
        onView(withId(R.id.search_edit_text))
            .perform(typeText("important"), pressImeActionButton());

        // Verify filtered results
        onView(withText("Important Memory"))
            .check(matches(isDisplayed()));
        
        onView(withText("Regular Memory"))
            .check(doesNotExist());
    }

    private void createTestMemories() {
        // Helper method to create test data
        // Implementation depends on your data layer
    }
}
```

### UI Automator (System-level Testing)
**Best for:** Cross-app testing, system interactions

```java
// SystemInteractionTest.java
@RunWith(AndroidJUnit4.class)
public class SystemInteractionTest {
    
    private UiDevice device;

    @Before
    public void setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    }

    @Test
    public void shareMemory_OpensSystemShareDialog() throws UiObjectNotFoundException {
        // Launch app
        Context context = ApplicationProvider.getApplicationContext();
        Intent intent = context.getPackageManager()
            .getLaunchIntentForPackage("com.mindhouse.app");
        context.startActivity(intent);

        // Navigate to memory
        UiObject memoryItem = device.findObject(new UiSelector().text("Test Memory"));
        memoryItem.click();

        // Tap share button
        UiObject shareButton = device.findObject(new UiSelector().resourceId("com.mindhouse.app:id/share_button"));
        shareButton.click();

        // Verify system share dialog opens
        UiObject shareDialog = device.findObject(new UiSelector().textContains("Share"));
        assertTrue("Share dialog should be visible", shareDialog.exists());

        // Select sharing app (e.g., Gmail)
        UiObject gmailOption = device.findObject(new UiSelector().textContains("Gmail"));
        if (gmailOption.exists()) {
            gmailOption.click();
            
            // Verify Gmail opens with shared content
            UiObject gmailCompose = device.findObject(new UiSelector().packageName("com.google.android.gm"));
            assertTrue("Gmail should open", gmailCompose.exists());
        }
    }
}
```

### Robolectric (Unit Tests with Android Framework)
**Best for:** Unit testing with Android components

```gradle
// app/build.gradle
testImplementation 'org.robolectric:robolectric:4.10.3'
testImplementation 'androidx.test:core:1.5.0'
```

```java
// MemoryViewModelTest.java
@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class MemoryViewModelTest {

    private MemoryViewModel viewModel;
    private MemoryRepository mockRepository;

    @Before
    public void setUp() {
        mockRepository = mock(MemoryRepository.class);
        viewModel = new MemoryViewModel(mockRepository);
    }

    @Test
    public void loadMemories_UpdatesLiveData() {
        // Arrange
        List<Memory> testMemories = Arrays.asList(
            new Memory("1", "Memory 1", "Content 1", Arrays.asList("tag1")),
            new Memory("2", "Memory 2", "Content 2", Arrays.asList("tag2"))
        );
        when(mockRepository.getAllMemories()).thenReturn(LiveData.of(testMemories));

        // Act
        Observer<List<Memory>> observer = mock(Observer.class);
        viewModel.getMemories().observeForever(observer);
        viewModel.loadMemories();

        // Assert
        verify(observer).onChanged(testMemories);
        assertEquals(2, viewModel.getMemories().getValue().size());
    }

    @Test
    public void searchMemories_FiltersCorrectly() {
        // Test search functionality
        List<Memory> allMemories = createTestMemories();
        when(mockRepository.searchMemories("important"))
            .thenReturn(LiveData.of(filterMemories(allMemories, "important")));

        viewModel.searchMemories("important");

        List<Memory> searchResults = viewModel.getSearchResults().getValue();
        assertEquals(1, searchResults.size());
        assertEquals("Important Memory", searchResults.get(0).getTitle());
    }
}
```

## Native iOS Tools

### XCUITest (Apple's UI Testing Framework)
**Best for:** iOS native UI testing

```swift
// MemoryAppUITests.swift
import XCTest

class MemoryAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testCreateMemory() {
        // Tap add memory button
        app.buttons["addMemoryButton"].tap()
        
        // Fill in memory details
        let titleField = app.textFields["memoryTitleField"]
        titleField.tap()
        titleField.typeText("iOS Test Memory")
        
        let contentField = app.textViews["memoryContentField"]
        contentField.tap()
        contentField.typeText("This is a test memory from iOS")
        
        // Add tag
        let tagField = app.textFields["tagInputField"]
        tagField.tap()
        tagField.typeText("ios-test")
        app.buttons["addTagButton"].tap()
        
        // Save memory
        app.buttons["saveMemoryButton"].tap()
        
        // Verify memory was created
        XCTAssertTrue(app.staticTexts["iOS Test Memory"].exists)
        XCTAssertTrue(app.staticTexts["ios-test"].exists)
    }
    
    func testSearchMemories() {
        // Create test memories first
        createTestMemories()
        
        // Open search
        app.buttons["searchButton"].tap()
        
        // Type search query
        let searchField = app.searchFields["memorySearchField"]
        searchField.tap()
        searchField.typeText("important")
        
        // Wait for search results
        let importantMemory = app.staticTexts["Important Memory"]
        XCTAssertTrue(importantMemory.waitForExistence(timeout: 5))
        
        // Verify filtering
        XCTAssertTrue(importantMemory.exists)
        XCTAssertFalse(app.staticTexts["Regular Memory"].exists)
    }
    
    func testMemorySwipeActions() {
        // Swipe left on memory cell
        let memoryCell = app.cells["memoryCellTest Memory"]
        memoryCell.swipeLeft()
        
        // Verify swipe actions appear
        XCTAssertTrue(app.buttons["Delete"].exists)
        XCTAssertTrue(app.buttons["Share"].exists)
        
        // Test delete action
        app.buttons["Delete"].tap()
        
        // Confirm deletion
        app.alerts.buttons["Delete"].tap()
        
        // Verify memory is removed
        XCTAssertFalse(memoryCell.exists)
    }
    
    private func createTestMemories() {
        // Helper method to create test data
        // This would interact with your app's UI to create memories
        let memories = [
            ("Important Memory", "This is important", ["important"]),
            ("Regular Memory", "This is regular", ["regular"]),
        ]
        
        for (title, content, tags) in memories {
            app.buttons["addMemoryButton"].tap()
            
            app.textFields["memoryTitleField"].tap()
            app.textFields["memoryTitleField"].typeText(title)
            
            app.textViews["memoryContentField"].tap()
            app.textViews["memoryContentField"].typeText(content)
            
            for tag in tags {
                app.textFields["tagInputField"].tap()
                app.textFields["tagInputField"].typeText(tag)
                app.buttons["addTagButton"].tap()
            }
            
            app.buttons["saveMemoryButton"].tap()
        }
    }
}
```

### Earl Grey (Google's iOS UI Testing)
**Best for:** More flexible iOS UI testing

```objc
// MemoryAppEarlGreyTests.m
#import <EarlGrey/EarlGrey.h>
#import <XCTest/XCTest.h>

@interface MemoryAppEarlGreyTests : XCTestCase
@end

@implementation MemoryAppEarlGreyTests

- (void)setUp {
    [super setUp];
    [[EarlGrey selectElementWithMatcher:grey_systemAlertViewShown()]
        assertWithMatcher:grey_nil()];
}

- (void)testCreateAndEditMemory {
    // Create memory
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"addMemoryButton")]
        performAction:grey_tap()];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryTitleField")]
        performAction:grey_replaceText(@"Earl Grey Memory")];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryContentField")]
        performAction:grey_replaceText(@"Testing with Earl Grey")];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"saveMemoryButton")]
        performAction:grey_tap()];
    
    // Verify creation
    [[EarlGrey selectElementWithMatcher:grey_text(@"Earl Grey Memory")]
        assertWithMatcher:grey_sufficientlyVisible()];
    
    // Edit memory
    [[EarlGrey selectElementWithMatcher:grey_text(@"Earl Grey Memory")]
        performAction:grey_tap()];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"editMemoryButton")]
        performAction:grey_tap()];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryTitleField")]
        performAction:grey_replaceText(@"Updated Earl Grey Memory")];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"saveMemoryButton")]
        performAction:grey_tap()];
    
    // Verify update
    [[EarlGrey selectElementWithMatcher:grey_text(@"Updated Earl Grey Memory")]
        assertWithMatcher:grey_sufficientlyVisible()];
}

- (void)testMemoryListScrolling {
    // Create multiple memories for scrolling test
    for (int i = 0; i < 20; i++) {
        [self createTestMemoryWithIndex:i];
    }
    
    // Scroll to bottom
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryListTableView")]
        performAction:grey_scrollToContentEdge(kGREYContentEdgeBottom)];
    
    // Verify last item is visible
    [[EarlGrey selectElementWithMatcher:grey_text(@"Test Memory 19")]
        assertWithMatcher:grey_sufficientlyVisible()];
    
    // Scroll to top
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryListTableView")]
        performAction:grey_scrollToContentEdge(kGREYContentEdgeTop)];
    
    // Verify first item is visible
    [[EarlGrey selectElementWithMatcher:grey_text(@"Test Memory 0")]
        assertWithMatcher:grey_sufficientlyVisible()];
}

- (void)createTestMemoryWithIndex:(int)index {
    NSString *title = [NSString stringWithFormat:@"Test Memory %d", index];
    NSString *content = [NSString stringWithFormat:@"Content for memory %d", index];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"addMemoryButton")]
        performAction:grey_tap()];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryTitleField")]
        performAction:grey_replaceText(title)];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"memoryContentField")]
        performAction:grey_replaceText(content)];
    
    [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"saveMemoryButton")]
        performAction:grey_tap()];
}

@end
```

## Cross-Platform Solutions

### Appium (Universal Mobile Testing)
**Best for:** Testing multiple platforms with single codebase

**Setup:**
```bash
# Install Appium
npm install -g appium
appium driver install uiautomator2  # Android
appium driver install xcuitest      # iOS

# Install client libraries
npm install webdriverio @wdio/cli @wdio/local-runner
```

**Configuration:**
```javascript
// wdio.conf.js
exports.config = {
    runner: 'local',
    specs: ['./test/specs/**/*.js'],
    
    capabilities: [{
        platformName: 'iOS',
        'appium:platformVersion': '16.0',
        'appium:deviceName': 'iPhone 14',
        'appium:app': '/path/to/MindHouse.app',
        'appium:automationName': 'XCUITest'
    }, {
        platformName: 'Android',
        'appium:platformVersion': '13',
        'appium:deviceName': 'Pixel 4',
        'appium:app': '/path/to/app-debug.apk',
        'appium:automationName': 'UiAutomator2'
    }],
    
    services: ['appium'],
    framework: 'mocha',
    reporters: ['spec'],
    
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    }
};
```

**Cross-Platform Test:**
```javascript
// test/specs/memory.spec.js
describe('Memory Management', () => {
    const isIOS = driver.capabilities.platformName === 'iOS';
    const isAndroid = driver.capabilities.platformName === 'Android';
    
    const selectors = {
        addButton: isIOS ? '~addMemoryButton' : 'id:add_memory_fab',
        titleField: isIOS ? '~memoryTitleField' : 'id:memory_title_edit',
        contentField: isIOS ? '~memoryContentField' : 'id:memory_content_edit',
        saveButton: isIOS ? '~saveMemoryButton' : 'id:save_memory_button',
    };
    
    it('should create memory on both platforms', async () => {
        // Tap add button
        await $(selectors.addButton).click();
        
        // Fill in details
        await $(selectors.titleField).setValue('Cross-Platform Memory');
        await $(selectors.contentField).setValue('Works on iOS and Android');
        
        // Save memory
        await $(selectors.saveButton).click();
        
        // Verify creation
        const memoryTitle = isIOS ? 
            $('~Cross-Platform Memory') : 
            $('android=new UiSelector().text("Cross-Platform Memory")');
        
        await expect(memoryTitle).toBeDisplayed();
    });
    
    it('should handle platform-specific gestures', async () => {
        const memoryCell = isIOS ?
            $('~memoryCellCross-Platform Memory') :
            $('id:memory_card_Cross-Platform Memory');
        
        if (isIOS) {
            // iOS swipe gesture
            await memoryCell.touchAction([
                { action: 'press', x: 200, y: 100 },
                { action: 'moveTo', x: 50, y: 100 },
                { action: 'release' }
            ]);
        } else {
            // Android long press
            await memoryCell.touchAction('longPress');
        }
        
        // Verify context menu appears
        const deleteButton = isIOS ? 
            $('~Delete') : 
            $('id:delete_button');
        
        await expect(deleteButton).toBeDisplayed();
    });
});
```

### Firebase Test Lab
**Best for:** Cloud testing across multiple devices

```bash
# Upload and test Android APK
gcloud firebase test android run \
  --type instrumentation \
  --app app-debug.apk \
  --test app-debug-test.apk \
  --device model=Pixel2,version=28,locale=en,orientation=portrait \
  --device model=NexusLowRes,version=25,locale=en,orientation=portrait

# Test iOS IPA
gcloud firebase test ios run \
  --test MindHouseUITests.zip \
  --device model=iphone13pro,version=15.7,locale=en,orientation=portrait \
  --device model=ipad9,version=15.7,locale=en,orientation=portrait
```

## Development Debugging Tools

### React Native Debugger
```bash
# Install React Native Debugger
brew install --cask react-native-debugger

# For Windows/Linux
npm install -g react-native-debugger
```

**Configuration:**
```javascript
// Configure in your app
if (__DEV__) {
  import('./ReactotronConfig').then(() => console.log('Reactotron Configured'));
}

// ReactotronConfig.js
import Reactotron from 'reactotron-react-native';
import { reactotronRedux } from 'reactotron-redux';

const reactotron = Reactotron
  .configure({ name: 'MindHouse' })
  .useReactNative()
  .use(reactotronRedux())
  .connect();

export default reactotron;
```

### Flipper (Meta's Mobile Debugging Platform)
```bash
# Install Flipper
brew install --cask flipper

# Add to React Native project
npm install react-native-flipper --save-dev
```

### Android Studio Debugging
**Layout Inspector:**
- Real-time view hierarchy
- Performance profiling
- Memory analysis

**ADB Commands:**
```bash
# View logs
adb logcat | grep MindHouse

# Install APK
adb install app-debug.apk

# Take screenshot
adb exec-out screencap -p > screen.png

# Record screen
adb shell screenrecord /sdcard/recording.mp4
```

### Xcode Debugging Tools
**View Debugger:**
- 3D view hierarchy
- Constraint analysis
- Performance metrics

**Instruments:**
```bash
# Profile app performance
instruments -t "Time Profiler" -D trace.trace MindHouse.app

# Memory analysis
instruments -t "Allocations" -D allocations.trace MindHouse.app
```

## Implementation Examples

### Complete Test Suite Structure
```
tests/
├── unit/
│   ├── components/
│   │   ├── MemoryCard.test.js
│   │   └── TagInput.test.js
│   ├── services/
│   │   └── MemoryService.test.js
│   └── utils/
│       └── helpers.test.js
├── integration/
│   ├── api/
│   │   └── MemoryAPI.test.js
│   └── database/
│       └── MemoryDB.test.js
├── e2e/
│   ├── android/
│   │   └── MemoryFlow.test.js
│   ├── ios/
│   │   └── MemoryFlow.test.js
│   └── shared/
│       ├── pageObjects/
│       └── helpers/
└── performance/
    ├── LoadTesting.test.js
    └── MemoryLeaks.test.js
```

### Continuous Testing Pipeline
```yaml
# .github/workflows/mobile-tests.yml
name: Mobile Tests
on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run test:unit
      
  android-e2e:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '11'
      - run: npm ci
      - run: npx detox build --configuration android.emu.debug
      - run: npx detox test --configuration android.emu.debug
        
  ios-e2e:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: cd ios && pod install
      - run: npx detox build --configuration ios.sim.debug
      - run: npx detox test --configuration ios.sim.debug
```

This comprehensive guide provides everything needed to implement robust mobile testing across React Native, native Android, and native iOS platforms, with practical examples and debugging tools for the Mind House application.