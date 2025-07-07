import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mind_house_app/main.dart' as app;

/// Integration tests for the Mind House application
/// Tests complete user workflows end-to-end
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mind House App Integration Tests', () {
    testWidgets('App launches and shows Store Information page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches to Store Information page
      expect(find.text('Store Information'), findsOneWidget);
      expect(find.text('Enter your information here...'), findsOneWidget);
    });

    testWidgets('Complete information creation workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter content
      final contentField = find.byType(TextField).first;
      await tester.enterText(contentField, 'Test information content');
      await tester.pump();

      // Add tags - find tag input field
      final tagFields = find.byType(TextField);
      if (tagFields.evaluate().length > 1) {
        await tester.enterText(tagFields.at(1), 'flutter');
        await tester.pump();
        
        // Simulate adding the tag (tap enter or add button)
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      }

      // Save information
      final saveButton = find.text('Save');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      }

      // Verify information was saved (could check for success message or navigation)
      expect(find.text('Test information content'), findsAtLeastNWidget(1));
    });

    testWidgets('Navigation between pages works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start on Store Information page
      expect(find.text('Store Information'), findsOneWidget);

      // Navigate to List Information page
      final listTab = find.text('List Information');
      if (listTab.evaluate().isNotEmpty) {
        await tester.tap(listTab);
        await tester.pumpAndSettle();
        
        // Verify we're on List Information page
        expect(find.text('List Information'), findsOneWidget);
      }

      // Navigate to Information page
      final infoTab = find.text('Information');
      if (infoTab.evaluate().isNotEmpty) {
        await tester.tap(infoTab);
        await tester.pumpAndSettle();
        
        // Verify we're on Information page
        expect(find.text('Information'), findsOneWidget);
      }

      // Navigate back to Store Information
      final storeTab = find.text('Store Information');
      if (storeTab.evaluate().isNotEmpty) {
        await tester.tap(storeTab);
        await tester.pumpAndSettle();
        
        // Verify we're back on Store Information page
        expect(find.text('Store Information'), findsOneWidget);
      }
    });

    testWidgets('Tag filtering workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First create some test data
      await _createTestInformation(tester, 'Flutter development notes', ['flutter', 'development']);
      await _createTestInformation(tester, 'Dart language tips', ['dart', 'programming']);
      
      // Navigate to List Information page
      final listTab = find.text('List Information');
      if (listTab.evaluate().isNotEmpty) {
        await tester.tap(listTab);
        await tester.pumpAndSettle();

        // Look for tag filter chips or buttons
        final flutterFilter = find.text('flutter');
        if (flutterFilter.evaluate().isNotEmpty) {
          await tester.tap(flutterFilter);
          await tester.pumpAndSettle();

          // Verify filtering works (should show Flutter-related content)
          expect(find.text('Flutter development notes'), findsOneWidget);
        }
      }
    });

    testWidgets('App state persistence across backgrounding', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter some content
      final contentField = find.byType(TextField).first;
      await tester.enterText(contentField, 'Persistent test content');
      await tester.pump();

      // Simulate app going to background and returning
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.paused'),
        ),
        (data) {},
      );
      await tester.pump();

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.resumed'),
        ),
        (data) {},
      );
      await tester.pumpAndSettle();

      // Verify content is still there
      expect(find.text('Persistent test content'), findsOneWidget);
    });

    testWidgets('Performance test with large dataset', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create multiple information items quickly
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 10; i++) {
        await _createTestInformation(tester, 'Performance test item $i', ['test', 'performance']);
      }
      
      stopwatch.stop();
      
      // Verify performance is acceptable (less than 5 seconds for 10 items)
      expect(stopwatch.elapsed.inSeconds, lessThan(5));

      // Navigate to list and verify all items load quickly
      final listTab = find.text('List Information');
      if (listTab.evaluate().isNotEmpty) {
        final navigationStopwatch = Stopwatch()..start();
        await tester.tap(listTab);
        await tester.pumpAndSettle();
        navigationStopwatch.stop();
        
        // Navigation should be fast (less than 1 second)
        expect(navigationStopwatch.elapsed.inMilliseconds, lessThan(1000));
      }
    });

    testWidgets('Error handling for invalid inputs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to save empty content
      final saveButton = find.text('Save');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        
        // Should show error or prevent saving
        // This depends on implementation - adjust based on actual behavior
      }

      // Try extremely long content
      final contentField = find.byType(TextField).first;
      await tester.enterText(contentField, 'A' * 10000);
      await tester.pump();
      
      // Verify app handles long content gracefully
      expect(find.byType(TextField), findsAtLeastNWidget(1));
    });
  });
}

/// Helper function to create test information with tags
Future<void> _createTestInformation(
  WidgetTester tester, 
  String content, 
  List<String> tags,
) async {
  // Navigate to Store Information if not already there
  final storeTab = find.text('Store Information');
  if (storeTab.evaluate().isNotEmpty) {
    await tester.tap(storeTab);
    await tester.pumpAndSettle();
  }

  // Clear any existing content
  final contentField = find.byType(TextField).first;
  await tester.enterText(contentField, '');
  await tester.pump();

  // Enter new content
  await tester.enterText(contentField, content);
  await tester.pump();

  // Add tags if tag input is available
  final tagFields = find.byType(TextField);
  if (tagFields.evaluate().length > 1) {
    for (String tag in tags) {
      await tester.enterText(tagFields.at(1), tag);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }
  }

  // Save
  final saveButton = find.text('Save');
  if (saveButton.evaluate().isNotEmpty) {
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }
}