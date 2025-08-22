# Mind House Design System

A comprehensive, accessible, and Material Design 3 compliant design system for Flutter applications, specifically optimized for information management workflows.

## 🎯 Overview

The Mind House Design System provides a complete set of reusable UI components, layout helpers, and design tokens that work together to create consistent, accessible, and beautiful user interfaces for information-heavy applications.

## ✨ Key Features

- **Material Design 3 Compliance** - Built on the latest Material Design principles
- **Accessibility First** - WCAG AA compliance with comprehensive screen reader support
- **Responsive by Default** - Adaptive layouts for mobile, tablet, and desktop
- **Information Management Optimized** - Components designed for content-heavy applications
- **Comprehensive Documentation** - Extensive examples and usage guidelines
- **Type Safety** - Full TypeScript-like support with comprehensive type definitions
- **Animation System** - Smooth, purposeful animations with performance optimization

## 📦 Components

### 🎴 Cards & Content Display
- **InformationCard** - Enhanced cards with visual hierarchy and content preview
- **ContentArea** - Flexible content layout with proper spacing and scroll behavior
- **EmptyStates** - Actionable empty states with illustrations and guidance

### 📝 Input Components  
- **TagInput** - Real-time suggestions and visual feedback for tagging
- **ContentInput** - Rich text support with markdown and formatting options
- **SearchInterface** - Advanced filtering and suggestion capabilities

### 🧭 Navigation
- **NavigationShell** - Adaptive navigation that changes based on screen size
- **TabbedNavigationShell** - Tab-based interfaces with gesture support
- **PersistentNavigationShell** - Persistent header/footer navigation

### 🔄 Feedback & States
- **LoadingStates** - Skeleton screens, shimmer effects, and progressive loading
- **ProgressiveLoading** - Step-by-step loading with progress indication

### 📐 Layout System
- **ResponsiveContainer** - Adaptive containers with breakpoint-based configuration
- **FlexibleGrid** - Information organization with masonry and auto-fit layouts
- **ResponsiveBuilder** - Breakpoint-based widget switching

## 🎨 Design Tokens

### Color System
- **Semantic Colors** - Primary, secondary, surface, error, etc.
- **Information Colors** - Specialized colors for data visualization
- **Light/Dark Support** - Automatic theme switching

### Typography
- **Information Hierarchy** - Optimized type scale for content readability
- **Responsive Typography** - Font sizes that adapt to screen size
- **Accessibility** - High contrast ratios and readable font weights

### Spacing & Layout
- **Consistent Spacing Scale** - 8px base grid with semantic names
- **Component Spacing** - Predefined padding and margins for components
- **Responsive Spacing** - Spacing that adapts to device type

## 🚀 Getting Started

### Installation

```dart
// Add to pubspec.yaml dependencies
dependencies:
  mind_house_design_system:
    path: lib/design_system/

// Import the design system
import 'package:mind_house_design_system/design_system.dart';
```

### Setup Theme

```dart
MaterialApp(
  title: 'Mind House App',
  theme: MindHouseTheme.lightTheme,
  darkTheme: MindHouseTheme.darkTheme,
  home: MyHomePage(),
)
```

### Basic Usage

```dart
// Information Card
InformationCard.note(
  title: "Project Meeting Notes",
  content: "Discussed Q4 objectives and timeline",
  tags: ["work", "meeting", "important"],
  onTap: () => navigateToNote(),
)

// Tag Input with Suggestions
TagInput.withSuggestions(
  initialTags: ["flutter", "design"],
  suggestions: ["material", "ui", "ux", "development"],
  onTagsChanged: (tags) => updateCategories(tags),
)

// Responsive Grid Layout
FlexibleGrid.cards(
  cards: informationCards,
  minItemWidth: 280.0,
  aspectRatio: 1.2,
  spacing: 16.0,
)

// Adaptive Navigation
NavigationShell.adaptive(
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: "Home",
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined), 
      selectedIcon: Icon(Icons.search),
      label: "Search",
    ),
  ],
  children: [HomePage(), SearchPage()],
)
```

## 📱 Responsive Breakpoints

The design system uses a mobile-first approach with the following breakpoints:

- **XS** (< 480px) - Mobile portrait
- **SM** (480px - 768px) - Mobile landscape, small tablets
- **MD** (768px - 1024px) - Tablets, small laptops  
- **LG** (1024px - 1440px) - Laptops, desktops
- **XL** (> 1440px) - Large desktops

### Responsive Usage

