// Enhanced Loading States Component
// Material Design 3 compliant loading indicators with skeleton screens and progressive loading

import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';

/// Loading state types for different content
enum LoadingStateType {
  /// Simple circular progress indicator
  circular,

  /// Linear progress bar
  linear,

  /// Skeleton screen mimicking content structure
  skeleton,

  /// Shimmer effect for content loading
  shimmer,

  /// Pulse animation for placeholders
  pulse,

  /// Custom loading animation
  custom,
}

/// Loading size variants
enum LoadingSize {
  small,
  medium,
  large,
}

/// Enhanced loading states widget with multiple animation types
/// Supports skeleton screens, shimmer effects, and progressive loading
class LoadingStates extends StatefulWidget {
  const LoadingStates({
    super.key,
    this.type = LoadingStateType.circular,
    this.size = LoadingSize.medium,
    this.message,
    this.progress,
    this.duration = const Duration(milliseconds: 1500),
    this.color,
    this.backgroundColor,
    this.isVisible = true,
    this.showMessage = true,
    this.customAnimation,
    this.semanticLabel,
    this.skeletonConfig,
  });

  /// Type of loading animation
  final LoadingStateType type;

  /// Size variant
  final LoadingSize size;

  /// Optional loading message
  final String? message;

  /// Progress value (0.0 to 1.0) for determinate loading
  final double? progress;

  /// Animation duration
  final Duration duration;

  /// Primary color for the loading indicator
  final Color? color;

  /// Background color for skeleton/shimmer effects
  final Color? backgroundColor;

  /// Whether the loading state is visible
  final bool isVisible;

  /// Whether to show the loading message
  final bool showMessage;

  /// Custom animation widget
  final Widget? customAnimation;

  /// Accessibility label
  final String? semanticLabel;

  /// Configuration for skeleton loading
  final SkeletonConfig? skeletonConfig;

  @override
  State<LoadingStates> createState() => _LoadingStatesState();
}

