// Enhanced Flexible Grid Component
// Material Design 3 compliant grid layout for information organization

import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import 'responsive_container.dart';

/// Grid item alignment options
enum GridItemAlignment {
  start,
  center,
  end,
  stretch,
}

/// Grid layout behavior
enum GridLayoutBehavior {
  /// Fixed number of columns
  fixed,

  /// Responsive columns based on breakpoints
  responsive,

  /// Auto-fit columns based on minimum item width
  autoFit,

  /// Masonry-style layout with varying item heights
  masonry,
}

/// Grid item sizing configuration
class GridItemSize {
  const GridItemSize({
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.aspectRatio,
    this.flex = 1,
  });

  final double? width;
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final double? aspectRatio;
  final int flex;

  /// Create a square item
  static GridItemSize square(double size) => GridItemSize(
        width: size,
        height: size,
      );

  /// Create an item with aspect ratio
  static GridItemSize aspectRatio(double ratio) => GridItemSize(
        aspectRatio: ratio,
      );

  /// Create a flexible item
  static GridItemSize flexible([int flex = 1]) => GridItemSize(
        flex: flex,
      );
}

/// Individual grid item configuration
class GridItem {
  const GridItem({
    required this.child,
    this.size,
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.alignment = GridItemAlignment.stretch,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final GridItemSize? size;
  final int columnSpan;
  final int rowSpan;
  final GridItemAlignment alignment;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final String? semanticLabel;
}

/// Enhanced flexible grid widget for information organization
/// Supports responsive layouts, masonry style, and custom item sizing
class FlexibleGrid extends StatefulWidget {
  const FlexibleGrid({
    super.key,
    required this.items,
    this.behavior = GridLayoutBehavior.responsive,
    this.columns = 2,
    this.xsColumns = 1,
    this.smColumns = 2,
    this.mdColumns = 3,
    this.lgColumns = 4,
    this.xlColumns = 4,
    this.minItemWidth = 200.0,
    this.maxItemWidth,
    this.itemAspectRatio,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.primary = false,
    this.itemAlignment = GridItemAlignment.stretch,
    this.enableReordering = false,
    this.onReorder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.staggerAnimation = false,
    this.semanticLabel,
  });

  /// List of grid items
  final List<GridItem> items;

  /// Grid layout behavior
  final GridLayoutBehavior behavior;

  /// Fixed number of columns (for fixed behavior)
  final int columns;

  /// Columns for different breakpoints (for responsive behavior)
  final int xsColumns;
  final int smColumns;
  final int mdColumns;
  final int lgColumns;
  final int xlColumns;

  /// Minimum item width (for autoFit behavior)
  final double minItemWidth;

  /// Maximum item width (for autoFit behavior)
  final double? maxItemWidth;

  /// Default aspect ratio for items
  final double? itemAspectRatio;

  /// Vertical spacing between items
  final double mainAxisSpacing;

  /// Horizontal spacing between items
  final double crossAxisSpacing;

  /// Padding around the grid
  final EdgeInsets? padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether to size the grid to its content
  final bool shrinkWrap;

  /// Whether this is the primary scroll view
  final bool primary;

  /// Default alignment for items
  final GridItemAlignment itemAlignment;

  /// Whether items can be reordered
  final bool enableReordering;

  /// Callback when items are reordered
  final ValueChanged<List<GridItem>>? onReorder;

  /// Animation duration for layout changes
  final Duration animationDuration;

  /// Whether to stagger item animations
  final bool staggerAnimation;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<FlexibleGrid> createState() => _FlexibleGridState();
}

class _FlexibleGridState extends State<FlexibleGrid>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<AnimationController> _itemAnimationControllers = [];
  List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(FlexibleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupAnimations() {
    _animationController?.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _itemAnimationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: widget.animationDuration.inMilliseconds +
              (widget.staggerAnimation ? index * 100 : 0),
        ),
        vsync: this,
      ),
    );

