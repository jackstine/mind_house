import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/widgets/tag_input.dart';
import 'package:mind_house_app/models/tag.dart';
import '../helpers/test_utilities.dart';
import '../helpers/test_data_factory.dart';

/// Widget tests for TagInput component
void main() {
  group('TagInput Widget Tests', () {
    testWidgets('should display text field for tag input', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) {},
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display hint text correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            hintText: 'Enter tag name',
            onTagAdded: (tag) {},
          ),
        ),
      );

      expect(find.text('Enter tag name'), findsOneWidget);
    });

    testWidgets('should call onTagAdded when tag is submitted', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, equals('flutter'));
    });

    testWidgets('should clear text field after tag is added', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should show suggestions when available', (tester) async {
      final suggestions = TestDataFactory.createTagList(3);

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            suggestions: suggestions,
            onTagAdded: (tag) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'fl');
      await tester.pump();

      // Should show suggestion list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should filter suggestions based on input', (tester) async {
      final suggestions = [
        TestDataFactory.createTag(name: 'flutter', displayName: 'Flutter'),
        TestDataFactory.createTag(name: 'dart', displayName: 'Dart'),
        TestDataFactory.createTag(name: 'firebase', displayName: 'Firebase'),
      ];

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            suggestions: suggestions,
            onTagAdded: (tag) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'fl');
      await tester.pump();

      // Should only show flutter suggestion
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsNothing);
      expect(find.text('Firebase'), findsNothing);
    });

    testWidgets('should select suggestion when tapped', (tester) async {
      String? selectedTag;
      final suggestions = [
        TestDataFactory.createTag(name: 'flutter', displayName: 'Flutter'),
      ];

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            suggestions: suggestions,
            onTagAdded: (tag) => selectedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'fl');
      await tester.pump();

      await tester.tap(find.text('Flutter'));
      await tester.pump();

      expect(selectedTag, equals('flutter'));
    });

    testWidgets('should handle empty input gracefully', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, isNull);
    });

    testWidgets('should handle whitespace-only input gracefully', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, isNull);
    });

    testWidgets('should trim whitespace from input', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  flutter  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, equals('flutter'));
    });

    testWidgets('should handle special characters in input', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'c++');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, equals('c++'));
    });

    testWidgets('should handle unicode characters', (tester) async {
      String? addedTag;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'тег');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, equals('тег'));
    });

    testWidgets('should handle long input correctly', (tester) async {
      String? addedTag;
      final longInput = 'a' * 100;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) => addedTag = tag,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), longInput);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(addedTag, equals(longInput));
    });

    testWidgets('should show selected tags as chips', (tester) async {
      final selectedTags = TestDataFactory.createTagList(2);

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            selectedTags: selectedTags,
            onTagAdded: (tag) {},
            onTagRemoved: (tag) {},
          ),
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('should remove tag when chip delete is tapped', (tester) async {
      String? removedTag;
      final selectedTags = [
        TestDataFactory.createTag(name: 'flutter', displayName: 'Flutter'),
      ];

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            selectedTags: selectedTags,
            onTagAdded: (tag) {},
            onTagRemoved: (tag) => removedTag = tag,
          ),
        ),
      );

      // Find and tap the delete button on the chip
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(removedTag, equals('flutter'));
    });

    testWidgets('should provide accessibility support', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            onTagAdded: (tag) {},
          ),
        ),
      );

      await TestUtilities.verifyAccessibility(tester);
    });

    testWidgets('should handle rapid input changes', (tester) async {
      final suggestions = TestDataFactory.createTagList(10);

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagInput(
            suggestions: suggestions,
            onTagAdded: (tag) {},
          ),
        ),
      );

      // Rapid input changes
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextField), 'test$i');
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(tester.takeException(), isNull);
    });

    group('Debouncing', () {
      testWidgets('should debounce suggestion requests', (tester) async {
        int requestCount = 0;
        
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagInput(
              onTagAdded: (tag) {},
              onSuggestionRequested: (query) {
                requestCount++;
                return [];
              },
            ),
          ),
        );

        // Rapid typing
        await tester.enterText(find.byType(TextField), 'f');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.enterText(find.byType(TextField), 'fl');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.enterText(find.byType(TextField), 'flu');
        await tester.pump(const Duration(milliseconds: 50));

        // Should debounce requests
        expect(requestCount, lessThan(3));
      });
    });

    group('Edge cases', () {
      testWidgets('should handle null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagInput(
              onTagAdded: null,
              onTagRemoved: null,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle very large suggestion lists', (tester) async {
        final largeSuggestions = TestDataFactory.createTagList(100);

        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagInput(
              suggestions: largeSuggestions,
              onTagAdded: (tag) {},
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 't');
        await tester.pump();

        // Should handle large lists without performance issues
        expect(find.byType(ListView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should prevent duplicate tag addition', (tester) async {
        final addedTags = <String>[];
        final selectedTags = [
          TestDataFactory.createTag(name: 'flutter', displayName: 'Flutter'),
        ];

        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagInput(
              selectedTags: selectedTags,
              onTagAdded: (tag) => addedTags.add(tag),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'flutter');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Should not add duplicate
        expect(addedTags, isEmpty);
      });
    });

    group('Performance', () {
      testWidgets('should handle many selected tags efficiently', (tester) async {
        final manyTags = TestDataFactory.createTagList(50);

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagInput(
              selectedTags: manyTags,
              onTagAdded: (tag) {},
              onTagRemoved: (tag) {},
            ),
          ),
        );
        
        stopwatch.stop();

        // Should render many tags quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(find.byType(Chip), findsNWidgets(50));
      });
    });
  });
}