// Enhanced Content Area Component
// Material Design 3 compliant content layout with proper spacing and scroll behavior

import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import 'responsive_container.dart';

/// Content area layout types
enum ContentAreaType {
  /// Standard content with normal padding
  standard,

  /// Compact layout with reduced spacing
  compact,

  /// Spacious layout with increased spacing
  spacious,

  /// Full bleed content that extends to edges
  fullBleed,

  /// Article-style content with optimal reading width
  article,
}

/// Scroll behavior options
enum ScrollBehavior {
  /// Auto scroll based on content overflow
  auto,

  /// Always scrollable
  always,

  /// Never scrollable
  never,

  /// Custom scroll behavior
  custom,
}

/// Content alignment options
enum ContentAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  stretch,
}

/// Enhanced content area with comprehensive layout features
/// Supports responsive design, proper spacing, and scroll management
class ContentArea extends StatefulWidget {
  const ContentArea({
    super.key,
    required this.child,
    this.type = ContentAreaType.standard,
    this.alignment = ContentAlignment.stretch,
    this.scrollBehavior = ScrollBehavior.auto,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.constraints,
    this.maxWidth,
    this.minHeight,
    this.enableSafeArea = true,
    this.enableRefreshIndicator = false,
    this.onRefresh,
    this.scrollController,
    this.physics,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.semanticChildCount,
    this.semanticLabel,
    this.loadingOverlay,
    this.errorOverlay,
    this.isLoading = false,
    this.hasError = false,
  });

  /// Main content widget
  final Widget child;

  /// Content area layout type
  final ContentAreaType type;

  /// Content alignment within the area
  final ContentAlignment alignment;

  /// Scroll behavior configuration
  final ScrollBehavior scrollBehavior;

  /// Custom padding (overrides type defaults)
  final EdgeInsets? padding;

  /// Margin around the content area
  final EdgeInsets? margin;

  /// Background color
  final Color? backgroundColor;

  /// Box constraints for the content area
  final BoxConstraints? constraints;

  /// Maximum width for content (useful for article type)
  final double? maxWidth;

  /// Minimum height for the content area
  final double? minHeight;

  /// Whether to respect safe area insets
  final bool enableSafeArea;

  /// Whether to enable pull-to-refresh
  final bool enableRefreshIndicator;

  /// Callback for refresh action
  final Future<void> Function()? onRefresh;

  /// Custom scroll controller
  final ScrollController? scrollController;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Keyboard dismiss behavior
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Clip behavior for content
  final Clip clipBehavior;

  /// Semantic child count for accessibility
  final int? semanticChildCount;

  /// Accessibility label
  final String? semanticLabel;

  /// Loading overlay widget
  final Widget? loadingOverlay;

  /// Error overlay widget
  final Widget? errorOverlay;

  /// Whether content is loading
  final bool isLoading;

  /// Whether there's an error state
  final bool hasError;

  @override
  State<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    
    _overlayController = AnimationController(
      duration: MindHouseDesignTokens.animationMedium,
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    if (widget.isLoading || widget.hasError) {
      _overlayController.forward();
    }
  }

