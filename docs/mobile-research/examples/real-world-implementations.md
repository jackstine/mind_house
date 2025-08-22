# Real-World Mobile Testing Implementations

## Overview

This document provides practical, real-world examples of mobile testing implementations across different frameworks and platforms, showcasing production-ready patterns and best practices.

## React Native E2E Testing with Detox

### 1. E-commerce App Login & Checkout Flow

```javascript
// e2e/flows/checkoutFlow.e2e.js
const { device, expect, element, by, waitFor } = require('detox');

describe('E-commerce Checkout Flow', () => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      permissions: { location: 'always' }
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should complete full checkout process', async () => {
    // Login flow
    await waitFor(element(by.id('login-screen')))
      .toBeVisible()
      .withTimeout(10000);
    
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
    
    // Wait for home screen
    await waitFor(element(by.id('product-list')))
      .toBeVisible()
      .withTimeout(15000);
    
    // Add product to cart
    await element(by.id('product-item-0')).tap();
    await waitFor(element(by.id('product-detail')))
      .toBeVisible()
      .withTimeout(5000);
    
    await element(by.id('add-to-cart-button')).tap();
    await expect(element(by.text('Added to cart'))).toBeVisible();
    
    // Navigate to cart
    await element(by.id('cart-tab')).tap();
    await waitFor(element(by.id('cart-screen')))
      .toBeVisible()
      .withTimeout(5000);
    
    // Proceed to checkout
    await element(by.id('checkout-button')).tap();
    
    // Fill shipping information
    await waitFor(element(by.id('shipping-form')))
      .toBeVisible()
      .withTimeout(5000);
    
    await element(by.id('address-input')).typeText('123 Main St');
    await element(by.id('city-input')).typeText('New York');
    await element(by.id('zip-input')).typeText('10001');
    
    // Continue to payment
    await element(by.id('continue-to-payment')).tap();
    
    // Mock payment (in real app, would use test payment methods)
    await waitFor(element(by.id('payment-form')))
      .toBeVisible()
      .withTimeout(5000);
    
    await element(by.id('card-number-input')).typeText('4111111111111111');
    await element(by.id('expiry-input')).typeText('12/25');
    await element(by.id('cvv-input')).typeText('123');
    
    // Complete order
    await element(by.id('place-order-button')).tap();
    
    // Verify order confirmation
    await waitFor(element(by.id('order-confirmation')))
      .toBeVisible()
      .withTimeout(20000);
    
    await expect(element(by.text('Order confirmed!'))).toBeVisible();
    await expect(element(by.id('order-number'))).toBeVisible();
  });

  it('should handle network errors gracefully', async () => {
    // Simulate network failure
    await device.setURLBlacklist(['.*api.example.com.*']);
    
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
    
    // Verify error handling
    await waitFor(element(by.text('Network error. Please try again.')))
      .toBeVisible()
      .withTimeout(10000);
    
    // Clear blacklist
    await device.setURLBlacklist([]);
  });
});
```

### 2. Social Media App with Image Upload

```javascript
// e2e/flows/socialMediaFlow.e2e.js
describe('Social Media Post Creation', () => {
  it('should create post with image and tags', async () => {
    // Login
    await loginFlow('social_user@example.com', 'password123');
    
    // Navigate to create post
    await element(by.id('create-post-fab')).tap();
    
    // Add image
    await element(by.id('add-image-button')).tap();
    await element(by.text('Choose from Gallery')).tap();
    
    // Wait for image picker (platform-specific)
    if (device.getPlatform() === 'ios') {
      await element(by.label('Photo, Landscape, August 9, 2018, 2:17 PM')).tap();
      await element(by.label('Done')).tap();
    } else {
      await element(by.id('image-sample-1')).tap();
    }
    
    // Add caption
    await waitFor(element(by.id('caption-input')))
      .toBeVisible()
      .withTimeout(5000);
    
    await element(by.id('caption-input'))
      .typeText('Beautiful sunset! #nature #photography #blessed');
    
    // Add location
    await element(by.id('add-location-button')).tap();
    await element(by.id('location-search')).typeText('Central Park');
    await waitFor(element(by.text('Central Park, New York')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.text('Central Park, New York')).tap();
    
    // Publish post
    await element(by.id('publish-button')).tap();
    
    // Verify post appears in feed
    await waitFor(element(by.id('feed-screen')))
      .toBeVisible()
      .withTimeout(10000);
    
    await expect(element(by.text('Beautiful sunset! #nature #photography #blessed')))
      .toBeVisible();
    
    await expect(element(by.text('Central Park, New York')))
      .toBeVisible();
  });

  async function loginFlow(email, password) {
    await element(by.id('email-input')).typeText(email);
    await element(by.id('password-input')).typeText(password);
    await element(by.id('login-button')).tap();
    
    await waitFor(element(by.id('feed-screen')))
      .toBeVisible()
      .withTimeout(15000);
  }
});
```

