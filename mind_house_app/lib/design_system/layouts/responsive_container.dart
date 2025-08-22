// Enhanced Responsive Container Component
// Material Design 3 compliant responsive layout helper with adaptive breakpoints

import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';

/// Breakpoint definitions for responsive design
class Breakpoints {
  static const double xs = 480;    // Extra small screens (phones in portrait)
  static const double sm = 768;    // Small screens (phones in landscape, tablets in portrait)
  static const double md = 1024;   // Medium screens (tablets in landscape, small laptops)
  static const double lg = 1440;   // Large screens (laptops, desktops)
  static const double xl = 1920;   // Extra large screens (large desktops)
}

/// Device type categories for responsive behavior
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Layout density for different screen sizes
enum LayoutDensity {
  compact,    // Dense layout for mobile
  standard,   // Normal layout for tablets
  comfortable, // Spacious layout for desktop
}

/// Container behavior for different screen sizes
enum ResponsiveBehavior {
  /// Container width follows content constraints
  flexible,

  /// Container maintains fixed maximum widths
  constrained,

  /// Container fills available width
  expanded,

  /// Custom behavior defined by breakpoint rules
  adaptive,
}

/// Configuration for responsive behavior at each breakpoint
class ResponsiveConfig {
  const ResponsiveConfig({
    this.padding,
    this.margin,
    this.maxWidth,
    this.columns,
    this.spacing,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.direction = Axis.horizontal,
  });

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final int? columns;
  final double? spacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final Axis direction;
}

