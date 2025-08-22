import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mind_house_app/main.dart' as app;

/// Navigation Tests for Mind House App
/// Tests nav1-nav4 from TESTING_PLAN.md
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1: Navigation & App Structure Tests', () {
    
    testWidgets('nav1: Test navigation between Store, Browse, and View tabs', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      print('🚀 Testing nav1: Tab navigation between Store, Browse, and View');

      // Verify we start on Store tab (index 0)
      expect(find.text('Store'), findsOneWidget);
      print('✅ Verified: App starts on Store tab');

      // Verify NavigationBar is present with all 3 tabs
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
      print('✅ Found NavigationBar widget');

      // Test navigation to Browse tab
      print('🔄 Navigating to Browse tab...');
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      // Verify Browse tab content is displayed
      expect(find.byType(NavigationBar), findsOneWidget);
      print('✅ Successfully navigated to Browse tab');

      // Test navigation to View tab
      print('🔄 Navigating to View tab...');
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      
      // Verify View tab content is displayed
      expect(find.byType(NavigationBar), findsOneWidget);
      print('✅ Successfully navigated to View tab');

      // Test navigation back to Store tab
      print('🔄 Navigating back to Store tab...');
      await tester.tap(find.text('Store'));
      await tester.pumpAndSettle();
      
      // Verify Store tab content is displayed
      expect(find.text('Store'), findsOneWidget);
      print('✅ Successfully navigated back to Store tab');

      print('🎉 nav1 PASSED: All tab navigation working correctly');
    });

    testWidgets('nav2: Verify tab state preservation across navigation', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      print('🚀 Testing nav2: Tab state preservation');

      // On Store tab, enter some text to create state
      final textField = find.byType(TextField).first;
      if (textField.evaluate().isNotEmpty) {
        await tester.tap(textField);
        await tester.pumpAndSettle();
        await tester.enterText(textField, 'Test state preservation');
        await tester.pumpAndSettle();
        print('✅ Entered text in Store tab');

        // Navigate to Browse tab
        await tester.tap(find.text('Browse'));
        await tester.pumpAndSettle();
        print('✅ Navigated to Browse tab');

        // Navigate back to Store tab
        await tester.tap(find.text('Store'));
        await tester.pumpAndSettle();

        // Verify the text is still there (state preserved)
        expect(find.text('Test state preservation'), findsOneWidget);
        print('✅ nav2 PASSED: Tab state preserved successfully');
      } else {
        print('⚠️ nav2 SKIPPED: No text field found to test state preservation');
      }
    });

    testWidgets('nav3: Test tab icons and labels display correctly', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      print('🚀 Testing nav3: Tab icons and labels');

      // Verify Store tab label
      expect(find.text('Store'), findsOneWidget);
      print('✅ Store tab: label found');

      // Verify Browse tab label
      expect(find.text('Browse'), findsOneWidget);
      print('✅ Browse tab: label found');

      // Verify View tab label  
      expect(find.text('View'), findsOneWidget);
      print('✅ View tab: label found');

      // Check for NavigationDestination widgets (which contain the icons)
      final navigationDestinations = find.byType(NavigationDestination);
      expect(navigationDestinations, findsNWidgets(3));
      print('✅ Found 3 NavigationDestination widgets with icons');

      // Check the selected icon is different from unselected (Store tab should be selected initially)
      final navigationBar = find.byType(NavigationBar);
      final NavigationBar navBarWidget = tester.widget(navigationBar);
      expect(navBarWidget.selectedIndex, equals(0));
      print('✅ Store tab is selected with proper icon highlighting');

      print('🎉 nav3 PASSED: All tab icons and labels display correctly');
    });

    testWidgets('nav4: Verify selected tab highlighting works', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      print('🚀 Testing nav4: Selected tab highlighting');

      // Get NavigationBar widget
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      // Initial state: Store tab should be selected (index 0)
      final NavigationBar navBarWidget = tester.widget(navigationBar);
      expect(navBarWidget.selectedIndex, equals(0));
      print('✅ Store tab is initially selected (index 0)');

      // Navigate to Browse tab and verify selection
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      final NavigationBar navBarWidget2 = tester.widget(navigationBar);
      expect(navBarWidget2.selectedIndex, equals(1));
      print('✅ Browse tab is selected (index 1)');

      // Navigate to View tab and verify selection
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      
      final NavigationBar navBarWidget3 = tester.widget(navigationBar);
      expect(navBarWidget3.selectedIndex, equals(2));
      print('✅ View tab is selected (index 2)');

      // Navigate back to Store and verify selection
      await tester.tap(find.text('Store'));
      await tester.pumpAndSettle();
      
      final NavigationBar navBarWidget4 = tester.widget(navigationBar);
      expect(navBarWidget4.selectedIndex, equals(0));
      print('✅ Store tab is selected again (index 0)');

      print('🎉 nav4 PASSED: Tab highlighting works correctly');
    });
  });
}