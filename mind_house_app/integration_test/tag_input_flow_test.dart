import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mind_house_app/main.dart' as app;

/// Integration tests for tag input workflows
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tag Input Flow Integration Tests', () {
    testWidgets('Complete tag input workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on Store Information page
      expect(find.text('Store Information'), findsOneWidget);

      // Find tag input field
      final tagInputs = find.byType(TextField);
      expect(tagInputs.evaluate().length, greaterThan(1));
      
      final tagInput = tagInputs.at(1); // Second TextField should be tag input

      // Test basic tag addition
      await tester.enterText(tagInput, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify tag chip appears
      expect(find.text('flutter'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);

      // Add another tag
      await tester.enterText(tagInput, 'dart');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should have two tags now
      expect(find.text('dart'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));

      // Test tag removal
      final closeButtons = find.byIcon(Icons.close);
      if (closeButtons.evaluate().isNotEmpty) {
        await tester.tap(closeButtons.first);
        await tester.pumpAndSettle();
        
        // Should have one less tag
        expect(find.byType(Chip), findsOneWidget);
      }
    });

    testWidgets('Tag autocomplete and suggestion workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, add some tags to create a suggestion database
      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Add initial tags
      final initialTags = ['flutter', 'dart', 'mobile', 'development'];
      for (final tag in initialTags) {
        await tester.enterText(tagInput, tag);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Clear tags to test suggestions
      final closeButtons = find.byIcon(Icons.close);
      for (int i = 0; i < closeButtons.evaluate().length; i++) {
        await tester.tap(closeButtons.first);
        await tester.pumpAndSettle();
      }

      // Test autocomplete
      await tester.enterText(tagInput, 'fl');
      await tester.pump();

      // Should show suggestions containing 'flutter'
      // This depends on the actual implementation of suggestions
      await tester.pumpAndSettle();

      // Complete the tag
      await tester.enterText(tagInput, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('Tag input with special characters', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Test special characters
      final specialTags = ['c++', 'node.js', 'web-dev', 'ui/ux'];
      
      for (final tag in specialTags) {
        await tester.enterText(tagInput, tag);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        
        expect(find.text(tag), findsOneWidget);
      }

      expect(find.byType(Chip), findsNWidgets(specialTags.length));
    });

    testWidgets('Tag input with unicode and emoji', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Test unicode tags
      final unicodeTags = ['тег', '标签', '🏷️tag', 'café'];
      
      for (final tag in unicodeTags) {
        await tester.enterText(tagInput, tag);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        
        expect(find.text(tag), findsOneWidget);
      }

      expect(find.byType(Chip), findsNWidgets(unicodeTags.length));
    });

    testWidgets('Rapid tag input workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Rapidly add many tags
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 10; i++) {
        await tester.enterText(tagInput, 'tag$i');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should handle rapid input efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(Chip), findsNWidgets(10));
    });

    testWidgets('Tag input error handling', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Test empty tag submission
      await tester.enterText(tagInput, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should not add empty tag
      expect(find.byType(Chip), findsNothing);

      // Test whitespace-only tag
      await tester.enterText(tagInput, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should not add whitespace tag
      expect(find.byType(Chip), findsNothing);

      // Test duplicate tag prevention
      await tester.enterText(tagInput, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(tagInput, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should only have one tag
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('Tag persistence across app lifecycle', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Add some tags
      await tester.enterText(tagInput, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(tagInput, 'dart');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Simulate app going to background
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.paused'),
        ),
        (data) {},
      );
      await tester.pump();

      // Simulate app returning to foreground
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.resumed'),
        ),
        (data) {},
      );
      await tester.pumpAndSettle();

      // Tags should still be there
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('Tag input accessibility workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable accessibility testing
      final handle = tester.ensureSemantics();
      
      try {
        final tagInputs = find.byType(TextField);
        final tagInput = tagInputs.at(1);

        // Add tag using accessibility actions
        await tester.enterText(tagInput, 'accessible-tag');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Verify accessibility
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        expect(find.text('accessible-tag'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('Tag input performance with large dataset', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Add a large number of tags to test performance
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 50; i++) {
        await tester.enterText(tagInput, 'performance-tag-$i');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        
        // Only pump occasionally to test batching
        if (i % 10 == 0) {
          await tester.pump();
        }
      }
      
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should handle large number of tags efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // 15 seconds max
      expect(find.byType(Chip), findsNWidgets(50));
    });

    testWidgets('Tag input with navigation workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tagInputs = find.byType(TextField);
      final tagInput = tagInputs.at(1);

      // Add tags on Store Information page
      await tester.enterText(tagInput, 'navigation-test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Navigate to List Information page
      final listTab = find.text('List Information');
      if (listTab.evaluate().isNotEmpty) {
        await tester.tap(listTab);
        await tester.pumpAndSettle();
      }

      // Navigate back to Store Information
      final storeTab = find.text('Store Information');
      if (storeTab.evaluate().isNotEmpty) {
        await tester.tap(storeTab);
        await tester.pumpAndSettle();
      }

      // Tags should be preserved
      expect(find.text('navigation-test'), findsOneWidget);
    });
  });
}