## Android Native Testing with Espresso

### 1. Banking App with Biometric Authentication

```java
// BankingAppTest.java
@RunWith(AndroidJUnit4.class)
@LargeTest
public class BankingAppTest {

    @Rule
    public ActivityScenarioRule<MainActivity> activityRule = 
        new ActivityScenarioRule<>(MainActivity.class);

    @Rule
    public GrantPermissionRule permissionRule = 
        GrantPermissionRule.grant(Manifest.permission.USE_FINGERPRINT);

    private UiDevice device;

    @Before
    public void setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    }

    @Test
    public void testBiometricLogin() {
        // Navigate to login
        onView(withId(R.id.login_with_biometric_button))
            .perform(click());

        // Trigger biometric prompt
        onView(withText("Use your fingerprint to authenticate"))
            .check(matches(isDisplayed()));

        // Simulate successful biometric authentication
        // In real scenario, this would require device-specific setup
        device.pressKeyCode(KeyEvent.KEYCODE_ENTER);

        // Verify successful login
        onView(withId(R.id.account_balance_card))
            .check(matches(isDisplayed()));

        onView(withId(R.id.balance_amount))
            .check(matches(not(withText("****"))));
    }

    @Test
    public void testMoneyTransfer() {
        // Login first
        performLogin();

        // Navigate to transfer
        onView(withId(R.id.transfer_money_button))
            .perform(click());

        // Fill transfer form
        onView(withId(R.id.recipient_account_input))
            .perform(typeText("1234567890"), closeSoftKeyboard());

        onView(withId(R.id.transfer_amount_input))
            .perform(typeText("100.00"), closeSoftKeyboard());

        onView(withId(R.id.transfer_note_input))
            .perform(typeText("Lunch money"), closeSoftKeyboard());

        // Confirm transfer
        onView(withId(R.id.confirm_transfer_button))
            .perform(click());

        // Handle 2FA verification
        onView(withText("Enter verification code"))
            .check(matches(isDisplayed()));

        onView(withId(R.id.verification_code_input))
            .perform(typeText("123456"), closeSoftKeyboard());

        onView(withId(R.id.verify_button))
            .perform(click());

        // Wait for confirmation
        IdlingRegistry.getInstance().register(getTransferIdlingResource());
        
        onView(withText("Transfer completed successfully"))
            .check(matches(isDisplayed()));

        IdlingRegistry.getInstance().unregister(getTransferIdlingResource());

        // Verify balance updated
        onView(withId(R.id.balance_amount))
            .check(matches(not(withText(getCurrentBalance()))));
    }

    @Test
    public void testTransactionHistory() {
        performLogin();

        // Open transaction history
        onView(withId(R.id.transaction_history_button))
            .perform(click());

        // Wait for transactions to load
        onView(isRoot()).perform(waitForView(withId(R.id.transactions_recycler), 10000));

        // Verify transaction list
        onView(withId(R.id.transactions_recycler))
            .check(matches(isDisplayed()));

        // Test filtering
        onView(withId(R.id.filter_button))
            .perform(click());

        onView(withText("This Month"))
            .perform(click());

        // Verify filtered results
        onView(withId(R.id.transactions_recycler))
            .perform(RecyclerViewActions.actionOnItemAtPosition(0, click()));

        // Check transaction details
        onView(withId(R.id.transaction_detail_screen))
            .check(matches(isDisplayed()));
    }

    // Custom IdlingResource for async operations
    private IdlingResource getTransferIdlingResource() {
        return new ElapsedTimeIdlingResource(5000);
    }

    private void performLogin() {
        onView(withId(R.id.username_input))
            .perform(typeText("testuser"), closeSoftKeyboard());
        
        onView(withId(R.id.password_input))
            .perform(typeText("password123"), closeSoftKeyboard());
        
        onView(withId(R.id.login_button))
            .perform(click());

        // Wait for dashboard
        onView(withId(R.id.dashboard_layout))
            .check(matches(isDisplayed()));
    }

    private String getCurrentBalance() {
        // Implementation to get current balance for comparison
        return "1,234.56";
    }
}
```

