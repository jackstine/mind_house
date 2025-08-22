# iOS Testing Setup Guide - XCUITest, Earl Grey & Best Practices

## Overview

This guide provides comprehensive setup instructions for iOS testing frameworks including XCUITest (Apple's official framework), Earl Grey (Google's framework), and modern testing practices for 2025.

## Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ target deployment
- macOS Ventura or later
- Swift 5.7+ or Objective-C
- Active Apple Developer Account (for device testing)

## XCUITest Setup

### 1. Creating UI Testing Target

1. **In Xcode**:
   - File → New → Target
   - Select "iOS UI Testing Bundle"
   - Configure target settings
   - Ensure target membership for test files

2. **Project Configuration**:

```swift
// In your main app target's Build Settings
ENABLE_TESTABILITY = YES (for Debug configuration)

// UI Testing Bundle Build Settings
TEST_HOST = $(BUILT_PRODUCTS_DIR)/YourApp.app/YourApp
BUNDLE_LOADER = $(TEST_HOST)
```

### 2. Basic XCUITest Structure

Create your first test file `LoginUITests.swift`:

```swift
import XCTest

final class LoginUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testLoginFlow() throws {
        // Wait for login screen to appear
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 5))
        
        // Enter credentials
        usernameField.tap()
        usernameField.typeText("testuser@example.com")
        
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Submit login
        app.buttons["loginButton"].tap()
        
        // Verify successful navigation
        let homeTitle = app.staticTexts["homeTitle"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 10))
        XCTAssertEqual(homeTitle.label, "Welcome Home")
    }
    
    func testLoginValidation() throws {
        let loginButton = app.buttons["loginButton"]
        
        // Test empty fields
        loginButton.tap()
        
        let errorAlert = app.alerts["errorAlert"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3))
        XCTAssertTrue(errorAlert.staticTexts["Please fill in all fields"].exists)
        
        errorAlert.buttons["OK"].tap()
    }
}
```

### 3. Accessibility Setup

In your SwiftUI views:

```swift
struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .accessibilityIdentifier("usernameField")
                .accessibilityLabel("Username input field")
            
            SecureField("Password", text: $password)
                .accessibilityIdentifier("passwordField")
                .accessibilityLabel("Password input field")
            
            Button("Login") {
                // Login action
            }
            .accessibilityIdentifier("loginButton")
            .accessibilityLabel("Login button")
        }
    }
}
```

For UIKit:

```swift
class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        usernameTextField.accessibilityIdentifier = "usernameField"
        passwordTextField.accessibilityIdentifier = "passwordField"
        loginButton.accessibilityIdentifier = "loginButton"
        
        usernameTextField.accessibilityLabel = "Username input field"
        passwordTextField.accessibilityLabel = "Password input field"
        loginButton.accessibilityLabel = "Login button"
    }
}
```

## Earl Grey Setup

### 1. Installation via CocoaPods

Add to your `Podfile`:

```ruby
platform :ios, '12.0'

target 'YourApp' do
  # Your app pods
end

target 'YourAppEarlGreyTests' do
  inherit! :search_paths
  pod 'EarlGrey', '~> 2.2'
end
```

### 2. Installation via Swift Package Manager

1. File → Add Package Dependencies
2. Enter: `https://github.com/google/EarlGrey`
3. Select version and add to test target

### 3. Basic Earl Grey Test

```swift
import XCTest
import EarlGrey

final class LoginEarlGreyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Launch the application
        let application = XCUIApplication()
        application.launch()
    }
    
    func testLoginWithEarlGrey() {
        // Earl Grey syntax
        EarlGrey.selectElement(with: grey_accessibilityID("usernameField"))
            .perform(grey_typeText("testuser@example.com"))
        
        EarlGrey.selectElement(with: grey_accessibilityID("passwordField"))
            .perform(grey_typeText("password123"))
        
        EarlGrey.selectElement(with: grey_accessibilityID("loginButton"))
            .perform(grey_tap())
        
        // Verify navigation with automatic synchronization
        EarlGrey.selectElement(with: grey_accessibilityID("homeTitle"))
            .assert(grey_sufficientlyVisible())
            .assert(grey_text("Welcome Home"))
    }
    
    func testFormValidation() {
        // Test empty submission
        EarlGrey.selectElement(with: grey_accessibilityID("loginButton"))
            .perform(grey_tap())
        
        // Earl Grey automatically waits for UI synchronization
        EarlGrey.selectElement(with: grey_text("Please fill in all fields"))
            .assert(grey_sufficientlyVisible())
    }
}
```