class _LoadingStatesState extends State<LoadingStates>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _primaryController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    if (widget.isVisible) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(LoadingStates oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _primaryController.forward();
    
    if (widget.type == LoadingStateType.shimmer ||
        widget.type == LoadingStateType.pulse) {
      _shimmerController.repeat();
    }
  }

  void _stopAnimations() {
    _primaryController.reverse();
    _shimmerController.stop();
  }

  double _getSizeValue() {
    switch (widget.size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.medium:
        return 32.0;
      case LoadingSize.large:
        return 48.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? 'Loading',
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildLoadingWidget(theme),
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    switch (widget.type) {
      case LoadingStateType.circular:
        return _buildCircularLoading(theme);
      case LoadingStateType.linear:
        return _buildLinearLoading(theme);
      case LoadingStateType.skeleton:
        return _buildSkeletonLoading(theme);
      case LoadingStateType.shimmer:
        return _buildShimmerLoading(theme);
      case LoadingStateType.pulse:
        return _buildPulseLoading(theme);
      case LoadingStateType.custom:
        return widget.customAnimation ?? _buildCircularLoading(theme);
    }
  }

  Widget _buildCircularLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getSizeValue(),
            height: _getSizeValue(),
            child: CircularProgressIndicator(
              value: widget.progress,
              color: widget.color ?? theme.colorScheme.primary,
              strokeWidth: 3.0,
            ),
          ),
          if (widget.showMessage && widget.message != null) ...[
            SizedBox(height: MindHouseDesignTokens.spaceMD),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinearLoading(ThemeData theme) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: widget.progress,
          color: widget.color ?? theme.colorScheme.primary,
          backgroundColor: widget.backgroundColor ?? 
              theme.colorScheme.surfaceContainer,
        ),
        if (widget.showMessage && widget.message != null) ...[
          SizedBox(height: MindHouseDesignTokens.spaceMD),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonLoading(ThemeData theme) {
    final config = widget.skeletonConfig ?? SkeletonConfig.defaultConfig();
    
    return Column(
      children: List.generate(config.itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: MindHouseDesignTokens.spaceMD),
          child: _buildSkeletonItem(theme, config),
        );
      }),
    );
  }

  Widget _buildSkeletonItem(ThemeData theme, SkeletonConfig config) {
    return Container(
      padding: MindHouseDesignTokens.componentPaddingMedium,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surfaceContainer,
        borderRadius: MindHouseDesignTokens.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showAvatar)
            Row(
              children: [
                _buildSkeletonBox(
                  theme,
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                ),
                SizedBox(width: MindHouseDesignTokens.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonBox(theme, width: 120, height: 16),
                      SizedBox(height: MindHouseDesignTokens.spaceXS),
                      _buildSkeletonBox(theme, width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          if (config.showTitle) ...[
            if (config.showAvatar) SizedBox(height: MindHouseDesignTokens.spaceMD),
            _buildSkeletonBox(theme, width: double.infinity, height: 20),
          ],
          if (config.showSubtitle) ...[
            SizedBox(height: MindHouseDesignTokens.spaceXS),
            _buildSkeletonBox(theme, width: 200, height: 16),
          ],
          if (config.showDescription) ...[
            SizedBox(height: MindHouseDesignTokens.spaceMD),
            ...List.generate(config.descriptionLines, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: MindHouseDesignTokens.spaceXS),
                child: _buildSkeletonBox(
                  theme,
                  width: index == config.descriptionLines - 1 ? 150 : double.infinity,
                  height: 14,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(
    ThemeData theme, {
    required double width,
    required double height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          borderRadius ?? MindHouseDesignTokens.radiusSM,
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainer,
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
              end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
            ),
            borderRadius: MindHouseDesignTokens.cardBorderRadius,
          ),
          child: widget.skeletonConfig != null
              ? _buildSkeletonLoading(theme)
              : SizedBox(
                  width: double.infinity,
                  height: 100,
                ),
        );
      },
    );
  }

  Widget _buildPulseLoading(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + 0.5 * (1 + _shimmerAnimation.value) / 2,
          child: widget.skeletonConfig != null
              ? _buildSkeletonLoading(theme)
              : Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: MindHouseDesignTokens.cardBorderRadius,
                  ),
                ),
        );
      },
    );
  }
}

/// Configuration for skeleton loading screens
class SkeletonConfig {
  const SkeletonConfig({
    this.itemCount = 3,
    this.showAvatar = true,
    this.showTitle = true,
    this.showSubtitle = false,
    this.showDescription = true,
    this.descriptionLines = 2,
  });

  final int itemCount;
  final bool showAvatar;
  final bool showTitle;
  final bool showSubtitle;
  final bool showDescription;
  final int descriptionLines;

  /// Default configuration for common layouts
  static SkeletonConfig defaultConfig() => const SkeletonConfig();

  /// Configuration for list items
  static SkeletonConfig listItem() => const SkeletonConfig(
        itemCount: 5,
        showAvatar: true,
        showTitle: true,
        showSubtitle: true,
        showDescription: false,
      );

  /// Configuration for card layouts
  static SkeletonConfig card() => const SkeletonConfig(
        itemCount: 3,
        showAvatar: false,
        showTitle: true,
        showSubtitle: false,
        showDescription: true,
        descriptionLines: 3,
      );

  /// Configuration for article content
  static SkeletonConfig article() => const SkeletonConfig(
        itemCount: 1,
        showAvatar: true,
        showTitle: true,
        showSubtitle: true,
        showDescription: true,
        descriptionLines: 5,
      );
}

/// Factory methods for common loading configurations
extension LoadingStatesFactory on LoadingStates {
  /// Create a simple circular progress indicator
  static LoadingStates circular({
    Key? key,
    String? message,
    LoadingSize size = LoadingSize.medium,
    Color? color,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.circular,
      size: size,
      message: message,
      color: color,
      isVisible: isVisible,
    );
  }

  /// Create a linear progress bar
  static LoadingStates linear({
    Key? key,
    String? message,
    double? progress,
    Color? color,
    Color? backgroundColor,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.linear,
      message: message,
      progress: progress,
      color: color,
      backgroundColor: backgroundColor,
      isVisible: isVisible,
    );
  }

