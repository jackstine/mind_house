// Enhanced Navigation Shell Component
// Material Design 3 compliant navigation with improved tab management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

/// Navigation destination definition
class NavigationDestination {
  const NavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget icon;
  final String label;
  final Widget? selectedIcon;
  final Widget? badge;
  final String? tooltip;
  final String? semanticLabel;
  final bool enabled;
}

/// Navigation shell type
enum NavigationShellType {
  /// Bottom navigation bar for mobile
  bottomNavigation,

  /// Navigation rail for tablets
  navigationRail,

  /// Navigation drawer for large screens
  navigationDrawer,

  /// Adaptive navigation that changes based on screen size
  adaptive,
}

/// Navigation bar position
enum NavigationPosition {
  bottom,
  top,
  leading,
  trailing,
}

/// Enhanced navigation shell with comprehensive features
/// Supports adaptive navigation, tab management, and customizable appearance
class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.destinations,
    required this.children,
    this.currentIndex = 0,
    this.onDestinationSelected,
    this.type = NavigationShellType.adaptive,
    this.position = NavigationPosition.bottom,
    this.enableSwipeNavigation = true,
    this.enableKeyboardNavigation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.pageController,
    this.physics,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.indicatorColor,
    this.indicatorShape,
    this.labelBehavior,
    this.enableFab = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset,
    this.semanticLabel,
  });

  /// List of navigation destinations
  final List<NavigationDestination> destinations;

  /// List of page widgets corresponding to destinations
  final List<Widget> children;

  /// Currently selected destination index
  final int currentIndex;

  /// Callback when destination is selected
  final ValueChanged<int>? onDestinationSelected;

  /// Navigation shell type
  final NavigationShellType type;

  /// Navigation position
  final NavigationPosition position;

  /// Whether to enable swipe navigation between pages
  final bool enableSwipeNavigation;

  /// Whether to enable keyboard navigation
  final bool enableKeyboardNavigation;

  /// Animation duration for page transitions
  final Duration animationDuration;

  /// Page controller for managing page views
  final PageController? pageController;

  /// Scroll physics for page view
  final ScrollPhysics? physics;

  /// Background color for navigation
  final Color? backgroundColor;

  /// Color for selected items
  final Color? selectedItemColor;

  /// Color for unselected items
  final Color? unselectedItemColor;

  /// Navigation elevation
  final double? elevation;

  /// Selection indicator color
  final Color? indicatorColor;

  /// Selection indicator shape
  final ShapeBorder? indicatorShape;

  /// Label behavior for navigation items
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Whether to enable floating action button
  final bool enableFab;

  /// Floating action button widget
  final Widget? floatingActionButton;

  /// FAB location
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// App bar widget
  final PreferredSizeWidget? appBar;

  /// Navigation drawer
  final Widget? drawer;

  /// End drawer
  final Widget? endDrawer;

  /// Persistent footer buttons
  final List<Widget>? persistentFooterButtons;

  /// Whether to resize when keyboard appears
  final bool? resizeToAvoidBottomInset;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = widget.pageController ??
        PageController(initialPage: widget.currentIndex);

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(NavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _navigateToIndex(widget.currentIndex, animate: true);
    }
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  NavigationShellType _getEffectiveType(BuildContext context) {
    if (widget.type != NavigationShellType.adaptive) return widget.type;

    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) return NavigationShellType.bottomNavigation;
    if (screenWidth < 1024) return NavigationShellType.navigationRail;
    return NavigationShellType.navigationDrawer;
  }

  Future<void> _navigateToIndex(int index, {bool animate = true}) async {
    if (index < 0 || index >= widget.destinations.length || _isAnimating) return;
    
    if (!widget.destinations[index].enabled) return;

    setState(() {
      _isAnimating = true;
    });

    if (animate) {
      await _pageController.animateToPage(
        index,
        duration: widget.animationDuration,
        curve: MindHouseDesignTokens.easeStandard,
      );
    } else {
      _pageController.jumpToPage(index);
    }

    setState(() {
      _currentIndex = index;
      _isAnimating = false;
    });

    widget.onDestinationSelected?.call(index);
    
    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  void _handleKeyPress(KeyEvent event) {
    if (!widget.enableKeyboardNavigation || event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft && _currentIndex > 0) {
      _navigateToIndex(_currentIndex - 1);
    } else if (key == LogicalKeyboardKey.arrowRight &&
        _currentIndex < widget.destinations.length - 1) {
      _navigateToIndex(_currentIndex + 1);
    } else if (key >= LogicalKeyboardKey.digit1 &&
        key <= LogicalKeyboardKey.digit9) {
      final index = int.parse(key.keyLabel) - 1;
      if (index < widget.destinations.length) {
        _navigateToIndex(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveType = _getEffectiveType(context);
    
    return Semantics(
      label: widget.semanticLabel ?? 'Navigation shell',
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyPress,
        child: _buildShellForType(context, effectiveType),
      ),
    );
  }

  Widget _buildShellForType(BuildContext context, NavigationShellType type) {
    switch (type) {
      case NavigationShellType.bottomNavigation:
        return _buildBottomNavigationShell(context);
      case NavigationShellType.navigationRail:
        return _buildNavigationRailShell(context);
      case NavigationShellType.navigationDrawer:
        return _buildNavigationDrawerShell(context);
      case NavigationShellType.adaptive:
        // This shouldn't happen as _getEffectiveType handles adaptive
        return _buildBottomNavigationShell(context);
    }
  }

  Widget _buildBottomNavigationShell(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: widget.appBar,
      body: _buildPageView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        backgroundColor: widget.backgroundColor,
        elevation: widget.elevation,
        indicatorColor: widget.indicatorColor,
        indicatorShape: widget.indicatorShape,
        labelBehavior: widget.labelBehavior,
        destinations: widget.destinations.map((dest) {
          return NavigationDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: dest.label,
            tooltip: dest.tooltip,
            enabled: dest.enabled,
          );
        }).toList(),
      ),
      floatingActionButton: widget.enableFab ? widget.floatingActionButton : null,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      persistentFooterButtons: widget.persistentFooterButtons,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );
  }

  Widget _buildNavigationRailShell(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _navigateToIndex,
            backgroundColor: widget.backgroundColor,
            elevation: widget.elevation,
            indicatorColor: widget.indicatorColor,
            indicatorShape: widget.indicatorShape,
            labelType: NavigationRailLabelType.selected,
            destinations: widget.destinations.map((dest) {
              return NavigationRailDestination(
                icon: dest.badge != null
                    ? Badge(child: dest.icon)
                    : dest.icon,
                selectedIcon: dest.selectedIcon,
                label: Text(dest.label),
                disabled: !dest.enabled,
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildPageView()),
        ],
      ),
      floatingActionButton: widget.enableFab ? widget.floatingActionButton : null,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
    );
  }

  Widget _buildNavigationDrawerShell(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: _buildPageView(),
      drawer: widget.drawer ?? _buildNavigationDrawer(context),
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.enableFab ? widget.floatingActionButton : null,
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final theme = Theme.of(context);
    
    return NavigationDrawer(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        _navigateToIndex(index);
        Navigator.of(context).pop(); // Close drawer
      },
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation,
      indicatorColor: widget.indicatorColor,
      indicatorShape: widget.indicatorShape,
      children: [
        const SizedBox(height: 16),
        ...widget.destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final dest = entry.value;
          
          return NavigationDrawerDestination(
            icon: dest.badge != null
                ? Badge(child: dest.icon)
                : dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
            enabled: dest.enabled,
          );
        }),
      ],
    );
  }

  Widget _buildPageView() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return PageView(
          controller: _pageController,
          physics: widget.enableSwipeNavigation
              ? (widget.physics ?? const ClampingScrollPhysics())
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (!_isAnimating) {
              setState(() {
                _currentIndex = index;
              });
              widget.onDestinationSelected?.call(index);
            }
          },
          children: widget.children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            return FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Specialized navigation shell for tab-based interfaces