  @override
  void didUpdateWidget(ContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading ||
        widget.hasError != oldWidget.hasError) {
      if (widget.isLoading || widget.hasError) {
        _overlayController.forward();
      } else {
        _overlayController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  EdgeInsets _getPadding(BuildContext context) {
    if (widget.padding != null) return widget.padding!;

    switch (widget.type) {
      case ContentAreaType.compact:
        return MindHouseDesignTokens.componentPaddingSmall;
      case ContentAreaType.standard:
        return MindHouseDesignTokens.componentPaddingMedium;
      case ContentAreaType.spacious:
        return MindHouseDesignTokens.componentPaddingLarge;
      case ContentAreaType.fullBleed:
        return EdgeInsets.zero;
      case ContentAreaType.article:
        return const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceXL,
        );
    }
  }

  double? _getMaxWidth() {
    if (widget.maxWidth != null) return widget.maxWidth;

    switch (widget.type) {
      case ContentAreaType.article:
        return 720.0; // Optimal reading width
      default:
        return null;
    }
  }

  Alignment _getContentAlignment() {
    switch (widget.alignment) {
      case ContentAlignment.topLeft:
        return Alignment.topLeft;
      case ContentAlignment.topCenter:
        return Alignment.topCenter;
      case ContentAlignment.topRight:
        return Alignment.topRight;
      case ContentAlignment.centerLeft:
        return Alignment.centerLeft;
      case ContentAlignment.center:
        return Alignment.center;
      case ContentAlignment.centerRight:
        return Alignment.centerRight;
      case ContentAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case ContentAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case ContentAlignment.bottomRight:
        return Alignment.bottomRight;
      case ContentAlignment.stretch:
        return Alignment.center; // Will be handled differently
    }
  }

  bool _shouldScroll(BuildContext context) {
    switch (widget.scrollBehavior) {
      case ScrollBehavior.always:
        return true;
      case ScrollBehavior.never:
        return false;
      case ScrollBehavior.auto:
        // Determine based on content and screen size
        return true; // Default to scrollable for auto
      case ScrollBehavior.custom:
        return widget.physics != const NeverScrollableScrollPhysics();
    }
  }

  Widget _buildContent(BuildContext context) {
    Widget content = widget.child;

    // Apply constraints if specified
    final maxWidth = _getMaxWidth();
    if (maxWidth != null || widget.constraints != null) {
      content = ConstrainedBox(
        constraints: widget.constraints ??
            BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: content,
      );
    }

    // Apply alignment (except stretch which is handled by container)
    if (widget.alignment != ContentAlignment.stretch) {
      content = Align(
        alignment: _getContentAlignment(),
        child: content,
      );
    }

    // Apply minimum height if specified
    if (widget.minHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.minHeight!),
        child: content,
      );
    }

    return content;
  }

  Widget _buildScrollableContent(BuildContext context) {
    Widget content = _buildContent(context);
    
    if (!_shouldScroll(context)) {
      return content;
    }

    // Wrap in scrollable widget
    Widget scrollable = SingleChildScrollView(
      controller: widget.scrollController,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      child: content,
    );

    // Add pull-to-refresh if enabled
    if (widget.enableRefreshIndicator && widget.onRefresh != null) {
      scrollable = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: scrollable,
      );
    }

    return scrollable;
  }

  Widget _buildOverlay(Widget overlay) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.3 * _overlayAnimation.value),
            child: Center(child: overlay),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildScrollableContent(context);

    // Apply padding
    final padding = _getPadding(context);
    if (padding != EdgeInsets.zero) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    // Apply margin
    if (widget.margin != null) {
      content = Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    // Apply background color and container styling
    content = Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: content,
    );

    // Apply safe area if enabled
    if (widget.enableSafeArea) {
      content = SafeArea(child: content);
    }

    // Add overlays if present
    final overlays = <Widget>[];
    
    if (widget.isLoading && widget.loadingOverlay != null) {
      overlays.add(Positioned.fill(
        child: _buildOverlay(widget.loadingOverlay!),
      ));
    }
    
    if (widget.hasError && widget.errorOverlay != null) {
      overlays.add(Positioned.fill(
        child: _buildOverlay(widget.errorOverlay!),
      ));
    }

    if (overlays.isNotEmpty) {
      content = Stack(
        children: [
          content,
          ...overlays,
        ],
      );
    }

    // Add semantics
    if (widget.semanticLabel != null || widget.semanticChildCount != null) {
      content = Semantics(
        label: widget.semanticLabel,
        childCount: widget.semanticChildCount,
        child: content,
      );
    }

    return content;
  }
}

/// Specialized content area for lists and collections
class ListContentArea extends StatelessWidget {
  const ListContentArea({
    super.key,
    required this.children,
    this.type = ContentAreaType.standard,
    this.spacing = 8.0,
    this.scrollable = true,
    this.physics,
    this.controller,
    this.padding,
    this.enableRefresh = false,
    this.onRefresh,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.isLoading = false,
    this.hasError = false,
    this.semanticLabel,
  });

  /// List of child widgets
  final List<Widget> children;

  /// Content area type
  final ContentAreaType type;

  /// Spacing between list items
  final double spacing;

  /// Whether the list is scrollable
  final bool scrollable;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Scroll controller
  final ScrollController? controller;

  /// List padding
  final EdgeInsets? padding;

  /// Whether to enable pull-to-refresh
  final bool enableRefresh;

  /// Refresh callback
  final Future<void> Function()? onRefresh;

  /// Widget to show when list is empty
  final Widget? emptyState;