  /// Create a skeleton screen for content loading
  static LoadingStates skeleton({
    Key? key,
    SkeletonConfig? config,
    Color? backgroundColor,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.skeleton,
      skeletonConfig: config ?? SkeletonConfig.defaultConfig(),
      backgroundColor: backgroundColor,
      isVisible: isVisible,
      showMessage: false,
    );
  }

  /// Create a shimmer loading effect
  static LoadingStates shimmer({
    Key? key,
    SkeletonConfig? config,
    Color? backgroundColor,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.shimmer,
      skeletonConfig: config ?? SkeletonConfig.defaultConfig(),
      backgroundColor: backgroundColor,
      isVisible: isVisible,
      showMessage: false,
    );
  }

  /// Create a pulse loading effect
  static LoadingStates pulse({
    Key? key,
    SkeletonConfig? config,
    Color? backgroundColor,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.pulse,
      skeletonConfig: config ?? SkeletonConfig.defaultConfig(),
      backgroundColor: backgroundColor,
      isVisible: isVisible,
      showMessage: false,
    );
  }

  /// Create a page loading overlay
  static LoadingStates pageOverlay({
    Key? key,
    String message = 'Loading...',
    Color? color,
    bool isVisible = true,
  }) {
    return LoadingStates(
      key: key,
      type: LoadingStateType.circular,
      size: LoadingSize.large,
      message: message,
      color: color,
      isVisible: isVisible,
    );
  }
}

/// Progressive loading widget for step-by-step loading processes
class ProgressiveLoading extends StatefulWidget {
  const ProgressiveLoading({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.isComplete = false,
    this.onStepComplete,
    this.stepDuration = const Duration(seconds: 2),
    this.showStepDetails = true,
    this.color,
    this.semanticLabel,
  });

  /// List of loading steps
  final List<String> steps;

  /// Current active step index
  final int currentStep;

  /// Whether loading is complete
  final bool isComplete;

  /// Callback when a step completes
  final ValueChanged<int>? onStepComplete;

  /// Duration for each step animation
  final Duration stepDuration;

  /// Whether to show step details
  final bool showStepDetails;

  /// Primary color
  final Color? color;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<ProgressiveLoading> createState() => _ProgressiveLoadingState();
}

class _ProgressiveLoadingState extends State<ProgressiveLoading>
    with TickerProviderStateMixin {
  late AnimationController _stepController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _stepController = AnimationController(
      duration: widget.stepDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _stepController.forward();
  }

  @override
  void didUpdateWidget(ProgressiveLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.currentStep != oldWidget.currentStep) {
      _stepController.reset();
      _stepController.forward();
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? 'Progressive loading',
      child: Container(
        padding: MindHouseDesignTokens.componentPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressBar(theme),
            if (widget.showStepDetails) ...[
              SizedBox(height: MindHouseDesignTokens.spaceLG),
              _buildStepsList(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final progress = widget.isComplete
        ? 1.0
        : (widget.currentStep + _progressAnimation.value) / widget.steps.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          color: widget.color ?? theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surfaceContainer,
        ),
        SizedBox(height: MindHouseDesignTokens.spaceMD),
        Text(
          widget.isComplete
              ? 'Complete!'
              : 'Step ${widget.currentStep + 1} of ${widget.steps.length}',
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildStepsList(ThemeData theme) {
    return Column(
      children: widget.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isComplete = index < widget.currentStep || widget.isComplete;
        final isCurrent = index == widget.currentStep && !widget.isComplete;

        return Padding(
          padding: EdgeInsets.only(bottom: MindHouseDesignTokens.spaceSM),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isComplete
                      ? (widget.color ?? theme.colorScheme.primary)
                      : isCurrent
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check : Icons.circle,
                  size: 12,
                  color: isComplete
                      ? theme.colorScheme.onPrimary
                      : isCurrent
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: MindHouseDesignTokens.spaceMD),
              Expanded(
                child: Text(
                  step,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isComplete || isCurrent
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}