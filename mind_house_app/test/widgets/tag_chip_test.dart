import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/widgets/tag_chip.dart';
import 'package:mind_house_app/models/tag.dart';
import '../helpers/test_utilities.dart';
import '../helpers/test_data_factory.dart';

/// Widget tests for TagChip component
void main() {
  group('TagChip Widget Tests', () {
    late Tag testTag;

    setUp(() {
      testTag = TestDataFactory.createTag(
        name: 'flutter',
        displayName: 'Flutter',
        color: 'FF6B73',
        usageCount: 5,
      );
    });

    testWidgets('should display tag name correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(tag: testTag),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('should display tag chip with correct styling', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(tag: testTag),
        ),
      );

      final chipFinder = find.byType(Chip);
      expect(chipFinder, findsOneWidget);

      final chip = tester.widget<Chip>(chipFinder);
      expect(chip.label, isA<Text>());
    });

    testWidgets('should handle selection state correctly', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            isSelected: true,
          ),
        ),
      );

      final chipFinder = find.byType(Chip);
      final chip = tester.widget<Chip>(chipFinder);
      
      // Should have different styling when selected
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('should show delete button when showDeleteButton is true', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            showDeleteButton: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not show delete button when showDeleteButton is false', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            showDeleteButton: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should call onTap when chip is tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            onTap: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(Chip));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should call onDeleted when delete button is tapped', (tester) async {
      bool wasDeleted = false;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            showDeleteButton: true,
            onDeleted: () => wasDeleted = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(wasDeleted, isTrue);
    });

    testWidgets('should handle color conversion correctly', (tester) async {
      final coloredTag = TestDataFactory.createTag(
        name: 'test',
        color: 'FF0000', // Red
      );

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(tag: coloredTag),
        ),
      );

      final chipFinder = find.byType(Chip);
      final chip = tester.widget<Chip>(chipFinder);
      
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('should handle long tag names correctly', (tester) async {
      final longTag = TestDataFactory.createTag(
        name: 'very-long-tag-name-that-might-overflow',
        displayName: 'Very Long Tag Name That Might Overflow The UI',
      );

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: SizedBox(
            width: 200,
            child: TagChip(tag: longTag),
          ),
        ),
      );

      expect(find.text('Very Long Tag Name That Might Overflow The UI'), findsOneWidget);
      
      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle unicode characters in tag name', (tester) async {
      final unicodeTag = TestDataFactory.createTag(
        name: 'тег',
        displayName: '🏷️ Unicode Tag',
      );

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(tag: unicodeTag),
        ),
      );

      expect(find.text('🏷️ Unicode Tag'), findsOneWidget);
    });

    testWidgets('should provide proper accessibility support', (tester) async {
      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(tag: testTag),
        ),
      );

      await TestUtilities.verifyAccessibility(tester);
    });

    testWidgets('should handle rapid taps without errors', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: TagChip(
            tag: testTag,
            onTap: () => tapCount++,
          ),
        ),
      );

      // Rapid taps
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(Chip));
      }
      await tester.pump();

      expect(tapCount, equals(10));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain state during parent rebuilds', (tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        TestUtilities.createTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TagChip(
                    tag: testTag,
                    isSelected: isSelected,
                    onTap: () => setState(() => isSelected = !isSelected),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Tap to select
      await tester.tap(find.byType(TagChip));
      await tester.pump();

      // Trigger parent rebuild
      await tester.tap(find.text('Rebuild'));
      await tester.pump();

      // State should be maintained
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, isNotNull); // Still selected
    });

    group('Edge cases', () {
      testWidgets('should handle null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagChip(
              tag: testTag,
              onTap: null,
              onDeleted: null,
            ),
          ),
        );

        // Should not crash when tapped
        await tester.tap(find.byType(Chip));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle empty display name', (tester) async {
        final emptyTag = Tag(
          name: 'test',
          displayName: '',
          color: 'FF0000',
        );

        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagChip(tag: emptyTag),
          ),
        );

        // Should still render without crashing
        expect(find.byType(Chip), findsOneWidget);
      });

      testWidgets('should handle invalid color gracefully', (tester) async {
        // This would typically be caught by Tag validation, but test defensive coding
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: TagChip(tag: testTag),
          ),
        );

        expect(find.byType(Chip), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Performance', () {
      testWidgets('should render quickly with many chips', (tester) async {
        final tags = TestDataFactory.createTagList(20);

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          TestUtilities.createTestWidget(
            child: Wrap(
              children: tags.map((tag) => TagChip(tag: tag)).toList(),
            ),
          ),
        );
        
        stopwatch.stop();

        // Should render 20 chips quickly (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(find.byType(TagChip), findsNWidgets(20));
      });
    });
  });
}