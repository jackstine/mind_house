// Mind House Design System
// Comprehensive design system export file with documentation and usage examples

library mind_house_design_system;

// Design Tokens
export 'tokens/design_tokens.dart';

// Component Exports
export 'components/cards/information_card.dart';
export 'components/inputs/tag_input.dart';
export 'components/inputs/content_input.dart';
export 'components/navigation/search_interface.dart';
export 'components/navigation/navigation_shell.dart';
export 'components/feedback/loading_states.dart';
export 'components/feedback/empty_states.dart';

// Layout Exports
export 'layouts/responsive_container.dart';
export 'layouts/flexible_grid.dart';
export 'layouts/content_area.dart';

import 'package:flutter/material.dart';
import 'tokens/design_tokens.dart';

/// Mind House Design System Theme Configuration
/// 
/// This class provides pre-configured Material Design 3 themes optimized
/// for information management applications. It includes both light and dark
/// themes with semantic color mappings and accessibility considerations.
class MindHouseTheme {
  MindHouseTheme._();

  /// Light theme configuration optimized for information management
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: MindHouseDesignTokens.lightColorScheme,
    textTheme: MindHouseDesignTokens.textTheme,
    
    // Card theme
    cardTheme: CardTheme(
      elevation: MindHouseDesignTokens.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: MindHouseDesignTokens.cardBorderRadius,
      ),
      margin: EdgeInsets.all(MindHouseDesignTokens.spaceSM),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MindHouseDesignTokens.lightColorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.lightColorScheme.outline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.lightColorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.lightColorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.lightColorScheme.error,
        ),
      ),
      contentPadding: MindHouseDesignTokens.componentPaddingMedium,
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
        elevation: MindHouseDesignTokens.elevation2,
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: MindHouseDesignTokens.lightColorScheme.surfaceContainer,
      selectedColor: MindHouseDesignTokens.lightColorScheme.primaryContainer,
      deleteIconColor: MindHouseDesignTokens.lightColorScheme.onSurfaceVariant,
      labelStyle: MindHouseDesignTokens.textTheme.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusLG),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MindHouseDesignTokens.spaceSM,
        vertical: MindHouseDesignTokens.spaceXS,
      ),
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      elevation: MindHouseDesignTokens.elevation0,
      backgroundColor: MindHouseDesignTokens.lightColorScheme.surface,
      foregroundColor: MindHouseDesignTokens.lightColorScheme.onSurface,
      titleTextStyle: MindHouseDesignTokens.textTheme.titleLarge,
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      elevation: MindHouseDesignTokens.elevation2,
      backgroundColor: MindHouseDesignTokens.lightColorScheme.surface,
      indicatorColor: MindHouseDesignTokens.lightColorScheme.primaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MindHouseDesignTokens.textTheme.labelMedium?.copyWith(
            color: MindHouseDesignTokens.lightColorScheme.onPrimaryContainer,
          );
        }
        return MindHouseDesignTokens.textTheme.labelMedium?.copyWith(
          color: MindHouseDesignTokens.lightColorScheme.onSurfaceVariant,
        );
      }),
    ),
  );

  /// Dark theme configuration optimized for information management
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: MindHouseDesignTokens.darkColorScheme,
    textTheme: MindHouseDesignTokens.textTheme,
    
    // Card theme
    cardTheme: CardTheme(
      elevation: MindHouseDesignTokens.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: MindHouseDesignTokens.cardBorderRadius,
      ),
      margin: EdgeInsets.all(MindHouseDesignTokens.spaceSM),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MindHouseDesignTokens.darkColorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.darkColorScheme.outline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.darkColorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.darkColorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        borderSide: BorderSide(
          color: MindHouseDesignTokens.darkColorScheme.error,
        ),
      ),
      contentPadding: MindHouseDesignTokens.componentPaddingMedium,
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
        elevation: MindHouseDesignTokens.elevation2,
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: MindHouseDesignTokens.buttonBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: MindHouseDesignTokens.darkColorScheme.surfaceContainer,
      selectedColor: MindHouseDesignTokens.darkColorScheme.primaryContainer,
      deleteIconColor: MindHouseDesignTokens.darkColorScheme.onSurfaceVariant,
      labelStyle: MindHouseDesignTokens.textTheme.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusLG),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MindHouseDesignTokens.spaceSM,
        vertical: MindHouseDesignTokens.spaceXS,
      ),
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      elevation: MindHouseDesignTokens.elevation0,
      backgroundColor: MindHouseDesignTokens.darkColorScheme.surface,
      foregroundColor: MindHouseDesignTokens.darkColorScheme.onSurface,
      titleTextStyle: MindHouseDesignTokens.textTheme.titleLarge,
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      elevation: MindHouseDesignTokens.elevation2,
      backgroundColor: MindHouseDesignTokens.darkColorScheme.surface,
      indicatorColor: MindHouseDesignTokens.darkColorScheme.primaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MindHouseDesignTokens.textTheme.labelMedium?.copyWith(
            color: MindHouseDesignTokens.darkColorScheme.onPrimaryContainer,
          );
        }
        return MindHouseDesignTokens.textTheme.labelMedium?.copyWith(
          color: MindHouseDesignTokens.darkColorScheme.onSurfaceVariant,
        );
      }),
    ),
  );
}

