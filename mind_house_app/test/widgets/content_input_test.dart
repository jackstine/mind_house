import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/widgets/content_input.dart';
import '../helpers/test_utilities.dart';

/// Widget tests for ContentInput component
void main() {
  group('ContentInput Widget Tests', () {
    testWidgets('should display text field for content input', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display hint text correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            hintText: 'Enter your content here',
          ),
        ),
      );

      expect(find.text('Enter your content here'), findsOneWidget);
    });

    testWidgets('should display label text correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            labelText: 'Content',
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should handle text input correctly', (tester) async {
      String? inputText;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => inputText = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.pump();

      expect(inputText, equals('Test content'));
    });

    testWidgets('should call onSubmitted when submitted', (tester) async {
      bool wasSubmitted = false;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onSubmitted: () => wasSubmitted = true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(wasSubmitted, isTrue);
    });

    testWidgets('should support multiline input', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            maxLines: null,
            minLines: 3,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, isNull);
      expect(textField.minLines, equals(3));
    });

    testWidgets('should handle expands property correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: SizedBox(
            height: 200,
            child: ContentInput(
              expands: true,
            ),
          ),
        ),
      );

      final expanded = find.byType(Expanded);
      expect(expanded, findsOneWidget);
    });

    testWidgets('should show character count when text is entered', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(find.text('4 characters'), findsOneWidget);
    });

    testWidgets('should not show character count when readOnly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            readOnly: true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(find.text('4 characters'), findsNothing);
    });

    testWidgets('should show clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear text when clear button is tapped', (tester) async {
      String? currentText;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => currentText = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(currentText, equals(''));
    });

    testWidgets('should not show clear button when readOnly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            readOnly: true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should handle external controller', (tester) async {
      final controller = TextEditingController(text: 'Initial text');
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            controller: controller,
          ),
        ),
      );

      expect(find.text('Initial text'), findsOneWidget);
      
      controller.dispose();
    });

    testWidgets('should apply custom padding', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            padding: const EdgeInsets.all(20),
          ),
        ),
      );

      final paddingWidget = find.byType(Padding);
      expect(paddingWidget, findsOneWidget);
      
      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, equals(const EdgeInsets.all(20)));
    });

    testWidgets('should handle very long text input', (tester) async {
      final longText = 'A' * 10000;
      String? inputText;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => inputText = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      expect(inputText, equals(longText));
      expect(find.text('10000 characters'), findsOneWidget);
    });

    testWidgets('should handle unicode and emoji content', (tester) async {
      const emojiContent = 'Unicode content 🎉💻📱🚀 with emojis';
      String? inputText;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => inputText = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), emojiContent);
      await tester.pump();

      expect(inputText, equals(emojiContent));
    });

    testWidgets('should handle multiline content correctly', (tester) async {
      const multilineContent = 'Line 1\nLine 2\nLine 3';
      String? inputText;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => inputText = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), multilineContent);
      await tester.pump();

      expect(inputText, equals(multilineContent));
    });

    testWidgets('should provide accessibility support', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            labelText: 'Content Input',
          ),
        ),
      );

      await TestUtilities.verifyAccessibility(tester);
    });

    testWidgets('should handle focus changes correctly', (tester) async {
      final focusNode = FocusNode();
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: Column(
            children: [
              ContentInput(),
              TextField(focusNode: focusNode),
            ],
          ),
        ),
      );

      // Focus on ContentInput
      await tester.tap(find.byType(ContentInput));
      await tester.pump();

      // Focus on other TextField
      focusNode.requestFocus();
      await tester.pump();

      expect(tester.takeException(), isNull);
      
      focusNode.dispose();
    });

    testWidgets('should handle rapid text changes', (tester) async {
      int changeCount = 0;
      
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: ContentInput(
            onChanged: (text) => changeCount++,
          ),
        ),
      );

      // Rapid text changes
      for (int i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField), 'Text $i');
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(changeCount, equals(10));
      expect(tester.takeException(), isNull);
    });

    group('ReadOnly mode', () {
      testWidgets('should display text but not allow editing when readOnly', (tester) async {
        final controller = TextEditingController(text: 'Read only content');
        
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(
              controller: controller,
              readOnly: true,
            ),
          ),
        );

        expect(find.text('Read only content'), findsOneWidget);
        
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.readOnly, isTrue);
        
        controller.dispose();
      });

      testWidgets('should show different styling when readOnly', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(
              readOnly: true,
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.filled, isTrue);
        expect(textField.decoration?.fillColor, isNotNull);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(
              onChanged: null,
              onSubmitted: null,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Test');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle empty text correctly', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(),
          ),
        );

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        expect(find.byIcon(Icons.clear), findsNothing);
        expect(find.textContaining('characters'), findsNothing);
      });

      testWidgets('should dispose resources properly', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(),
          ),
        );

        // Pump a different widget to trigger dispose
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: Container(),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });

    group('Performance', () {
      testWidgets('should handle large content efficiently', (tester) async {
        final largeContent = 'A' * 50000; // 50k characters
        
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: ContentInput(),
          ),
        );

        await tester.enterText(find.byType(TextField), largeContent);
        await tester.pump();
        
        stopwatch.stop();

        // Should handle large content quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(find.text('50000 characters'), findsOneWidget);
      });
    });
  });
}