```dart
// Responsive values
final columns = ResponsiveContainer.getResponsiveValue(
  context,
  xs: 1,
  sm: 2,
  md: 3,
  lg: 4,
  xl: 5,
  defaultValue: 2,
);

// Responsive spacing
ResponsiveGap(
  xs: 8.0,
  sm: 16.0, 
  md: 24.0,
  lg: 32.0,
  defaultSize: 16.0,
)

// Device type checks
if (ResponsiveUtils.isMobile(context)) {
  // Mobile-specific layout
} else if (ResponsiveUtils.isTablet(context)) {
  // Tablet-specific layout  
} else {
  // Desktop layout
}
```

## ♿ Accessibility Features

### Built-in Accessibility
- **Screen Reader Support** - Comprehensive semantic labels and descriptions
- **Keyboard Navigation** - Full keyboard accessibility with focus management
- **Touch Targets** - Minimum 48dp touch targets on all interactive elements
- **Color Contrast** - WCAG AA compliant color combinations
- **Motion Preferences** - Respects user's reduced motion preferences

### Accessibility Usage

```dart
// Semantic labels
InformationCard(
  title: "Document Title",
  semanticLabel: "Document titled 'Document Title', last modified yesterday, tap to open",
)

// Keyboard navigation
SearchInterface(
  enableKeyboardNavigation: true,
  onSearch: handleSearch,
)

// Focus management
NavigationShell(
  enableKeyboardNavigation: true,
  destinations: destinations,
)
```

## 🎯 Design Principles

### 1. Information First
- Optimized for content-heavy applications
- Clear information hierarchy
- Efficient space utilization

### 2. Responsive by Default
- Mobile-first approach
- Adaptive layouts for all screen sizes
- Touch-friendly interactions

### 3. Accessibility as a Foundation  
- Universal design principles
- Screen reader compatibility
- Keyboard navigation support

### 4. Performance Optimized
- Efficient rendering with Flutter's widget system
- Minimal rebuilds and optimized animations
- Lazy loading for large data sets

## 📚 Component Documentation

### InformationCard
Enhanced cards for displaying structured information with visual hierarchy.

```dart
// Basic note card
InformationCard.note(
  title: "Meeting Notes",
  content: "Discussed project timeline",
  tags: ["work", "meeting"],
  onTap: () => openNote(),
)

// Task card with completion state
InformationCard.task(
  title: "Review design mockups",
  description: "Check alignment with brand guidelines", 
  isCompleted: false,
  onTap: () => openTask(),
)

// Article card with author and thumbnail
InformationCard.article(
  title: "Flutter Best Practices",
  author: "John Doe",
  excerpt: "Essential patterns for scalable Flutter apps",
  tags: ["flutter", "development"],
  thumbnail: CachedNetworkImage(imageUrl: thumbnailUrl),
  onTap: () => openArticle(),
)
```

### TagInput  
Real-time suggestions and validation for tagging interfaces.

```dart
// Simple tag input
TagInput.simple(
  initialTags: ["flutter", "design"],
  onTagsChanged: (tags) => saveTags(tags),
  hintText: "Add tags...",
)

// With predefined suggestions
TagInput.withSuggestions(
  suggestions: ["material", "ui", "ux", "development"],
  onTagsChanged: (tags) => updateFilters(tags),
)

// Category input with validation
TagInput.categories(
  maxTags: 5,
  onTagsChanged: (tags) => updateCategories(tags),
  hintText: "Add categories...",
)
```

### ContentInput
Rich text input with formatting and markdown support.

```dart
// Simple text area
ContentInput.textArea(
  placeholder: "Start writing...",
  onContentChanged: (content) => saveContent(content),
  minLines: 3,
)

// Markdown editor
ContentInput.markdown(
  initialContent: "# My Document\n\nContent here...",
  onContentChanged: (content) => saveDocument(content),
  showWordCount: true,
)

// Code editor  
ContentInput.code(
  placeholder: "Enter your code...",
  onContentChanged: (code) => saveCode(code),
  showCharacterCount: true,
)
```

### SearchInterface
Advanced search with filtering and suggestions.

```dart
// Simple search
SearchInterface.simple(
  onSearch: (query, filters) => performSearch(query),
  placeholder: "Search documents...",
)

// Advanced search with filters
SearchInterface.advanced(
  onSearch: (query, filters) => searchWithFilters(query, filters),
  suggestionCallback: (query) => fetchSuggestions(query),
  filters: [
    SearchFilter(
      key: "type",
      label: "Content Type", 
      options: ["notes", "documents", "images"],
    ),
    SearchFilter(
      key: "status",
      label: "Status",
      options: ["draft", "published", "archived"],
    ),
  ],
)
```

### LoadingStates & EmptyStates
Comprehensive feedback for different application states.