/// Enhanced responsive container with adaptive layouts
/// Supports breakpoint-based configuration and device-specific optimizations
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.behavior = ResponsiveBehavior.adaptive,
    this.density,
    this.padding,
    this.margin,
    this.maxWidth,
    this.minWidth,
    this.backgroundColor,
    this.xsConfig,
    this.smConfig,
    this.mdConfig,
    this.lgConfig,
    this.xlConfig,
    this.enableSafeArea = true,
    this.enableScrolling = false,
    this.scrollController,
    this.physics,
    this.centerContent = false,
    this.semanticLabel,
  });

  /// Child widget to be displayed
  final Widget child;

  /// Responsive behavior type
  final ResponsiveBehavior behavior;

  /// Layout density override
  final LayoutDensity? density;

  /// Default padding (overridden by breakpoint configs)
  final EdgeInsets? padding;

  /// Default margin (overridden by breakpoint configs)
  final EdgeInsets? margin;

  /// Maximum container width
  final double? maxWidth;

  /// Minimum container width
  final double? minWidth;

  /// Background color
  final Color? backgroundColor;

  /// Configuration for extra small screens (< 480px)
  final ResponsiveConfig? xsConfig;

  /// Configuration for small screens (480px - 768px)
  final ResponsiveConfig? smConfig;

  /// Configuration for medium screens (768px - 1024px)
  final ResponsiveConfig? mdConfig;

  /// Configuration for large screens (1024px - 1440px)
  final ResponsiveConfig? lgConfig;

  /// Configuration for extra large screens (> 1440px)
  final ResponsiveConfig? xlConfig;

  /// Whether to respect safe area insets
  final bool enableSafeArea;

  /// Whether to enable scrolling if content overflows
  final bool enableScrolling;

  /// Scroll controller for scrollable content
  final ScrollController? scrollController;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether to center content horizontally
  final bool centerContent;

  /// Accessibility label
  final String? semanticLabel;

  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.sm) return DeviceType.mobile;
    if (width < Breakpoints.md) return DeviceType.tablet;
    if (width < Breakpoints.xl) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Get current layout density based on device type
  static LayoutDensity getLayoutDensity(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return LayoutDensity.compact;
      case DeviceType.tablet:
        return LayoutDensity.standard;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return LayoutDensity.comfortable;
    }
  }

  /// Check if current screen matches breakpoint
  static bool isXs(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.xs;

  static bool isSm(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.xs &&
      MediaQuery.of(context).size.width < Breakpoints.sm;

  static bool isMd(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.sm &&
      MediaQuery.of(context).size.width < Breakpoints.md;

  static bool isLg(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.md &&
      MediaQuery.of(context).size.width < Breakpoints.lg;

  static bool isXl(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.lg;

  /// Get responsive value based on breakpoints
  static T getResponsiveValue<T>(
    BuildContext context, {
    T? xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
    required T defaultValue,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.xl && xl != null) return xl;
    if (width >= Breakpoints.lg && lg != null) return lg;
    if (width >= Breakpoints.md && md != null) return md;
    if (width >= Breakpoints.sm && sm != null) return sm;
    if (width < Breakpoints.sm && xs != null) return xs;
    
    return defaultValue;
  }

  ResponsiveConfig _getCurrentConfig(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.xl && xlConfig != null) return xlConfig!;
    if (width >= Breakpoints.lg && lgConfig != null) return lgConfig!;
    if (width >= Breakpoints.md && mdConfig != null) return mdConfig!;
    if (width >= Breakpoints.sm && smConfig != null) return smConfig!;
    if (width < Breakpoints.sm && xsConfig != null) return xsConfig!;
    
    return const ResponsiveConfig();
  }

  EdgeInsets _getPadding(BuildContext context) {
    final config = _getCurrentConfig(context);
    if (config.padding != null) return config.padding!;
    if (padding != null) return padding!;

    final currentDensity = density ?? getLayoutDensity(context);
    switch (currentDensity) {
      case LayoutDensity.compact:
        return MindHouseDesignTokens.componentPaddingSmall;
      case LayoutDensity.standard:
        return MindHouseDesignTokens.componentPaddingMedium;
      case LayoutDensity.comfortable:
        return MindHouseDesignTokens.componentPaddingLarge;
    }
  }

  EdgeInsets _getMargin(BuildContext context) {
    final config = _getCurrentConfig(context);
    if (config.margin != null) return config.margin!;
    if (margin != null) return margin!;

    return EdgeInsets.zero;
  }

  double? _getMaxWidth(BuildContext context) {
    final config = _getCurrentConfig(context);
    if (config.maxWidth != null) return config.maxWidth;
    if (maxWidth != null) return maxWidth;

    switch (behavior) {
      case ResponsiveBehavior.constrained:
        final width = MediaQuery.of(context).size.width;
        if (width >= Breakpoints.xl) return 1200;
        if (width >= Breakpoints.lg) return 960;
        if (width >= Breakpoints.md) return 720;
        return null;
      case ResponsiveBehavior.flexible:
      case ResponsiveBehavior.expanded:
      case ResponsiveBehavior.adaptive:
        return null;
    }
  }

  BoxConstraints _getConstraints(BuildContext context) {
    final maxW = _getMaxWidth(context);
    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxW ?? double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply responsive configuration
    final currentPadding = _getPadding(context);
    final currentMargin = _getMargin(context);
    final constraints = _getConstraints(context);

    // Wrap with container for styling
    content = Container(
      constraints: constraints,
      padding: currentPadding,
      margin: currentMargin,
      color: backgroundColor,
      child: content,
    );

    // Center content if requested
    if (centerContent) {
      content = Center(child: content);
    }

    // Add scrolling if enabled
    if (enableScrolling) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: physics,
        child: content,
      );
    }

    // Add safe area if enabled
    if (enableSafeArea) {
      content = SafeArea(child: content);
    }

    // Add semantics
    if (semanticLabel != null) {
      content = Semantics(
        label: semanticLabel,
        child: content,
      );
    }

    return content;
  }
}

/// Responsive layout builder for creating adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    required this.fallback,
  });

  /// Widget for extra small screens
  final Widget? xs;

  /// Widget for small screens
  final Widget? sm;

  /// Widget for medium screens
  final Widget? md;

  /// Widget for large screens
  final Widget? lg;

  /// Widget for extra large screens
  final Widget? xl;

  /// Fallback widget if no specific size widget is provided
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer.getResponsiveValue(
      context,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
      defaultValue: fallback,
    );
  }
}