/// Design System Documentation
/// 
/// This class provides comprehensive documentation and usage examples
/// for the Mind House Design System components and patterns.
class DesignSystemDocs {
  DesignSystemDocs._();
  
  /// Component usage examples and best practices
  static const String componentUsage = '''
# Mind House Design System - Component Usage

## InformationCard
Used for displaying structured information with visual hierarchy:

```dart
InformationCard.note(
  title: "Meeting Notes",
  content: "Discussed project timeline and deliverables",
  tags: ["work", "meeting", "important"],
  onTap: () => navigateToNote(),
)
```

## TagInput
For tag-based categorization and filtering:

```dart
TagInput.withSuggestions(
  initialTags: ["flutter", "design"],
  suggestions: ["material", "ui", "ux", "development"],
  onTagsChanged: (tags) => updateCategories(tags),
)
```

## ContentInput
Rich text input with formatting support:

```dart
ContentInput.markdown(
  initialContent: "# My Document",
  onContentChanged: (content) => saveDocument(content),
  showWordCount: true,
)
```

## SearchInterface
Advanced search with filtering capabilities:

```dart
SearchInterface.advanced(
  onSearch: (query, filters) => performSearch(query, filters),
  suggestionCallback: (query) => fetchSuggestions(query),
  filters: [
    SearchFilter(
      key: "type",
      label: "Content Type",
      options: ["notes", "documents", "images"],
    ),
  ],
)
```

## LoadingStates
Various loading indicators and skeleton screens:

```dart
LoadingStates.skeleton(
  config: SkeletonConfig.listItem(),
  isVisible: isLoading,
)
```

## EmptyStates
Actionable empty states with guidance:

```dart
EmptyStates.noContent(
  title: "No notes yet",
  description: "Create your first note to get started",
  actions: [
    EmptyStateAction(
      label: "Create Note",
      onPressed: () => createNewNote(),
      isPrimary: true,
    ),
  ],
)
```
''';

  /// Layout system documentation
  static const String layoutUsage = '''
# Layout System

## ResponsiveContainer
Adaptive layouts that respond to screen size:

```dart
ResponsiveContainer.content(
  child: MyContent(),
  centerContent: true,
)
```

## FlexibleGrid
Information organization with responsive columns:

```dart
FlexibleGrid.cards(
  cards: noteCards,
  minItemWidth: 280.0,
  aspectRatio: 1.2,
)
```

## ContentArea
Proper content spacing and scroll behavior:

```dart
ContentArea.article(
  child: MarkdownContent(),
  enableSafeArea: true,
)
```

## NavigationShell
Adaptive navigation for different screen sizes:

```dart
NavigationShell.adaptive(
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      label: "Search",
    ),
  ],
  children: [HomePage(), SearchPage()],
)
```
''';

  /// Accessibility guidelines
  static const String accessibilityGuidelines = '''
# Accessibility Guidelines

## Semantic Labels
All components support semantic labels for screen readers:

```dart
InformationCard(
  title: "Document Title",
  semanticLabel: "Document titled 'Document Title', tap to open",
)
```

## Touch Targets
Minimum touch target sizes are enforced:
- Interactive elements: 48dp minimum
- Icons: 40dp minimum with padding

## Color Contrast
All color combinations meet WCAG AA standards:
- Text on background: 4.5:1 minimum
- Interactive elements: 3:1 minimum

## Keyboard Navigation
Components support keyboard navigation:
- Tab order follows logical flow
- Arrow keys for directional navigation
- Enter/Space for activation
- Escape for dismissal

## Screen Reader Support
- Proper heading hierarchy
- Descriptive labels and hints
- State announcements
- Live regions for dynamic content
''';

  /// Design principles and best practices
  static const String designPrinciples = '''
# Design Principles

## Information Hierarchy
1. Use typography scale to establish clear hierarchy
2. Apply consistent spacing for visual rhythm  
3. Leverage color to guide attention and convey meaning

## Responsive Design
1. Mobile-first approach with progressive enhancement
2. Flexible layouts that adapt to different screen sizes
3. Touch-friendly interactions on all devices

## Content Organization
1. Group related information together
2. Use white space effectively to reduce cognitive load
3. Provide clear navigation and wayfinding

## Accessibility First
1. Design for keyboard-only users
2. Ensure sufficient color contrast
3. Provide alternative text for images
4. Use semantic HTML structure

## Performance
1. Lazy load content when appropriate
2. Optimize images and assets
3. Minimize animation complexity
4. Use efficient layout patterns
''';
}