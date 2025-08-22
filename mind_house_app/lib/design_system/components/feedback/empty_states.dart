// Enhanced Empty States Component
// Material Design 3 compliant empty states with actionable guidance and illustrations

import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';

/// Empty state types for different scenarios
enum EmptyStateType {
  /// No content available
  noContent,

  /// No search results found
  noResults,

  /// No data due to network error
  networkError,

  /// User has no items yet (first time experience)
  firstTime,

  /// Content is loading
  loading,

  /// Permission required
  permissionRequired,

  /// Feature coming soon
  comingSoon,

  /// Custom empty state
  custom,
}

/// Size variants for different layouts
enum EmptyStateSize {
  compact,
  standard,
  expanded,
}

/// Action button configuration
class EmptyStateAction {
  const EmptyStateAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
}

/// Enhanced empty states widget with actionable guidance
/// Supports multiple types, custom illustrations, and call-to-action buttons
class EmptyStates extends StatefulWidget {
  const EmptyStates({
    super.key,
    required this.type,
    this.title,
    this.description,
    this.illustration,
    this.actions = const [],
    this.size = EmptyStateSize.standard,
    this.showAnimation = true,
    this.customContent,
    this.backgroundColor,
    this.textColor,
    this.actionSpacing = 16.0,
    this.semanticLabel,
  });

  /// Type of empty state
  final EmptyStateType type;

  /// Main title text (auto-generated if null)
  final String? title;

  /// Description text (auto-generated if null)
  final String? description;

  /// Custom illustration widget
  final Widget? illustration;

  /// List of action buttons
  final List<EmptyStateAction> actions;

  /// Size variant
  final EmptyStateSize size;

  /// Whether to show entrance animation
  final bool showAnimation;

  /// Custom content widget (overrides default layout)
  final Widget? customContent;

  /// Background color override
  final Color? backgroundColor;

  /// Text color override
  final Color? textColor;

  /// Spacing between action buttons
  final double actionSpacing;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<EmptyStates> createState() => _EmptyStatesState();
}