### 2. Food Delivery App with Location Services

```java
// FoodDeliveryTest.java
@RunWith(AndroidJUnit4.class)
public class FoodDeliveryTest {

    @Rule
    public GrantPermissionRule locationPermission = 
        GrantPermissionRule.grant(Manifest.permission.ACCESS_FINE_LOCATION);

    @Rule
    public ActivityScenarioRule<MainActivity> activityRule = 
        new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void testOrderWithLocationTracking() {
        // Set mock location
        setMockLocation(40.7128, -74.0060); // NYC coordinates

        // Allow location permission if prompted
        handleLocationPermissionDialog();

        // Search for restaurants
        onView(withId(R.id.search_restaurants_input))
            .perform(typeText("pizza"), closeSoftKeyboard());

        onView(withId(R.id.search_button))
            .perform(click());

        // Select restaurant
        onView(withId(R.id.restaurants_recycler))
            .perform(RecyclerViewActions.actionOnItemAtPosition(0, click()));

        // Add items to cart
        onView(withId(R.id.menu_recycler))
            .perform(RecyclerViewActions.actionOnItemAtPosition(0, click()));

        onView(withId(R.id.add_to_cart_button))
            .perform(click());

        // Proceed to checkout
        onView(withId(R.id.cart_button))
            .perform(click());

        onView(withId(R.id.checkout_button))
            .perform(click());

        // Verify delivery address auto-populated
        onView(withId(R.id.delivery_address_text))
            .check(matches(containsString("New York")));

        // Place order
        onView(withId(R.id.place_order_button))
            .perform(click());

        // Verify order tracking screen
        onView(withId(R.id.order_tracking_screen))
            .check(matches(isDisplayed()));

        onView(withId(R.id.delivery_map))
            .check(matches(isDisplayed()));
    }

    private void setMockLocation(double latitude, double longitude) {
        // Implementation would depend on your testing setup
        // Could use MockLocationProvider or similar
    }

    private void handleLocationPermissionDialog() {
        UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        
        UiObject allowButton = device.findObject(new UiSelector()
            .textContains("Allow")
            .className("android.widget.Button"));
            
        if (allowButton.exists()) {
            try {
                allowButton.click();
            } catch (UiObjectNotFoundException e) {
                // Permission already granted
            }
        }
    }
}
```

## iOS Native Testing with XCUITest

### 1. Healthcare App with Complex Navigation