  /// Widget to show when loading
  final Widget? loadingState;

  /// Widget to show when error occurs
  final Widget? errorState;

  /// Whether content is loading
  final bool isLoading;

  /// Whether there's an error
  final bool hasError;

  /// Accessibility label
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Handle empty state
    if (!isLoading && !hasError && children.isEmpty && emptyState != null) {
      return ContentArea(
        type: type,
        alignment: ContentAlignment.center,
        scrollBehavior: ScrollBehavior.never,
        child: emptyState!,
        semanticLabel: semanticLabel,
      );
    }

    // Build list content
    Widget content = Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < children.length - 1 ? spacing : 0,
          ),
          child: child,
        );
      }).toList(),
    );

    return ContentArea(
      type: type,
      scrollBehavior: scrollable ? ScrollBehavior.always : ScrollBehavior.never,
      physics: physics,
      scrollController: controller,
      padding: padding,
      enableRefreshIndicator: enableRefresh,
      onRefresh: onRefresh,
      loadingOverlay: loadingState,
      errorOverlay: errorState,
      isLoading: isLoading,
      hasError: hasError,
      semanticChildCount: children.length,
      semanticLabel: semanticLabel,
      child: content,
    );
  }
}

/// Specialized content area for forms
class FormContentArea extends StatelessWidget {
  const FormContentArea({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.padding,
    this.maxWidth = 600.0,
    this.enableKeyboardAvoidance = true,
    this.scrollable = true,
    this.physics,
    this.semanticLabel,
  });

  /// Form field widgets
  final List<Widget> children;

  /// Spacing between form fields
  final double spacing;

  /// Form padding
  final EdgeInsets? padding;

  /// Maximum form width
  final double maxWidth;

  /// Whether to avoid keyboard overlap
  final bool enableKeyboardAvoidance;

  /// Whether form is scrollable
  final bool scrollable;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Accessibility label
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < children.length - 1 ? spacing : 0,
          ),
          child: child,
        );
      }).toList(),
    );

    return ContentArea(
      type: ContentAreaType.standard,
      alignment: ContentAlignment.topCenter,
      maxWidth: maxWidth,
      padding: padding,
      scrollBehavior: scrollable ? ScrollBehavior.always : ScrollBehavior.never,
      physics: physics,
      keyboardDismissBehavior: enableKeyboardAvoidance
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      semanticLabel: semanticLabel ?? 'Form content area',
      child: content,
    );
  }
}

/// Factory methods for common content area configurations
extension ContentAreaFactory on ContentArea {
  /// Create a standard content area
  static ContentArea standard({
    Key? key,
    required Widget child,
    bool enableSafeArea = true,
    Color? backgroundColor,
  }) {
    return ContentArea(
      key: key,
      type: ContentAreaType.standard,
      enableSafeArea: enableSafeArea,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create a compact content area for dense layouts
  static ContentArea compact({
    Key? key,
    required Widget child,
    bool scrollable = true,
    Color? backgroundColor,
  }) {
    return ContentArea(
      key: key,
      type: ContentAreaType.compact,
      scrollBehavior: scrollable ? ScrollBehavior.always : ScrollBehavior.never,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create an article-style content area for reading
  static ContentArea article({
    Key? key,
    required Widget child,
    bool enableSafeArea = true,
    Color? backgroundColor,
  }) {
    return ContentArea(
      key: key,
      type: ContentAreaType.article,
      alignment: ContentAlignment.topCenter,
      enableSafeArea: enableSafeArea,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Create a full-bleed content area
  static ContentArea fullBleed({
    Key? key,
    required Widget child,
    bool scrollable = true,
    ScrollPhysics? physics,
  }) {
    return ContentArea(
      key: key,
      type: ContentAreaType.fullBleed,
      scrollBehavior: scrollable ? ScrollBehavior.always : ScrollBehavior.never,
      physics: physics,
      enableSafeArea: false,
      child: child,
    );
  }

  /// Create a centered content area
  static ContentArea centered({
    Key? key,
    required Widget child,
    double? maxWidth,
    Color? backgroundColor,
  }) {
    return ContentArea(
      key: key,
      type: ContentAreaType.standard,
      alignment: ContentAlignment.center,
      maxWidth: maxWidth,
      scrollBehavior: ScrollBehavior.never,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}