class TabbedNavigationShell extends StatefulWidget {
  const TabbedNavigationShell({
    super.key,
    required this.tabs,
    required this.children,
    this.currentIndex = 0,
    this.onTabSelected,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 2.0,
    this.labelPadding,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.physics,
    this.semanticLabel,
  });

  /// List of tab definitions
  final List<Tab> tabs;

  /// List of tab content widgets
  final List<Widget> children;

  /// Currently selected tab index
  final int currentIndex;

  /// Callback when tab is selected
  final ValueChanged<int>? onTabSelected;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Tab indicator color
  final Color? indicatorColor;

  /// Selected tab label color
  final Color? labelColor;

  /// Unselected tab label color
  final Color? unselectedLabelColor;

  /// Indicator weight (thickness)
  final double indicatorWeight;

  /// Padding for tab labels
  final EdgeInsets? labelPadding;

  /// Whether to enable page transition animations
  final bool enableAnimation;

  /// Animation duration
  final Duration animationDuration;

  /// Scroll physics for tab view
  final ScrollPhysics? physics;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<TabbedNavigationShell> createState() => _TabbedNavigationShellState();
}

class _TabbedNavigationShellState extends State<TabbedNavigationShell>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.currentIndex,
      animationDuration: widget.enableAnimation
          ? widget.animationDuration
          : Duration.zero,
      vsync: this,
    );

    _tabController.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(TabbedNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.tabs.length,
        initialIndex: widget.currentIndex.clamp(0, widget.tabs.length - 1),
        animationDuration: widget.enableAnimation
            ? widget.animationDuration
            : Duration.zero,
        vsync: this,
      );
      _tabController.addListener(_handleTabSelection);
    } else if (widget.currentIndex != oldWidget.currentIndex) {
      _tabController.animateTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      widget.onTabSelected?.call(_tabController.index);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? 'Tabbed navigation',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: widget.tabs,
            isScrollable: widget.isScrollable,
            indicatorColor: widget.indicatorColor,
            labelColor: widget.labelColor,
            unselectedLabelColor: widget.unselectedLabelColor,
            indicatorWeight: widget.indicatorWeight,
            labelPadding: widget.labelPadding,
            physics: widget.physics,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: widget.physics,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation shell with persistent header and footer
class PersistentNavigationShell extends StatelessWidget {
  const PersistentNavigationShell({
    super.key,
    this.header,
    this.footer,
    required this.body,
    this.headerHeight,
    this.footerHeight,
    this.backgroundColor,
    this.enableSafeArea = true,
    this.semanticLabel,
  });

  /// Persistent header widget
  final Widget? header;

  /// Persistent footer widget
  final Widget? footer;

  /// Main body content
  final Widget body;

  /// Fixed header height
  final double? headerHeight;

  /// Fixed footer height
  final double? footerHeight;

  /// Background color
  final Color? backgroundColor;

  /// Whether to respect safe area
  final bool enableSafeArea;

  /// Accessibility label
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        if (header != null)
          Container(
            height: headerHeight,
            width: double.infinity,
            child: header,
          ),
        Expanded(child: body),
        if (footer != null)
          Container(
            height: footerHeight,
            width: double.infinity,
            child: footer,
          ),
      ],
    );

    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: content,
      );
    }

    if (enableSafeArea) {
      content = SafeArea(child: content);
    }

    if (semanticLabel != null) {
      content = Semantics(
        label: semanticLabel,
        child: content,
      );
    }

    return content;
  }
}

