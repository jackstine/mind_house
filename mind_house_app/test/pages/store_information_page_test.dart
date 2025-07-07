import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mind_house_app/pages/store_information_page.dart';
import 'package:mind_house_app/blocs/information_bloc.dart';
import 'package:mind_house_app/blocs/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion_bloc.dart';
import 'package:mind_house_app/widgets/content_input.dart';
import 'package:mind_house_app/widgets/tag_input.dart';
import 'package:mind_house_app/widgets/save_button.dart';
import '../helpers/test_utilities.dart';
import '../helpers/test_data_factory.dart';
import '../mocks/mock_repositories.mocks.dart';

/// Widget tests for StoreInformationPage component
void main() {
  group('StoreInformationPage Widget Tests', () {
    late MockInformationRepository mockInformationRepository;
    late MockTagRepository mockTagRepository;

    setUp(() {
      mockInformationRepository = MockInformationRepository();
      mockTagRepository = MockTagRepository();
    });

    Widget createTestPage() {
      return TestUtilities.createTestWidget(
        child: StoreInformationPage(),
        informationRepository: mockInformationRepository,
        tagRepository: mockTagRepository,
      );
    }

    testWidgets('should display page title', (tester) async {
      await tester.pumpWidget(createTestPage());

      expect(find.text('Store Information'), findsOneWidget);
    });

    testWidgets('should display content input field', (tester) async {
      await tester.pumpWidget(createTestPage());

      expect(find.byType(ContentInput), findsOneWidget);
    });

    testWidgets('should display tag input field', (tester) async {
      await tester.pumpWidget(createTestPage());

      expect(find.byType(TagInput), findsOneWidget);
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(createTestPage());

      expect(find.byType(SaveButton), findsOneWidget);
    });

    testWidgets('should handle content input changes', (tester) async {
      await tester.pumpWidget(createTestPage());

      final contentInput = find.byType(ContentInput);
      expect(contentInput, findsOneWidget);

      // Enter text in content input
      await tester.enterText(
        find.descendant(
          of: contentInput,
          matching: find.byType(TextField),
        ),
        'Test information content',
      );
      await tester.pump();

      // Content should be updated
      expect(find.text('Test information content'), findsOneWidget);
    });

    testWidgets('should handle tag addition', (tester) async {
      await tester.pumpWidget(createTestPage());

      final tagInput = find.byType(TagInput);
      expect(tagInput, findsOneWidget);

      // Add a tag
      final tagTextField = find.descendant(
        of: tagInput,
        matching: find.byType(TextField),
      );
      
      await tester.enterText(tagTextField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Tag should be added as a chip
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('should handle tag removal', (tester) async {
      await tester.pumpWidget(createTestPage());

      // Add a tag first
      final tagTextField = find.descendant(
        of: find.byType(TagInput),
        matching: find.byType(TextField),
      );
      
      await tester.enterText(tagTextField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Remove the tag
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Tag should be removed
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should save information when save button is pressed', (tester) async {
      when(mockInformationRepository.create(any))
          .thenAnswer((_) async => TestDataFactory.createInformation());
      when(mockInformationRepository.getAll())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestPage());

      // Enter content
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        'Test information content',
      );
      await tester.pump();

      // Add tag
      final tagTextField = find.descendant(
        of: find.byType(TagInput),
        matching: find.byType(TextField),
      );
      await tester.enterText(tagTextField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Tap save button
      await tester.tap(find.byType(SaveButton));
      await tester.pump();

      // Verify repository was called
      verify(mockInformationRepository.create(any)).called(1);
    });

    testWidgets('should clear form after successful save', (tester) async {
      when(mockInformationRepository.create(any))
          .thenAnswer((_) async => TestDataFactory.createInformation());
      when(mockInformationRepository.getAll())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestPage());

      // Enter content and tags
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        'Test content',
      );
      
      final tagTextField = find.descendant(
        of: find.byType(TagInput),
        matching: find.byType(TextField),
      );
      await tester.enterText(tagTextField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Save
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      // Form should be cleared
      final contentTextField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
      );
      expect(contentTextField.controller?.text, isEmpty);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should show loading state while saving', (tester) async {
      // Mock a slow save operation
      when(mockInformationRepository.create(any))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return TestDataFactory.createInformation();
          });

      await tester.pumpWidget(createTestPage());

      // Enter content
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        'Test content',
      );
      await tester.pump();

      // Start save operation
      await tester.tap(find.byType(SaveButton));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when save fails', (tester) async {
      when(mockInformationRepository.create(any))
          .thenThrow(Exception('Save failed'));

      await tester.pumpWidget(createTestPage());

      // Enter content
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        'Test content',
      );
      await tester.pump();

      // Try to save
      await tester.tap(find.byType(SaveButton));
      await tester.pump();

      // Should show error message
      expect(find.textContaining('Save failed'), findsOneWidget);
    });

    testWidgets('should disable save button when content is empty', (tester) async {
      await tester.pumpWidget(createTestPage());

      final saveButton = tester.widget<SaveButton>(find.byType(SaveButton));
      expect(saveButton.isEnabled, isFalse);
    });

    testWidgets('should enable save button when content is entered', (tester) async {
      await tester.pumpWidget(createTestPage());

      // Enter content
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        'Test content',
      );
      await tester.pump();

      final saveButton = tester.widget<SaveButton>(find.byType(SaveButton));
      expect(saveButton.isEnabled, isTrue);
    });

    testWidgets('should handle very long content', (tester) async {
      await tester.pumpWidget(createTestPage());

      final longContent = 'A' * 10000;
      
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        longContent,
      );
      await tester.pump();

      expect(find.text(longContent), findsOneWidget);
    });

    testWidgets('should handle unicode content', (tester) async {
      await tester.pumpWidget(createTestPage());

      const unicodeContent = 'Unicode test 🎉💻📱🚀 with emojis';
      
      await tester.enterText(
        find.descendant(
          of: find.byType(ContentInput),
          matching: find.byType(TextField),
        ),
        unicodeContent,
      );
      await tester.pump();

      expect(find.text(unicodeContent), findsOneWidget);
    });

    testWidgets('should handle many tags', (tester) async {
      await tester.pumpWidget(createTestPage());

      final tagTextField = find.descendant(
        of: find.byType(TagInput),
        matching: find.byType(TextField),
      );

      // Add multiple tags
      for (int i = 0; i < 10; i++) {
        await tester.enterText(tagTextField, 'tag$i');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      }

      expect(find.byType(Chip), findsNWidgets(10));
    });

    testWidgets('should provide accessibility support', (tester) async {
      await tester.pumpWidget(createTestPage());

      await TestUtilities.verifyAccessibility(tester);
    });

    testWidgets('should handle rapid user interactions', (tester) async {
      when(mockInformationRepository.create(any))
          .thenAnswer((_) async => TestDataFactory.createInformation());
      when(mockInformationRepository.getAll())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestPage());

      // Rapid interactions
      for (int i = 0; i < 5; i++) {
        await tester.enterText(
          find.descendant(
            of: find.byType(ContentInput),
            matching: find.byType(TextField),
          ),
          'Content $i',
        );
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(tester.takeException(), isNull);
    });

    group('Keyboard shortcuts', () {
      testWidgets('should save with Ctrl+S shortcut', (tester) async {
        when(mockInformationRepository.create(any))
            .thenAnswer((_) async => TestDataFactory.createInformation());
        when(mockInformationRepository.getAll())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestPage());

        // Enter content
        await tester.enterText(
          find.descendant(
            of: find.byType(ContentInput),
            matching: find.byType(TextField),
          ),
          'Test content',
        );
        await tester.pump();

        // Simulate Ctrl+S
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        verify(mockInformationRepository.create(any)).called(1);
      });
    });

    group('State persistence', () {
      testWidgets('should maintain form state during rebuilds', (tester) async {
        await tester.pumpWidget(createTestPage());

        // Enter content
        await tester.enterText(
          find.descendant(
            of: find.byType(ContentInput),
            matching: find.byType(TextField),
          ),
          'Persistent content',
        );
        await tester.pump();

        // Trigger rebuild
        await tester.pumpWidget(createTestPage());

        // Content should still be there
        expect(find.text('Persistent content'), findsOneWidget);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle empty tag submission', (tester) async {
        await tester.pumpWidget(createTestPage());

        final tagTextField = find.descendant(
          of: find.byType(TagInput),
          matching: find.byType(TextField),
        );

        // Try to submit empty tag
        await tester.enterText(tagTextField, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // No chip should be added
        expect(find.byType(Chip), findsNothing);
      });

      testWidgets('should handle whitespace-only content', (tester) async {
        await tester.pumpWidget(createTestPage());

        await tester.enterText(
          find.descendant(
            of: find.byType(ContentInput),
            matching: find.byType(TextField),
          ),
          '   ',
        );
        await tester.pump();

        final saveButton = tester.widget<SaveButton>(find.byType(SaveButton));
        expect(saveButton.isEnabled, isFalse);
      });

      testWidgets('should prevent duplicate tags', (tester) async {
        await tester.pumpWidget(createTestPage());

        final tagTextField = find.descendant(
          of: find.byType(TagInput),
          matching: find.byType(TextField),
        );

        // Add same tag twice
        await tester.enterText(tagTextField, 'flutter');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(tagTextField, 'flutter');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Should only have one chip
        expect(find.byType(Chip), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle large form efficiently', (tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(createTestPage());

        // Large content
        final largeContent = 'A' * 50000;
        await tester.enterText(
          find.descendant(
            of: find.byType(ContentInput),
            matching: find.byType(TextField),
          ),
          largeContent,
        );

        // Many tags
        final tagTextField = find.descendant(
          of: find.byType(TagInput),
          matching: find.byType(TextField),
        );
        for (int i = 0; i < 20; i++) {
          await tester.enterText(tagTextField, 'tag$i');
          await tester.testTextInput.receiveAction(TextInputAction.done);
        }
        
        await tester.pump();
        stopwatch.stop();

        // Should handle large form quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(find.byType(Chip), findsNWidgets(20));
      });
    });
  });
}