```swift
// HealthcareAppUITests.swift
final class HealthcareAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["UI_TESTING"]
        app.launch()
    }
    
    func testPatientRegistrationFlow() throws {
        // Start registration
        app.buttons["getStartedButton"].tap()
        app.buttons["registerNewPatient"].tap()
        
        // Personal Information
        let personalInfoForm = app.scrollViews["personalInfoForm"]
        XCTAssertTrue(personalInfoForm.waitForExistence(timeout: 5))
        
        personalInfoForm.textFields["firstNameField"].tap()
        personalInfoForm.textFields["firstNameField"].typeText("John")
        
        personalInfoForm.textFields["lastNameField"].tap()
        personalInfoForm.textFields["lastNameField"].typeText("Doe")
        
        personalInfoForm.textFields["emailField"].tap()
        personalInfoForm.textFields["emailField"].typeText("john.doe@example.com")
        
        personalInfoForm.textFields["phoneField"].tap()
        personalInfoForm.textFields["phoneField"].typeText("555-123-4567")
        
        // Date of birth
        personalInfoForm.buttons["dateOfBirthButton"].tap()
        
        let datePicker = app.datePickers["dateOfBirthPicker"]
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3))
        
        // Set date (January 1, 1990)
        datePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "January")
        datePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        datePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1990")
        
        app.buttons["Done"].tap()
        
        // Continue to medical history
        app.buttons["continueToMedicalHistory"].tap()
        
        // Medical History
        let medicalHistoryForm = app.scrollViews["medicalHistoryForm"]
        XCTAssertTrue(medicalHistoryForm.waitForExistence(timeout: 5))
        
        // Select allergies
        medicalHistoryForm.buttons["allergiesSection"].tap()
        medicalHistoryForm.buttons["penicillinAllergy"].tap()
        medicalHistoryForm.buttons["nutAllergy"].tap()
        
        // Add medical condition
        medicalHistoryForm.textFields["conditionsField"].tap()
        medicalHistoryForm.textFields["conditionsField"].typeText("Hypertension")
        
        // Continue to insurance
        app.buttons["continueToInsurance"].tap()
        
        // Insurance Information
        let insuranceForm = app.scrollViews["insuranceForm"]
        XCTAssertTrue(insuranceForm.waitForExistence(timeout: 5))
        
        insuranceForm.textFields["insuranceProviderField"].tap()
        insuranceForm.textFields["insuranceProviderField"].typeText("Blue Cross")
        
        insuranceForm.textFields["policyNumberField"].tap()
        insuranceForm.textFields["policyNumberField"].typeText("BC123456789")
        
        // Complete registration
        app.buttons["completeRegistration"].tap()
        
        // Handle biometric setup prompt
        let biometricAlert = app.alerts["biometricSetupAlert"]
        if biometricAlert.waitForExistence(timeout: 3) {
            biometricAlert.buttons["Set Up Later"].tap()
        }
        
        // Verify successful registration
        let welcomeScreen = app.scrollViews["welcomeScreen"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 10))
        
        let welcomeMessage = app.staticTexts["Welcome, John!"]
        XCTAssertTrue(welcomeMessage.exists)
        
        // Verify navigation to dashboard
        XCTAssertTrue(app.tabBars["mainTabBar"].exists)
        XCTAssertTrue(app.buttons["appointmentsTab"].exists)
        XCTAssertTrue(app.buttons["recordsTab"].exists)
    }
    
    func testAppointmentBooking() throws {
        // Login first
        performLogin(email: "john.doe@example.com", password: "TestPassword123!")
        
        // Navigate to appointments
        app.tabBars.buttons["appointmentsTab"].tap()
        
        // Book new appointment
        app.buttons["bookAppointmentButton"].tap()
        
        // Select doctor
        let doctorsList = app.tables["doctorsList"]
        XCTAssertTrue(doctorsList.waitForExistence(timeout: 5))
        
        doctorsList.cells.containing(.staticText, identifier: "Dr. Sarah Johnson").element.tap()
        
        // Select appointment type
        app.buttons["routineCheckup"].tap()
        
        // Select date and time
        app.buttons["selectDateTimeButton"].tap()
        
        let calendar = app.collectionViews["calendarView"]
        XCTAssertTrue(calendar.waitForExistence(timeout: 5))
        
        // Select tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let dayString = dayFormatter.string(from: tomorrow)
        
        calendar.buttons[dayString].tap()
        
        // Select time slot
        let timeSlots = app.collectionViews["timeSlotsView"]
        XCTAssertTrue(timeSlots.waitForExistence(timeout: 3))
        
        timeSlots.buttons["10:00 AM"].tap()
        
        // Add appointment notes
        app.textViews["appointmentNotesField"].tap()
        app.textViews["appointmentNotesField"].typeText("Routine annual checkup")
        
        // Confirm booking
        app.buttons["confirmBookingButton"].tap()
        
        // Verify confirmation
        let confirmationAlert = app.alerts["appointmentConfirmation"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 5))
        
        XCTAssertTrue(confirmationAlert.staticTexts["Your appointment has been booked"].exists)
        confirmationAlert.buttons["OK"].tap()
        
        // Verify appointment appears in list
        let appointmentCell = doctorsList.cells.containing(.staticText, identifier: "Dr. Sarah Johnson")
        XCTAssertTrue(appointmentCell.element.exists)
    }
    
    private func performLogin(email: String, password: String) {
        let emailField = app.textFields["emailLoginField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        
        emailField.tap()
        emailField.typeText(email)
        
        app.secureTextFields["passwordLoginField"].tap()
        app.secureTextFields["passwordLoginField"].typeText(password)
        
        app.buttons["loginButton"].tap()
        
        // Wait for dashboard
        let dashboard = app.tabBars["mainTabBar"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 10))
    }
}
```