class _EmptyStatesState extends State<EmptyStates>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MindHouseDesignTokens.animationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeEmphasized,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case EmptyStateSize.compact:
        return const EdgeInsets.all(24.0);
      case EmptyStateSize.standard:
        return const EdgeInsets.all(32.0);
      case EmptyStateSize.expanded:
        return const EdgeInsets.all(48.0);
    }
  }

  double _getIllustrationSize() {
    switch (widget.size) {
      case EmptyStateSize.compact:
        return 80.0;
      case EmptyStateSize.standard:
        return 120.0;
      case EmptyStateSize.expanded:
        return 160.0;
    }
  }

  String _getDefaultTitle() {
    switch (widget.type) {
      case EmptyStateType.noContent:
        return 'No content available';
      case EmptyStateType.noResults:
        return 'No results found';
      case EmptyStateType.networkError:
        return 'Connection problem';
      case EmptyStateType.firstTime:
        return 'Welcome!';
      case EmptyStateType.loading:
        return 'Loading...';
      case EmptyStateType.permissionRequired:
        return 'Permission needed';
      case EmptyStateType.comingSoon:
        return 'Coming soon';
      case EmptyStateType.custom:
        return 'Empty';
    }
  }

  String _getDefaultDescription() {
    switch (widget.type) {
      case EmptyStateType.noContent:
        return 'There\'s nothing here yet. Start by creating your first item.';
      case EmptyStateType.noResults:
        return 'Try adjusting your search terms or filters to find what you\'re looking for.';
      case EmptyStateType.networkError:
        return 'Please check your internet connection and try again.';
      case EmptyStateType.firstTime:
        return 'Get started by exploring the features or creating your first item.';
      case EmptyStateType.loading:
        return 'Please wait while we load your content.';
      case EmptyStateType.permissionRequired:
        return 'This feature requires additional permissions to work properly.';
      case EmptyStateType.comingSoon:
        return 'This feature is currently in development and will be available soon.';
      case EmptyStateType.custom:
        return 'Nothing to show here right now.';
    }
  }

  IconData _getDefaultIcon() {
    switch (widget.type) {
      case EmptyStateType.noContent:
        return Icons.inbox_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off;
      case EmptyStateType.networkError:
        return Icons.wifi_off_outlined;
      case EmptyStateType.firstTime:
        return Icons.explore_outlined;
      case EmptyStateType.loading:
        return Icons.hourglass_empty;
      case EmptyStateType.permissionRequired:
        return Icons.lock_outline;
      case EmptyStateType.comingSoon:
        return Icons.schedule;
      case EmptyStateType.custom:
        return Icons.circle_outlined;
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (widget.type) {
      case EmptyStateType.networkError:
        return theme.colorScheme.error;
      case EmptyStateType.permissionRequired:
        return theme.colorScheme.tertiary;
      case EmptyStateType.firstTime:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.customContent != null) {
      return widget.showAnimation
          ? _wrapWithAnimation(widget.customContent!)
          : widget.customContent!;
    }

    return Semantics(
      label: widget.semanticLabel ?? _getDefaultTitle(),
      child: widget.showAnimation
          ? _wrapWithAnimation(_buildDefaultContent(theme))
          : _buildDefaultContent(theme),
    );
  }

  Widget _wrapWithAnimation(Widget child) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultContent(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: _getPadding(),
      color: widget.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIllustration(theme),
          SizedBox(height: MindHouseDesignTokens.spaceLG),
          _buildTitle(theme),
          SizedBox(height: MindHouseDesignTokens.spaceMD),
          _buildDescription(theme),
          if (widget.actions.isNotEmpty) ...[
            SizedBox(height: MindHouseDesignTokens.spaceXL),
            _buildActions(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    if (widget.illustration != null) {
      return SizedBox(
        width: _getIllustrationSize(),
        height: _getIllustrationSize(),
        child: widget.illustration,
      );
    }

    return Container(
      width: _getIllustrationSize(),
      height: _getIllustrationSize(),
      decoration: BoxDecoration(
        color: _getIconColor(theme).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getDefaultIcon(),
        size: _getIllustrationSize() * 0.4,
        color: _getIconColor(theme),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      widget.title ?? _getDefaultTitle(),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: widget.textColor ?? theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text(
        widget.description ?? _getDefaultDescription(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: widget.textColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    if (widget.actions.length == 1) {
      return _buildSingleAction(theme, widget.actions.first);
    }

    return Wrap(
      spacing: widget.actionSpacing,
      runSpacing: MindHouseDesignTokens.spaceMD,
      alignment: WrapAlignment.center,
      children: widget.actions.map((action) {
        return _buildActionButton(theme, action);
      }).toList(),
    );
  }

  Widget _buildSingleAction(ThemeData theme, EmptyStateAction action) {
    if (action.isPrimary) {
      return ElevatedButton.icon(
        onPressed: action.onPressed,
        icon: action.icon != null ? Icon(action.icon) : const SizedBox.shrink(),
        label: Text(action.label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: MindHouseDesignTokens.spaceLG,
            vertical: MindHouseDesignTokens.spaceMD,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: action.onPressed,
      icon: action.icon != null ? Icon(action.icon) : const SizedBox.shrink(),
      label: Text(action.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: MindHouseDesignTokens.spaceLG,
          vertical: MindHouseDesignTokens.spaceMD,
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme, EmptyStateAction action) {
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: action.onPressed,
        child: Text(action.label),
      );
    }

    return OutlinedButton(
      onPressed: action.onPressed,
      child: Text(action.label),
    );
  }
}

/// Factory methods for common empty state configurations
extension EmptyStatesFactory on EmptyStates {
  /// Create a no content empty state
  static EmptyStates noContent({
    Key? key,
    String? title,
    String? description,
    List<EmptyStateAction> actions = const [],
    Widget? illustration,
    EmptyStateSize size = EmptyStateSize.standard,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.noContent,
      title: title,
      description: description,
      actions: actions,
      illustration: illustration,
      size: size,
    );
  }

  /// Create a no search results empty state
  static EmptyStates noResults({
    Key? key,
    String? query,
    List<EmptyStateAction> actions = const [],
    Widget? illustration,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.noResults,
      title: 'No results for "${query ?? 'your search'}"',
      actions: actions,
      illustration: illustration,
    );
  }

  /// Create a network error empty state
  static EmptyStates networkError({
    Key? key,
    List<EmptyStateAction> actions = const [],
    Widget? illustration,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.networkError,
      actions: actions.isNotEmpty
          ? actions
          : [
              EmptyStateAction(
                label: 'Try again',
                onPressed: () {},
                icon: Icons.refresh,
                isPrimary: true,
              ),
            ],
      illustration: illustration,
    );
  }

  /// Create a first time experience empty state
  static EmptyStates firstTime({
    Key? key,
    String? title,
    String? description,
    required List<EmptyStateAction> actions,
    Widget? illustration,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.firstTime,
      title: title ?? 'Get started',
      description: description ?? 'Welcome! Let\'s help you get started with your first item.',
      actions: actions,
      illustration: illustration,
      size: EmptyStateSize.expanded,
    );
  }

  /// Create a permission required empty state
  static EmptyStates permissionRequired({
    Key? key,
    String? title,
    String? description,
    required List<EmptyStateAction> actions,
    Widget? illustration,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.permissionRequired,
      title: title,
      description: description,
      actions: actions,
      illustration: illustration,
    );
  }

  /// Create a coming soon empty state
  static EmptyStates comingSoon({
    Key? key,
    String? title,
    String? description,
    List<EmptyStateAction> actions = const [],
    Widget? illustration,
  }) {
    return EmptyStates(
      key: key,
      type: EmptyStateType.comingSoon,
      title: title,
      description: description,
      actions: actions,
      illustration: illustration,
    );
  }
}

/// Specialized empty state for lists and collections
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    super.key,
    this.title = 'No items',
    this.description = 'Your list is empty. Add some items to get started.',
    this.addButtonLabel = 'Add item',
    this.onAddPressed,
    this.illustration,
    this.showAddButton = true,
  });

  final String title;
  final String description;
  final String addButtonLabel;
  final VoidCallback? onAddPressed;
  final Widget? illustration;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    return EmptyStates(
      type: EmptyStateType.noContent,
      title: title,
      description: description,
      illustration: illustration,
      actions: showAddButton && onAddPressed != null
          ? [
              EmptyStateAction(
                label: addButtonLabel,
                onPressed: onAddPressed!,
                icon: Icons.add,
                isPrimary: true,
              ),
            ]
          : [],
    );
  }
}

/// Specialized empty state for search results
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    this.query,
    this.onClearFilters,
    this.onSearchAgain,
    this.showSuggestions = false,
    this.suggestions = const [],
    this.onSuggestionTap,
  });

  final String? query;
  final VoidCallback? onClearFilters;
  final VoidCallback? onSearchAgain;
  final bool showSuggestions;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <EmptyStateAction>[];

    if (onClearFilters != null) {
      actions.add(EmptyStateAction(
        label: 'Clear filters',
        onPressed: onClearFilters!,
        icon: Icons.clear_all,
      ));
    }

    if (onSearchAgain != null) {
      actions.add(EmptyStateAction(
        label: 'Search again',
        onPressed: onSearchAgain!,
        icon: Icons.search,
        isPrimary: true,
      ));
    }

    return Column(
      children: [
        EmptyStates.noResults(
          query: query,
          actions: actions,
        ),
        if (showSuggestions && suggestions.isNotEmpty) ...[
          SizedBox(height: MindHouseDesignTokens.spaceLG),
          Container(
            width: double.infinity,
            padding: MindHouseDesignTokens.componentPaddingMedium,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: MindHouseDesignTokens.cardBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try searching for:',
                  style: theme.textTheme.titleSmall,
                ),
                SizedBox(height: MindHouseDesignTokens.spaceMD),
                Wrap(
                  spacing: MindHouseDesignTokens.spaceSM,
                  runSpacing: MindHouseDesignTokens.spaceXS,
                  children: suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      onPressed: () => onSuggestionTap?.call(suggestion),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Specialized empty state for error scenarios
class ErrorEmptyState extends StatelessWidget {
  const ErrorEmptyState({
    super.key,
    this.title = 'Something went wrong',
    this.description = 'An unexpected error occurred. Please try again.',
    this.errorCode,
    this.onRetry,
    this.onReport,
    this.showDetails = false,
    this.errorDetails,
  });

  final String title;
  final String description;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final bool showDetails;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <EmptyStateAction>[];

    if (onRetry != null) {
      actions.add(EmptyStateAction(
        label: 'Try again',
        onPressed: onRetry!,
        icon: Icons.refresh,
        isPrimary: true,
      ));
    }

    if (onReport != null) {
      actions.add(EmptyStateAction(
        label: 'Report issue',
        onPressed: onReport!,
        icon: Icons.bug_report,
      ));
    }

    return Column(
      children: [
        EmptyStates(
          type: EmptyStateType.custom,
          title: title,
          description: description,
          actions: actions,
          illustration: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
        if (showDetails && errorDetails != null) ...[
          SizedBox(height: MindHouseDesignTokens.spaceLG),
          ExpansionTile(
            title: Text(
              'Error details',
              style: theme.textTheme.labelMedium,
            ),
            children: [
              Container(
                width: double.infinity,
                padding: MindHouseDesignTokens.componentPaddingMedium,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: MindHouseDesignTokens.cardBorderRadius,
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorCode != null) ...[
                      Text(
                        'Error Code: $errorCode',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: MindHouseDesignTokens.spaceXS),
                    ],
                    Text(
                      errorDetails!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}