    _itemAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: MindHouseDesignTokens.easeStandard,
      ));
    }).toList();

    // Start animations
    _animationController.forward();
    for (int i = 0; i < _itemAnimationControllers.length; i++) {
      if (widget.staggerAnimation) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _itemAnimationControllers[i].forward();
          }
        });
      } else {
        _itemAnimationControllers[i].forward();
      }
    }
  }

  int _getColumnsForCurrentScreen(BuildContext context) {
    switch (widget.behavior) {
      case GridLayoutBehavior.fixed:
        return widget.columns;
      case GridLayoutBehavior.responsive:
        return ResponsiveContainer.getResponsiveValue(
          context,
          xs: widget.xsColumns,
          sm: widget.smColumns,
          md: widget.mdColumns,
          lg: widget.lgColumns,
          xl: widget.xlColumns,
          defaultValue: widget.columns,
        );
      case GridLayoutBehavior.autoFit:
        final screenWidth = MediaQuery.of(context).size.width;
        final padding = widget.padding ?? EdgeInsets.zero;
        final availableWidth = screenWidth - padding.horizontal;
        return ResponsiveUtils.getColumnsForWidth(
          availableWidth,
          widget.minItemWidth,
          spacing: widget.crossAxisSpacing,
        );
      case GridLayoutBehavior.masonry:
        return ResponsiveContainer.getResponsiveValue(
          context,
          xs: widget.xsColumns,
          sm: widget.smColumns,
          md: widget.mdColumns,
          lg: widget.lgColumns,
          xl: widget.xlColumns,
          defaultValue: widget.columns,
        );
    }
  }

  double _getItemWidth(BuildContext context, int columns) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = widget.padding ?? EdgeInsets.zero;
    final availableWidth = screenWidth - padding.horizontal;
    final totalSpacing = widget.crossAxisSpacing * (columns - 1);
    return (availableWidth - totalSpacing) / columns;
  }

  Widget _buildGridItem(
    BuildContext context,
    GridItem item,
    int index,
    double itemWidth,
  ) {
    Widget child = item.child;

    // Apply item padding
    if (item.padding != null) {
      child = Padding(
        padding: item.padding!,
        child: child,
      );
    }

    // Apply size constraints
    if (item.size != null) {
      final size = item.size!;
      child = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: size.minWidth ?? 0,
          maxWidth: size.maxWidth ?? double.infinity,
          minHeight: size.minHeight ?? 0,
          maxHeight: size.maxHeight ?? double.infinity,
        ),
        child: size.aspectRatio != null
            ? AspectRatio(
                aspectRatio: size.aspectRatio!,
                child: child,
              )
            : child,
      );
    } else if (widget.itemAspectRatio != null) {
      child = AspectRatio(
        aspectRatio: widget.itemAspectRatio!,
        child: child,
      );
    }

    // Apply alignment
    final alignment = item.alignment != GridItemAlignment.stretch
        ? item.alignment
        : widget.itemAlignment;

    switch (alignment) {
      case GridItemAlignment.start:
        child = Align(
          alignment: Alignment.topLeft,
          child: child,
        );
        break;
      case GridItemAlignment.center:
        child = Center(child: child);
        break;
      case GridItemAlignment.end:
        child = Align(
          alignment: Alignment.bottomRight,
          child: child,
        );
        break;
      case GridItemAlignment.stretch:
        // No change needed
        break;
    }

    // Apply container styling
    if (item.backgroundColor != null ||
        item.borderRadius != null ||
        item.elevation != null) {
      child = Card(
        color: item.backgroundColor,
        shape: item.borderRadius != null
            ? RoundedRectangleBorder(borderRadius: item.borderRadius!)
            : null,
        elevation: item.elevation ?? 0,
        child: child,
      );
    }

    // Add tap handling
    if (item.onTap != null) {
      child = InkWell(
        onTap: item.onTap,
        borderRadius: item.borderRadius ?? MindHouseDesignTokens.cardBorderRadius,
        child: child,
      );
    }

    // Add margin
    if (item.margin != null) {
      child = Padding(
        padding: item.margin!,
        child: child,
      );
    }

    // Add semantics
    if (item.semanticLabel != null) {
      child = Semantics(
        label: item.semanticLabel,
        child: child,
      );
    }

    // Apply animation
    if (index < _itemAnimations.length) {
      child = AnimatedBuilder(
        animation: _itemAnimations[index],
        builder: (context, _) {
          return Transform.scale(
            scale: _itemAnimations[index].value,
            child: Opacity(
              opacity: _itemAnimations[index].value,
              child: child,
            ),
          );
        },
      );
    }

    return SizedBox(
      width: itemWidth * item.columnSpan +
          (widget.crossAxisSpacing * (item.columnSpan - 1)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final columns = _getColumnsForCurrentScreen(context);
    final itemWidth = _getItemWidth(context, columns);

    Widget content;

    if (widget.behavior == GridLayoutBehavior.masonry) {
      content = _buildMasonryLayout(context, columns, itemWidth);
    } else {
      content = _buildRegularLayout(context, columns, itemWidth);
    }

    // Add padding
    if (widget.padding != null) {
      content = Padding(
        padding: widget.padding!,
        child: content,
      );
    }

    // Add semantics
    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        child: content,
      );
    }

    return content;
  }

  Widget _buildRegularLayout(BuildContext context, int columns, double itemWidth) {
    return GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      primary: widget.primary,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.itemAspectRatio ?? 1.0,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildGridItem(context, widget.items[index], index, itemWidth);
      },
    );
  }

  Widget _buildMasonryLayout(BuildContext context, int columns, double itemWidth) {
    // Create column lists
    final columnChildren = List.generate(columns, (_) => <Widget>[]);
    final columnHeights = List.generate(columns, (_) => 0.0);

    // Distribute items across columns
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      
      // Find column with minimum height
      int targetColumn = 0;
      for (int j = 1; j < columns; j++) {
        if (columnHeights[j] < columnHeights[targetColumn]) {
          targetColumn = j;
        }
      }

      // Add item to column
      final itemWidget = _buildGridItem(context, item, i, itemWidth);
      columnChildren[targetColumn].add(itemWidget);
      
      // Add spacing
      if (columnChildren[targetColumn].length > 1) {
        columnChildren[targetColumn].insert(
          columnChildren[targetColumn].length - 1,
          SizedBox(height: widget.mainAxisSpacing),
        );
      }

      // Estimate item height (this is approximate)
      final estimatedHeight = itemWidth / (widget.itemAspectRatio ?? 1.0);
      columnHeights[targetColumn] += estimatedHeight + widget.mainAxisSpacing;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren.asMap().entries.map((entry) {
        final index = entry.key;
        final children = entry.value;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < columns - 1 ? widget.crossAxisSpacing : 0,
            ),
            child: Column(
              children: children,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Specialized grid for displaying cards
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.cards,
    this.columns,
    this.minItemWidth = 280.0,
    this.aspectRatio = 1.2,
    this.spacing = 16.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<Widget> cards;
  final int? columns;
  final double minItemWidth;
  final double aspectRatio;
  final double spacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return FlexibleGrid(
      behavior: columns != null
          ? GridLayoutBehavior.fixed
          : GridLayoutBehavior.autoFit,
      columns: columns ?? 2,
      minItemWidth: minItemWidth,
      itemAspectRatio: aspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      items: cards
          .map((card) => GridItem(
                child: card,
                backgroundColor: Theme.of(context).colorScheme.surface,
                borderRadius: MindHouseDesignTokens.cardBorderRadius,
                elevation: MindHouseDesignTokens.elevation1,
              ))
          .toList(),
    );
  }
}

/// Specialized grid for image galleries
class ImageGrid extends StatelessWidget {
  const ImageGrid({
    super.key,
    required this.images,
    this.columns = 3,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.onImageTap,
    this.enableHeroAnimation = true,
  });

  final List<Widget> images;
  final int columns;
  final double aspectRatio;
  final double spacing;
  final ValueChanged<int>? onImageTap;
  final bool enableHeroAnimation;

  @override
  Widget build(BuildContext context) {
    return FlexibleGrid(
      behavior: GridLayoutBehavior.responsive,
      xsColumns: 2,
      smColumns: 3,
      mdColumns: columns,
      lgColumns: columns,
      xlColumns: columns,
      itemAspectRatio: aspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      items: images.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        
        Widget child = ClipRRect(
          borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusMD),
          child: image,
        );

        if (enableHeroAnimation) {
          child = Hero(
            tag: 'image_$index',
            child: child,
          );
        }

        return GridItem(
          child: child,
          onTap: onImageTap != null ? () => onImageTap!(index) : null,
        );
      }).toList(),
    );
  }
}