/// Responsive column layout that adapts to screen size
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({
    super.key,
    required this.children,
    this.xsColumns = 1,
    this.smColumns = 2,
    this.mdColumns = 3,
    this.lgColumns = 4,
    this.xlColumns = 4,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  /// Child widgets to display in columns
  final List<Widget> children;

  /// Number of columns for extra small screens
  final int xsColumns;

  /// Number of columns for small screens
  final int smColumns;

  /// Number of columns for medium screens
  final int mdColumns;

  /// Number of columns for large screens
  final int lgColumns;

  /// Number of columns for extra large screens
  final int xlColumns;

  /// Horizontal spacing between items
  final double spacing;

  /// Vertical spacing between rows
  final double runSpacing;

  /// How to align items horizontally
  final WrapAlignment alignment;

  /// How to align rows vertically
  final WrapAlignment runAlignment;

  /// How to align items within their cross axis
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveContainer.getResponsiveValue(
      context,
      xs: xsColumns,
      sm: smColumns,
      md: mdColumns,
      lg: lgColumns,
      xl: xlColumns,
      defaultValue: mdColumns,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = spacing * (columns - 1);
    final itemWidth = (screenWidth - totalSpacing) / columns;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.map((child) {
        return SizedBox(
          width: itemWidth,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Responsive gap widget that adapts spacing to screen size
class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({
    super.key,
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.defaultSize = 16.0,
    this.direction = Axis.vertical,
  });

  /// Gap size for extra small screens
  final double? xs;

  /// Gap size for small screens
  final double? sm;

  /// Gap size for medium screens
  final double? md;

  /// Gap size for large screens
  final double? lg;

  /// Gap size for extra large screens
  final double? xl;

  /// Default gap size
  final double defaultSize;

  /// Gap direction (vertical or horizontal)
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveContainer.getResponsiveValue(
      context,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
      defaultValue: defaultSize,
    );

    return direction == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}

/// Helper class for responsive utilities
class ResponsiveUtils {
  /// Check if device is considered mobile
  static bool isMobile(BuildContext context) {
    return ResponsiveContainer.getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is considered tablet
  static bool isTablet(BuildContext context) {
    return ResponsiveContainer.getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is considered desktop
  static bool isDesktop(BuildContext context) {
    final deviceType = ResponsiveContainer.getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }

  /// Get number of columns based on screen width and item width
  static int getColumnsForWidth(double screenWidth, double itemWidth, {double spacing = 16.0}) {
    if (itemWidth <= 0) return 1;
    
    int columns = 1;
    while (true) {
      final totalSpacing = spacing * (columns - 1);
      final requiredWidth = (itemWidth * columns) + totalSpacing;
      
      if (requiredWidth > screenWidth) break;
      columns++;
    }
    
    return (columns - 1).clamp(1, double.infinity).toInt();
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get screen orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }
}

/// Factory methods for common responsive container configurations
extension ResponsiveContainerFactory on ResponsiveContainer {
  /// Create a container with standard content constraints
  static ResponsiveContainer content({
    Key? key,
    required Widget child,
    bool enableSafeArea = true,
    bool centerContent = true,
    Color? backgroundColor,
  }) {
    return ResponsiveContainer(
      key: key,
      behavior: ResponsiveBehavior.constrained,
      enableSafeArea: enableSafeArea,
      centerContent: centerContent,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create a full-width container
  static ResponsiveContainer fullWidth({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    bool enableSafeArea = true,
    Color? backgroundColor,
  }) {
    return ResponsiveContainer(
      key: key,
      behavior: ResponsiveBehavior.expanded,
      padding: padding,
      enableSafeArea: enableSafeArea,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create a container with custom breakpoint configurations
  static ResponsiveContainer adaptive({
    Key? key,
    required Widget child,
    ResponsiveConfig? xsConfig,
    ResponsiveConfig? smConfig,
    ResponsiveConfig? mdConfig,
    ResponsiveConfig? lgConfig,
    ResponsiveConfig? xlConfig,
    bool enableSafeArea = true,
    Color? backgroundColor,
  }) {
    return ResponsiveContainer(
      key: key,
      behavior: ResponsiveBehavior.adaptive,
      xsConfig: xsConfig,
      smConfig: smConfig,
      mdConfig: mdConfig,
      lgConfig: lgConfig,
      xlConfig: xlConfig,
      enableSafeArea: enableSafeArea,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create a scrollable container for long content
  static ResponsiveContainer scrollable({
    Key? key,
    required Widget child,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    bool enableSafeArea = true,
    Color? backgroundColor,
  }) {
    return ResponsiveContainer(
      key: key,
      behavior: ResponsiveBehavior.constrained,
      enableScrolling: true,
      scrollController: scrollController,
      physics: physics,
      enableSafeArea: enableSafeArea,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}