/// Factory methods for common navigation shell configurations
extension NavigationShellFactory on NavigationShell {
  /// Create a mobile-optimized navigation shell
  static NavigationShell mobile({
    Key? key,
    required List<NavigationDestination> destinations,
    required List<Widget> children,
    int currentIndex = 0,
    ValueChanged<int>? onDestinationSelected,
    bool enableSwipeNavigation = true,
  }) {
    return NavigationShell(
      key: key,
      destinations: destinations,
      children: children,
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      type: NavigationShellType.bottomNavigation,
      enableSwipeNavigation: enableSwipeNavigation,
    );
  }

  /// Create a tablet-optimized navigation shell
  static NavigationShell tablet({
    Key? key,
    required List<NavigationDestination> destinations,
    required List<Widget> children,
    int currentIndex = 0,
    ValueChanged<int>? onDestinationSelected,
    bool enableSwipeNavigation = true,
  }) {
    return NavigationShell(
      key: key,
      destinations: destinations,
      children: children,
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      type: NavigationShellType.navigationRail,
      enableSwipeNavigation: enableSwipeNavigation,
    );
  }

  /// Create a desktop-optimized navigation shell
  static NavigationShell desktop({
    Key? key,
    required List<NavigationDestination> destinations,
    required List<Widget> children,
    int currentIndex = 0,
    ValueChanged<int>? onDestinationSelected,
    Widget? drawer,
  }) {
    return NavigationShell(
      key: key,
      destinations: destinations,
      children: children,
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      type: NavigationShellType.navigationDrawer,
      drawer: drawer,
      enableSwipeNavigation: false,
    );
  }

  /// Create an adaptive navigation shell that responds to screen size
  static NavigationShell adaptive({
    Key? key,
    required List<NavigationDestination> destinations,
    required List<Widget> children,
    int currentIndex = 0,
    ValueChanged<int>? onDestinationSelected,
    bool enableSwipeNavigation = true,
  }) {
    return NavigationShell(
      key: key,
      destinations: destinations,
      children: children,
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      type: NavigationShellType.adaptive,
      enableSwipeNavigation: enableSwipeNavigation,
    );
  }
}