/// Factory methods for common grid configurations
extension FlexibleGridFactory on FlexibleGrid {
  /// Create a responsive card grid
  static FlexibleGrid cards({
    Key? key,
    required List<Widget> cards,
    double minItemWidth = 280.0,
    double aspectRatio = 1.2,
    double spacing = 16.0,
  }) {
    return FlexibleGrid(
      key: key,
      behavior: GridLayoutBehavior.autoFit,
      minItemWidth: minItemWidth,
      itemAspectRatio: aspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      items: cards
          .map((card) => GridItem(
                child: card,
                borderRadius: MindHouseDesignTokens.cardBorderRadius,
              ))
          .toList(),
    );
  }

  /// Create a masonry-style grid
  static FlexibleGrid masonry({
    Key? key,
    required List<Widget> items,
    int columns = 2,
    double spacing = 16.0,
  }) {
    return FlexibleGrid(
      key: key,
      behavior: GridLayoutBehavior.masonry,
      columns: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      items: items
          .map((item) => GridItem(child: item))
          .toList(),
    );
  }

  /// Create a uniform grid
  static FlexibleGrid uniform({
    Key? key,
    required List<Widget> items,
    int columns = 2,
    double aspectRatio = 1.0,
    double spacing = 16.0,
  }) {
    return FlexibleGrid(
      key: key,
      behavior: GridLayoutBehavior.responsive,
      smColumns: columns,
      mdColumns: columns,
      lgColumns: columns,
      xlColumns: columns,
      itemAspectRatio: aspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      items: items
          .map((item) => GridItem(child: item))
          .toList(),
    );
  }
}