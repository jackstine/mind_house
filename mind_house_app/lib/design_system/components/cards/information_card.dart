// Enhanced Information Card Component
// Material Design 3 compliant card for displaying structured information

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../tokens/design_tokens.dart';

/// Variants for different card styles and use cases
enum InformationCardVariant {
  /// Standard card with balanced visual hierarchy
  standard,

  /// Elevated card with stronger shadow for prominence
  elevated,

  /// Outlined card with border for subtle separation
  outlined,

  /// Filled card with background tint for categorization
  filled,

  /// Compact card with reduced padding for dense layouts
  compact,
}

/// Size variants for responsive layouts
enum InformationCardSize {
  small,
  medium,
  large,
}

/// Enhanced information card with comprehensive features
/// Supports multiple variants, accessibility, and animation
class InformationCard extends StatefulWidget {
  const InformationCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.tags = const [],
    this.leadingIcon,
    this.trailingWidget,
    this.onTap,
    this.onLongPress,
    this.variant = InformationCardVariant.standard,
    this.size = InformationCardSize.medium,
    this.backgroundColor,
    this.borderColor,
    this.isSelected = false,
    this.isEnabled = true,
    this.showActions = false,
    this.actions = const [],
    this.contentPreview,
    this.metadata,
    this.semanticLabel,
    this.heroTag,
  });

  /// Primary title text (required)
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Detailed description text
  final String? description;

  /// List of tags for categorization
  final List<String> tags;

  /// Leading icon or widget
  final Widget? leadingIcon;

  /// Trailing widget (often actions or status indicators)
  final Widget? trailingWidget;

  /// Tap callback for navigation or actions
  final VoidCallback? onTap;

  /// Long press callback for context menus
  final VoidCallback? onLongPress;

  /// Visual style variant
  final InformationCardVariant variant;

  /// Size variant for responsive design
  final InformationCardSize size;

  /// Custom background color (overrides variant defaults)
  final Color? backgroundColor;

  /// Custom border color for outlined variant
  final Color? borderColor;

  /// Selection state for multi-select scenarios
  final bool isSelected;

  /// Enabled state for interaction
  final bool isEnabled;

  /// Whether to show action buttons
  final bool showActions;

  /// List of action widgets
  final List<Widget> actions;

  /// Rich content preview widget
  final Widget? contentPreview;

  /// Additional metadata information
  final Map<String, dynamic>? metadata;

  /// Accessibility label override
  final String? semanticLabel;

  /// Hero animation tag
  final Object? heroTag;

  @override
  State<InformationCard> createState() => _InformationCardState();
}