## Page Object Model Implementation

### 1. Base Page Protocol

```swift
protocol PageObject {
    var app: XCUIApplication { get }
    func waitForPageToLoad() -> Self
}

extension PageObject {
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func tapElement(withIdentifier identifier: String) {
        let element = app.buttons[identifier]
        XCTAssertTrue(waitForElement(element), "Element \(identifier) not found")
        element.tap()
    }
    
    func enterText(_ text: String, inFieldWithIdentifier identifier: String) {
        let field = app.textFields[identifier]
        XCTAssertTrue(waitForElement(field), "Text field \(identifier) not found")
        field.tap()
        field.typeText(text)
    }
}
```

### 2. Login Page Object

```swift
final class LoginPage: PageObject {
    let app: XCUIApplication
    
    // Elements
    private var usernameField: XCUIElement { app.textFields["usernameField"] }
    private var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    private var loginButton: XCUIElement { app.buttons["loginButton"] }
    private var errorAlert: XCUIElement { app.alerts["errorAlert"] }
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    @discardableResult
    func waitForPageToLoad() -> Self {
        XCTAssertTrue(waitForElement(usernameField), "Login page not loaded")
        return self
    }
    
    @discardableResult
    func enterUsername(_ username: String) -> Self {
        usernameField.tap()
        usernameField.typeText(username)
        return self
    }
    
    @discardableResult
    func enterPassword(_ password: String) -> Self {
        passwordField.tap()
        passwordField.typeText(password)
        return self
    }
    
    @discardableResult
    func tapLogin() -> Self {
        loginButton.tap()
        return self
    }
    
    func verifyErrorAlert(withMessage message: String) {
        XCTAssertTrue(waitForElement(errorAlert), "Error alert not shown")
        XCTAssertTrue(errorAlert.staticTexts[message].exists, "Expected error message not found")
    }
    
    func navigateToHome() -> HomePage {
        tapLogin()
        return HomePage(app: app).waitForPageToLoad()
    }
}
```

### 3. Using Page Objects in Tests

```swift
final class LoginFlowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testSuccessfulLogin() throws {
        let homePage = LoginPage(app: app)
            .waitForPageToLoad()
            .enterUsername("testuser@example.com")
            .enterPassword("password123")
            .navigateToHome()
        
        // Verify home page loaded
        XCTAssertTrue(homePage.isLoaded)
    }
    
    func testValidationError() throws {
        LoginPage(app: app)
            .waitForPageToLoad()
            .tapLogin()
            .verifyErrorAlert(withMessage: "Please fill in all fields")
    }
}
```

## Advanced Testing Patterns

### 1. Custom Matchers and Extensions

```swift
extension XCUIElement {
    func waitForExistenceAndTap(timeout: TimeInterval = 5) {
        XCTAssertTrue(self.waitForExistence(timeout: timeout))
        self.tap()
    }
    
    func clearAndTypeText(_ text: String) {
        self.tap()
        self.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        self.typeText(text)
    }
    
    var isVisible: Bool {
        return self.exists && self.isHittable
    }
}

// Custom predicates
extension NSPredicate {
    static func containsText(_ text: String) -> NSPredicate {
        return NSPredicate(format: "label CONTAINS[c] %@", text)
    }
    
    static func hasAccessibilityIdentifier(_ identifier: String) -> NSPredicate {
        return NSPredicate(format: "identifier == %@", identifier)
    }
}
```

### 2. Test Data Management