```dart
// Loading states
LoadingStates.circular(
  message: "Loading your content...",
  size: LoadingSize.medium,
)

LoadingStates.skeleton(
  config: SkeletonConfig.listItem(),
  isVisible: isLoading,
)

LoadingStates.shimmer(
  config: SkeletonConfig.card(),
  isVisible: isLoadingCards,
)

// Empty states
EmptyStates.noContent(
  title: "No notes yet",
  description: "Create your first note to get started",
  actions: [
    EmptyStateAction(
      label: "Create Note",
      onPressed: () => createNote(),
      icon: Icons.add,
      isPrimary: true,
    ),
  ],
)

EmptyStates.noResults(
  query: "flutter design",
  actions: [
    EmptyStateAction(
      label: "Clear filters", 
      onPressed: () => clearFilters(),
    ),
  ],
)
```

## 🏗️ Layout Components

### ResponsiveContainer
Adaptive containers with breakpoint-based behavior.

```dart
// Standard content container
ResponsiveContainer.content(
  child: MyContent(),
  centerContent: true,
)

// Full-width container
ResponsiveContainer.fullWidth(
  child: HeroSection(),
  padding: EdgeInsets.all(24.0),
)

// Adaptive with custom breakpoint configs
ResponsiveContainer.adaptive(
  child: FlexibleContent(),
  xsConfig: ResponsiveConfig(
    padding: EdgeInsets.all(8.0),
    maxWidth: double.infinity,
  ),
  mdConfig: ResponsiveConfig(
    padding: EdgeInsets.all(24.0), 
    maxWidth: 960.0,
  ),
)
```

### FlexibleGrid
Information organization with multiple layout options.

```dart
// Card grid with auto-fit
FlexibleGrid.cards(
  cards: informationCards,
  minItemWidth: 280.0,
  aspectRatio: 1.2,
  spacing: 16.0,
)

// Masonry layout for varied content
FlexibleGrid.masonry(
  items: mixedContentWidgets,
  columns: 3,
  spacing: 16.0,
)

// Uniform grid
FlexibleGrid.uniform(
  items: uniformItems,
  columns: 4,
  aspectRatio: 1.0,
  spacing: 12.0,
)
```

### ContentArea
Flexible content layouts with proper spacing.

```dart
// Standard content area
ContentArea.standard(
  child: MyContent(),
  enableSafeArea: true,
)

// Article reading layout
ContentArea.article(
  child: MarkdownRenderer(content: article),
  enableSafeArea: true,
)

// Form layout
FormContentArea(
  children: [
    TextFormField(decoration: InputDecoration(labelText: "Title")),
    ContentInput.textArea(placeholder: "Description"),
    TagInput.simple(hintText: "Tags"),
  ],
  spacing: 16.0,
  maxWidth: 600.0,
)
```

## 🎨 Customization

### Custom Themes

```dart
// Extend the base theme
ThemeData customTheme = MindHouseTheme.lightTheme.copyWith(
  colorScheme: MindHouseTheme.lightTheme.colorScheme.copyWith(
    primary: Colors.deepPurple,
  ),
);

// Custom color scheme
ColorScheme customColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.teal,
  brightness: Brightness.light,
);
```

### Custom Design Tokens

```dart
// Override specific tokens
class CustomDesignTokens extends MindHouseDesignTokens {
  static const double customSpacing = 20.0;
  static const BorderRadius customRadius = BorderRadius.all(
    Radius.circular(16.0),
  );
}
```

## 🧪 Testing

The design system includes comprehensive testing utilities:

```dart
// Component testing
testWidgets('InformationCard displays content correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: MindHouseTheme.lightTheme,
      home: InformationCard.note(
        title: "Test Note",
        content: "Test content",
      ),
    ),
  );
  
  expect(find.text("Test Note"), findsOneWidget);
  expect(find.text("Test content"), findsOneWidget);
});

// Responsive testing  
testWidgets('ResponsiveContainer adapts to screen size', (tester) async {
  // Test mobile layout
  await tester.binding.setSurfaceSize(Size(400, 800));
  await tester.pumpWidget(testWidget);
  
  // Test tablet layout
  await tester.binding.setSurfaceSize(Size(800, 1024));
  await tester.pumpWidget(testWidget);
});
```

## 🤝 Contributing

1. Follow Material Design 3 guidelines
2. Ensure accessibility compliance (WCAG AA)
3. Write comprehensive documentation
4. Include usage examples
5. Add appropriate tests
6. Consider performance implications

## 📄 License

This design system is part of the Mind House project and follows the same licensing terms.

---

For more detailed documentation and examples, see the individual component files and the `DesignSystemDocs` class in `design_system.dart`.