### 2. Financial App with Complex Interactions

```swift
// FinancialAppUITests.swift
final class FinancialAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DISABLE_ANIMATIONS"]
        app.launch()
    }
    
    func testInvestmentPortfolioManagement() throws {
        // Authenticate
        authenticateWithBiometrics()
        
        // Navigate to portfolio
        app.tabBars.buttons["portfolioTab"].tap()
        
        let portfolioView = app.scrollViews["portfolioView"]
        XCTAssertTrue(portfolioView.waitForExistence(timeout: 5))
        
        // Verify portfolio summary
        XCTAssertTrue(app.staticTexts["totalValue"].exists)
        XCTAssertTrue(app.staticTexts["dayChange"].exists)
        
        // View stock details
        let stocksList = app.tables["stocksList"]
        let appleStock = stocksList.cells.containing(.staticText, identifier: "AAPL")
        appleStock.element.tap()
        
        // Verify stock detail screen
        let stockDetailView = app.scrollViews["stockDetailView"]
        XCTAssertTrue(stockDetailView.waitForExistence(timeout: 5))
        
        // Check chart interaction
        let stockChart = app.otherElements["stockChart"]
        XCTAssertTrue(stockChart.exists)
        
        // Test chart zoom
        stockChart.pinch(withScale: 2.0, velocity: 1.0)
        
        // Change time period
        app.segmentedControls["timePeriodControl"].buttons["1Y"].tap()
        
        // Buy more shares
        app.buttons["buyButton"].tap()
        
        let buyOrderView = app.scrollViews["buyOrderView"]
        XCTAssertTrue(buyOrderView.waitForExistence(timeout: 3))
        
        // Enter order details
        buyOrderView.textFields["quantityField"].tap()
        buyOrderView.textFields["quantityField"].typeText("10")
        
        // Select order type
        buyOrderView.buttons["orderTypeButton"].tap()
        
        let orderTypeSheet = app.sheets["orderTypeSheet"]
        orderTypeSheet.buttons["Limit Order"].tap()
        
        // Set limit price
        buyOrderView.textFields["limitPriceField"].tap()
        buyOrderView.textFields["limitPriceField"].typeText("150.00")
        
        // Review order
        app.buttons["reviewOrderButton"].tap()
        
        let orderReviewView = app.scrollViews["orderReviewView"]
        XCTAssertTrue(orderReviewView.waitForExistence(timeout: 3))
        
        // Verify order details
        XCTAssertTrue(orderReviewView.staticTexts["10 shares"].exists)
        XCTAssertTrue(orderReviewView.staticTexts["$150.00"].exists)
        
        // Place order
        app.buttons["placeOrderButton"].tap()
        
        // Handle 2FA if required
        let authAlert = app.alerts["2FARequired"]
        if authAlert.waitForExistence(timeout: 3) {
            let codeField = authAlert.textFields["authCodeField"]
            codeField.typeText("123456")
            authAlert.buttons["Verify"].tap()
        }
        
        // Verify order confirmation
        let confirmationView = app.scrollViews["orderConfirmationView"]
        XCTAssertTrue(confirmationView.waitForExistence(timeout: 10))
        
        XCTAssertTrue(app.staticTexts["Order Placed Successfully"].exists)
    }
    
    func testBudgetingFeature() throws {
        authenticateWithBiometrics()
        
        // Navigate to budgeting
        app.tabBars.buttons["budgetTab"].tap()
        
        let budgetView = app.scrollViews["budgetView"]
        XCTAssertTrue(budgetView.waitForExistence(timeout: 5))
        
        // Create new budget category
        app.buttons["addCategoryButton"].tap()
        
        let newCategoryView = app.scrollViews["newCategoryView"]
        XCTAssertTrue(newCategoryView.waitForExistence(timeout: 3))
        
        // Set category details
        newCategoryView.textFields["categoryNameField"].tap()
        newCategoryView.textFields["categoryNameField"].typeText("Entertainment")
        
        newCategoryView.textFields["budgetAmountField"].tap()
        newCategoryView.textFields["budgetAmountField"].typeText("200")
        
        // Select category color
        let colorPicker = app.collectionViews["colorPicker"]
        colorPicker.cells.element(boundBy: 2).tap()
        
        // Set spending alerts
        app.switches["alertsSwitch"].tap()
        
        let alertSlider = app.sliders["alertPercentageSlider"]
        alertSlider.adjust(toNormalizedSliderPosition: 0.8) // 80%
        
        // Save category
        app.buttons["saveCategoryButton"].tap()
        
        // Verify category appears in list
        let categoriesList = app.tables["categoriesList"]
        XCTAssertTrue(categoriesList.cells.containing(.staticText, identifier: "Entertainment").element.exists)
        
        // Test budget tracking
        let entertainmentCategory = categoriesList.cells.containing(.staticText, identifier: "Entertainment").element
        entertainmentCategory.tap()
        
        let categoryDetailView = app.scrollViews["categoryDetailView"]
        XCTAssertTrue(categoryDetailView.waitForExistence(timeout: 3))
        
        // View spending chart
        XCTAssertTrue(app.otherElements["spendingChart"].exists)
        
        // Add manual expense
        app.buttons["addExpenseButton"].tap()
        
        let expenseView = app.scrollViews["expenseView"]
        expenseView.textFields["amountField"].tap()
        expenseView.textFields["amountField"].typeText("25.50")
        
        expenseView.textFields["descriptionField"].tap()
        expenseView.textFields["descriptionField"].typeText("Movie tickets")
        
        app.buttons["saveExpenseButton"].tap()
        
        // Verify expense added
        let expensesList = app.tables["expensesList"]
        XCTAssertTrue(expensesList.cells.containing(.staticText, identifier: "Movie tickets").element.exists)
    }
    
    private func authenticateWithBiometrics() {
        let biometricButton = app.buttons["biometricAuthButton"]
        if biometricButton.waitForExistence(timeout: 5) {
            biometricButton.tap()
            
            // Simulate successful biometric authentication
            // In real testing, this would require device configuration
            if app.alerts["Touch ID"].waitForExistence(timeout: 3) {
                app.alerts["Touch ID"].buttons["OK"].tap()
            }
        }
    }
}
```