class _InformationCardState extends State<InformationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: MindHouseDesignTokens.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _elevationAnimation = Tween<double>(
      begin: _getDefaultElevation(),
      end: _getDefaultElevation() + 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getDefaultElevation() {
    switch (widget.variant) {
      case InformationCardVariant.elevated:
        return MindHouseDesignTokens.elevation3;
      case InformationCardVariant.filled:
        return MindHouseDesignTokens.elevation1;
      case InformationCardVariant.outlined:
      case InformationCardVariant.standard:
      case InformationCardVariant.compact:
        return MindHouseDesignTokens.elevation1;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case InformationCardSize.small:
        return const EdgeInsets.all(12.0);
      case InformationCardSize.medium:
        return MindHouseDesignTokens.componentPaddingMedium;
      case InformationCardSize.large:
        return MindHouseDesignTokens.componentPaddingLarge;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    if (widget.isSelected) {
      return theme.colorScheme.primaryContainer;
    }

    switch (widget.variant) {
      case InformationCardVariant.filled:
        return theme.colorScheme.surfaceContainerHigh;
      case InformationCardVariant.standard:
      case InformationCardVariant.elevated:
      case InformationCardVariant.outlined:
      case InformationCardVariant.compact:
        return theme.colorScheme.surface;
    }
  }

  BorderSide? _getBorder(ThemeData theme) {
    if (widget.variant == InformationCardVariant.outlined) {
      return BorderSide(
        color: widget.borderColor ?? theme.colorScheme.outline,
        width: 1.0,
      );
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleHover(bool isHovered) {
    if (!widget.isEnabled) return;
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleFocusChange(bool isFocused) {
    setState(() => _isFocused = isFocused);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = _buildCardContent(theme);

    return Semantics(
      label: widget.semanticLabel ?? widget.title,
      button: widget.onTap != null,
      selected: widget.isSelected,
      enabled: widget.isEnabled,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              color: _getBackgroundColor(theme),
              shape: RoundedRectangleBorder(
                borderRadius: MindHouseDesignTokens.cardBorderRadius,
                side: _getBorder(theme) ?? BorderSide.none,
              ),
              child: widget.heroTag != null
                  ? Hero(
                      tag: widget.heroTag!,
                      child: cardContent,
                    )
                  : cardContent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return InkWell(
      onTap: widget.isEnabled ? widget.onTap : null,
      onLongPress: widget.isEnabled ? widget.onLongPress : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onHover: _handleHover,
      onFocusChange: _handleFocusChange,
      borderRadius: MindHouseDesignTokens.cardBorderRadius,
      child: Container(
        padding: _getPadding(),
        constraints: BoxConstraints(
          minHeight: MindHouseDesignTokens.cardMinHeight,
          maxHeight: MindHouseDesignTokens.cardMaxHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            if (widget.description != null) ...[
              SizedBox(height: MindHouseDesignTokens.spaceSM),
              _buildDescription(theme),
            ],
            if (widget.contentPreview != null) ...[
              SizedBox(height: MindHouseDesignTokens.spaceMD),
              widget.contentPreview!,
            ],
            if (widget.tags.isNotEmpty) ...[
              SizedBox(height: MindHouseDesignTokens.spaceMD),
              _buildTags(theme),
            ],
            if (widget.showActions && widget.actions.isNotEmpty) ...[
              SizedBox(height: MindHouseDesignTokens.spaceMD),
              _buildActions(theme),
            ],
            if (widget.metadata != null) ...[
              SizedBox(height: MindHouseDesignTokens.spaceSM),
              _buildMetadata(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (widget.leadingIcon != null) ...[
          widget.leadingIcon!,
          SizedBox(width: MindHouseDesignTokens.spaceMD),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: _getTitleStyle(theme),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                SizedBox(height: MindHouseDesignTokens.spaceXS),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (widget.trailingWidget != null) ...[
          SizedBox(width: MindHouseDesignTokens.spaceMD),
          widget.trailingWidget!,
        ],
        if (widget.isSelected)
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: MindHouseDesignTokens.iconSizeMedium,
          ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.description!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: MindHouseDesignTokens.spaceSM,
      runSpacing: MindHouseDesignTokens.spaceXS,
      children: widget.tags.take(5).map((tag) {
        return Chip(
          label: Text(
            tag,
            style: theme.textTheme.labelSmall,
          ),
          backgroundColor: theme.colorScheme.secondaryContainer,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: MindHouseDesignTokens.spaceSM,
            vertical: MindHouseDesignTokens.spaceXS,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widget.actions
          .map((action) => Padding(
                padding: EdgeInsets.only(left: MindHouseDesignTokens.spaceSM),
                child: action,
              ))
          .toList(),
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Text(
      widget.metadata!.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(' • '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  TextStyle? _getTitleStyle(ThemeData theme) {
    switch (widget.size) {
      case InformationCardSize.small:
        return theme.textTheme.titleSmall;
      case InformationCardSize.medium:
        return theme.textTheme.titleMedium;
      case InformationCardSize.large:
        return theme.textTheme.titleLarge;
    }
  }
}

/// Factory methods for common card configurations
extension InformationCardFactory on InformationCard {
  /// Create a note card for displaying user notes
  static InformationCard note({
    Key? key,
    required String title,
    String? content,
    List<String> tags = const [],
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return InformationCard(
      key: key,
      title: title,
      description: content,
      tags: tags,
      onTap: onTap,
      isSelected: isSelected,
      leadingIcon: const Icon(Icons.note_outlined),
      variant: InformationCardVariant.standard,
      size: InformationCardSize.medium,
    );
  }

  /// Create a task card for displaying tasks or todos
  static InformationCard task({
    Key? key,
    required String title,
    String? description,
    bool isCompleted = false,
    VoidCallback? onTap,
    VoidCallback? onToggleComplete,
  }) {
    return InformationCard(
      key: key,
      title: title,
      description: description,
      onTap: onTap,
      leadingIcon: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? Colors.green : null,
      ),
      variant: InformationCardVariant.outlined,
      size: InformationCardSize.medium,
    );
  }

  /// Create an article card for displaying articles or documents
  static InformationCard article({
    Key? key,
    required String title,
    String? author,
    String? excerpt,
    List<String> tags = const [],
    VoidCallback? onTap,
    Widget? thumbnail,
  }) {
    return InformationCard(
      key: key,
      title: title,
      subtitle: author,
      description: excerpt,
      tags: tags,
      onTap: onTap,
      leadingIcon: thumbnail ?? const Icon(Icons.article_outlined),
      variant: InformationCardVariant.elevated,
      size: InformationCardSize.large,
    );
  }
}