```swift
struct TestData {
    static let validCredentials = (
        username: "testuser@example.com",
        password: "validpassword"
    )
    
    static let invalidCredentials = (
        username: "invalid@example.com",
        password: "wrongpassword"
    )
    
    static func randomEmail() -> String {
        return "user\(Int.random(in: 1000...9999))@example.com"
    }
}

enum TestConfiguration {
    static let defaultTimeout: TimeInterval = 10
    static let shortTimeout: TimeInterval = 3
    static let longTimeout: TimeInterval = 30
}
```

### 3. Network Stubbing and Mocking

```swift
import Foundation

class NetworkStubbing {
    static func stubSuccessfulLogin() {
        // Configure URL session for testing
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  url.path.contains("/login") else {
                throw NetworkError.unsupportedURL
            }
            
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let data = """
            {
                "success": true,
                "token": "mock-token",
                "user": {
                    "id": "123",
                    "email": "testuser@example.com"
                }
            }
            """.data(using: .utf8)!
            
            return (response, data)
        }
    }
}
```

## Performance and Accessibility Testing

### 1. Performance Monitoring

```swift
func testAppLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

func testScrollingPerformance() throws {
    let app = XCUIApplication()
    app.launch()
    
    let table = app.tables["dataTable"]
    
    measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
        table.swipeUp()
        table.swipeDown()
    }
}
```

### 2. Accessibility Testing

```swift
func testAccessibilityCompliance() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Test VoiceOver accessibility
    XCTAssertTrue(app.buttons["loginButton"].isAccessibilityElement)
    XCTAssertNotNil(app.buttons["loginButton"].accessibilityLabel)
    XCTAssertNotNil(app.buttons["loginButton"].accessibilityHint)
    
    // Test dynamic type support
    app.textFields["usernameField"].adjust(toNormalizedSliderPosition: 1.0)
    XCTAssertTrue(app.textFields["usernameField"].frame.height > 44)
}
```

## CI/CD Integration

### 1. Xcode Cloud Configuration

Create `.xcode-cloud.yml`:

```yaml
version: 1
ci:
  xcode_version: "14.3"
  
workflows:
  ui-tests:
    name: UI Tests
    description: Run UI tests on simulator
    
    start_conditions:
      - on_pull_request_update:
          source_branch_patterns: ["*"]
      - on_push:
          branch_patterns: ["main", "develop"]
    
    actions:
      - name: Test
        action: test
        scheme: YourApp
        destination: platform=iOS Simulator,name=iPhone 14,OS=16.4
        test_plan: UITests
```

### 2. GitHub Actions

```yaml
name: iOS UI Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-13
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode version
      run: sudo xcode-select -s '/Applications/Xcode_14.3.app'
    
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: ~/Library/Developer/Xcode/DerivedData
        key: ${{ runner.os }}-xcode-${{ hashFiles('**/*.xcodeproj') }}
    
    - name: Install dependencies
      run: |
        if [ -f "Podfile" ]; then
          pod install
        fi
    
    - name: Run UI tests
      run: |
        xcodebuild test \
          -workspace YourApp.xcworkspace \
          -scheme YourApp \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' \
          -testPlan UITests \
          -resultBundlePath TestResults.xcresult
    
    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: TestResults.xcresult
```

## Best Practices Summary

### 1. Test Structure
- Use Page Object Model for maintainable tests
- Implement proper setup and teardown
- Group related tests in test classes
- Use descriptive test method names

### 2. Element Identification
- Prefer accessibility identifiers over text-based selectors
- Use consistent naming conventions
- Avoid fragile XPath-like selectors

### 3. Synchronization
- Always wait for elements before interaction
- Use appropriate timeout values
- Prefer XCUITest's built-in waits over manual delays

### 4. Test Data
- Use consistent test data across tests
- Implement data factories for complex objects
- Clean up test data after tests

### 5. CI/CD Integration
- Run tests in parallel when possible
- Use appropriate simulator configurations
- Store and analyze test artifacts

This comprehensive setup guide provides everything needed to implement robust iOS testing with XCUITest and Earl Grey frameworks.