## Cross-Platform Testing with Appium

### 1. Ride-Sharing App Implementation

```python
# test_ride_sharing.py
import pytest
from appium import webdriver
from appium.webdriver.common.mobileby import MobileBy
from appium.webdriver.common.touch_action import TouchAction
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

class TestRideSharingApp:
    
    @pytest.fixture(scope="function")
    def driver(self, platform):
        if platform == "ios":
            capabilities = {
                'platformName': 'iOS',
                'platformVersion': '16.4',
                'deviceName': 'iPhone 14',
                'bundleId': 'com.example.rideshare',
                'automationName': 'XCUITest'
            }
        else:  # Android
            capabilities = {
                'platformName': 'Android',
                'platformVersion': '13',
                'deviceName': 'Pixel_6_API_33',
                'appPackage': 'com.example.rideshare',
                'appActivity': '.MainActivity',
                'automationName': 'UiAutomator2'
            }
        
        driver = webdriver.Remote('http://localhost:4723/wd/hub', capabilities)
        driver.implicitly_wait(10)
        yield driver
        driver.quit()
    
    def test_complete_ride_booking_flow(self, driver, platform):
        # Handle location permission
        self._handle_location_permission(driver, platform)
        
        # Set pickup location
        pickup_field = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeTextField[@name="pickupLocationField"]',
            'android': 'com.example.rideshare:id/pickup_location_field'
        })
        pickup_field.click()
        pickup_field.send_keys("123 Main Street, New York")
        
        # Select from suggestions
        suggestion = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeCell[contains(@name, "123 Main Street")]',
            'android': '//android.widget.TextView[contains(@text, "123 Main Street")]'
        })
        suggestion.click()
        
        # Set destination
        destination_field = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeTextField[@name="destinationField"]',
            'android': 'com.example.rideshare:id/destination_field'
        })
        destination_field.click()
        destination_field.send_keys("456 Park Avenue, New York")
        
        # Select destination suggestion
        dest_suggestion = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeCell[contains(@name, "456 Park Avenue")]',
            'android': '//android.widget.TextView[contains(@text, "456 Park Avenue")]'
        })
        dest_suggestion.click()
        
        # Select ride type
        ride_type_button = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="rideTypeStandard"]',
            'android': 'com.example.rideshare:id/ride_type_standard'
        })
        ride_type_button.click()
        
        # Book ride
        book_button = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="bookRideButton"]',
            'android': 'com.example.rideshare:id/book_ride_button'
        })
        book_button.click()
        
        # Handle payment method selection if needed
        self._handle_payment_selection(driver, platform)
        
        # Wait for driver matching
        driver_found_element = WebDriverWait(driver, 60).until(
            EC.presence_of_element_located((
                MobileBy.XPATH,
                self._get_selector(platform, {
                    'ios': '//XCUIElementTypeStaticText[@name="driverFoundMessage"]',
                    'android': '//android.widget.TextView[@resource-id="com.example.rideshare:id/driver_found_message"]'
                })
            ))
        )
        
        assert "Driver found" in driver_found_element.text
        
        # Verify driver details displayed
        driver_name = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeStaticText[@name="driverName"]',
            'android': 'com.example.rideshare:id/driver_name'
        })
        assert driver_name.text is not None
        
        # Verify car details
        car_info = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeStaticText[@name="carInfo"]',
            'android': 'com.example.rideshare:id/car_info'
        })
        assert car_info.text is not None
        
        # Test ride tracking
        tracking_map = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeOther[@name="trackingMap"]',
            'android': 'com.example.rideshare:id/tracking_map'
        })
        assert tracking_map.is_displayed()
    
    def test_ride_cancellation(self, driver, platform):
        # Book a ride first (simplified)
        self._quick_book_ride(driver, platform)
        
        # Cancel the ride
        cancel_button = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="cancelRideButton"]',
            'android': 'com.example.rideshare:id/cancel_ride_button'
        })
        cancel_button.click()
        
        # Confirm cancellation
        confirm_cancel = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="confirmCancelButton"]',
            'android': 'com.example.rideshare:id/confirm_cancel_button'
        })
        confirm_cancel.click()
        
        # Verify cancellation message
        cancellation_message = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((
                MobileBy.XPATH,
                self._get_selector(platform, {
                    'ios': '//XCUIElementTypeStaticText[contains(@name, "cancelled")]',
                    'android': '//android.widget.TextView[contains(@text, "cancelled")]'
                })
            ))
        )
        
        assert "cancelled" in cancellation_message.text.lower()
    
    def test_fare_estimation(self, driver, platform):
        # Set locations
        self._set_pickup_destination(driver, platform, 
                                   "Times Square, New York", 
                                   "Central Park, New York")
        
        # View fare estimate
        fare_estimate_button = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="viewFareEstimate"]',
            'android': 'com.example.rideshare:id/view_fare_estimate'
        })
        fare_estimate_button.click()
        
        # Verify fare details
        fare_amount = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeStaticText[@name="fareAmount"]',
            'android': 'com.example.rideshare:id/fare_amount'
        })
        
        assert "$" in fare_amount.text
        assert float(fare_amount.text.replace("$", "")) > 0
        
        # Check fare breakdown
        fare_breakdown = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="fareBreakdown"]',
            'android': 'com.example.rideshare:id/fare_breakdown_button'
        })
        fare_breakdown.click()
        
        # Verify breakdown components
        base_fare = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeStaticText[@name="baseFare"]',
            'android': 'com.example.rideshare:id/base_fare'
        })
        assert base_fare.is_displayed()
    
    # Helper methods
    def _find_element(self, driver, platform, selectors):
        selector = selectors[platform]
        if platform == "ios" or selector.startswith("//"):
            return driver.find_element(MobileBy.XPATH, selector)
        else:
            return driver.find_element(MobileBy.ID, selector)
    
    def _get_selector(self, platform, selectors):
        return selectors[platform]
    
    def _handle_location_permission(self, driver, platform):
        try:
            if platform == "ios":
                allow_button = WebDriverWait(driver, 5).until(
                    EC.presence_of_element_located((MobileBy.XPATH, '//XCUIElementTypeButton[@name="Allow While Using App"]'))
                )
                allow_button.click()
            else:
                allow_button = WebDriverWait(driver, 5).until(
                    EC.presence_of_element_located((MobileBy.XPATH, '//android.widget.Button[contains(@text, "ALLOW")]'))
                )
                allow_button.click()
        except:
            pass  # Permission already granted or not needed
    
    def _handle_payment_selection(self, driver, platform):
        try:
            add_payment_button = self._find_element(driver, platform, {
                'ios': '//XCUIElementTypeButton[@name="addPaymentMethod"]',
                'android': 'com.example.rideshare:id/add_payment_method'
            })
            if add_payment_button.is_displayed():
                add_payment_button.click()
                
                # Select credit card
                credit_card_option = self._find_element(driver, platform, {
                    'ios': '//XCUIElementTypeButton[@name="creditCardOption"]',
                    'android': 'com.example.rideshare:id/credit_card_option'
                })
                credit_card_option.click()
                
                # Add test card details
                card_number_field = self._find_element(driver, platform, {
                    'ios': '//XCUIElementTypeTextField[@name="cardNumber"]',
                    'android': 'com.example.rideshare:id/card_number'
                })
                card_number_field.send_keys("4111111111111111")
                
                # Add expiry
                expiry_field = self._find_element(driver, platform, {
                    'ios': '//XCUIElementTypeTextField[@name="expiryDate"]',
                    'android': 'com.example.rideshare:id/expiry_date'
                })
                expiry_field.send_keys("12/25")
                
                # Save payment method
                save_button = self._find_element(driver, platform, {
                    'ios': '//XCUIElementTypeButton[@name="savePaymentMethod"]',
                    'android': 'com.example.rideshare:id/save_payment_method'
                })
                save_button.click()
        except:
            pass  # Payment method already exists
    
    def _quick_book_ride(self, driver, platform):
        # Simplified booking for test setup
        self._set_pickup_destination(driver, platform,
                                   "Current Location",
                                   "Nearby Location")
        
        book_button = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeButton[@name="bookRideButton"]',
            'android': 'com.example.rideshare:id/book_ride_button'
        })
        book_button.click()
    
    def _set_pickup_destination(self, driver, platform, pickup, destination):
        pickup_field = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeTextField[@name="pickupLocationField"]',
            'android': 'com.example.rideshare:id/pickup_location_field'
        })
        pickup_field.click()
        pickup_field.send_keys(pickup)
        
        # Select first suggestion
        time.sleep(2)  # Wait for suggestions
        suggestion = driver.find_elements(MobileBy.XPATH, 
            '//android.widget.TextView' if platform == 'android' 
            else '//XCUIElementTypeCell')[0]
        suggestion.click()
        
        # Set destination
        dest_field = self._find_element(driver, platform, {
            'ios': '//XCUIElementTypeTextField[@name="destinationField"]',
            'android': 'com.example.rideshare:id/destination_field'
        })
        dest_field.click()
        dest_field.send_keys(destination)
        
        # Select first destination suggestion
        time.sleep(2)
        dest_suggestion = driver.find_elements(MobileBy.XPATH, 
            '//android.widget.TextView' if platform == 'android' 
            else '//XCUIElementTypeCell')[0]
        dest_suggestion.click()

# Pytest configuration
@pytest.fixture(params=["ios", "android"])
def platform(request):
    return request.param
```

## Performance Testing Examples

### 1. React Native Performance Testing

```javascript
// e2e/performance/performanceTest.e2e.js
const { device, expect, element, by } = require('detox');

describe('Performance Tests', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should maintain smooth scrolling performance', async () => {
    await element(by.id('large-list-screen')).tap();
    
    // Measure scroll performance
    const startTime = Date.now();
    
    for (let i = 0; i < 10; i++) {
      await element(by.id('large-list')).scroll(300, 'down');
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    
    const endTime = Date.now();
    const totalTime = endTime - startTime;
    
    // Should complete scrolling within reasonable time
    expect(totalTime).toBeLessThan(5000);
  });

  it('should handle memory intensive operations', async () => {
    await element(by.id('image-gallery-screen')).tap();
    
    // Load many images
    for (let i = 0; i < 20; i++) {
      await element(by.id(`image-${i}`)).tap();
      await element(by.id('close-image')).tap();
    }
    
    // App should remain responsive
    await expect(element(by.id('gallery-title'))).toBeVisible();
  });
});
```

This comprehensive collection of real-world implementations demonstrates practical testing approaches across different mobile platforms and frameworks, showcasing production-ready patterns that can be adapted to various application types.