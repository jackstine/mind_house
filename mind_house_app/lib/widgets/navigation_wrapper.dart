import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_house_app/services/app_lifecycle_manager.dart';

class NavigationWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackgroundReturn;

  const NavigationWrapper({
    super.key,
    required this.child,
    this.onBackgroundReturn,
  });

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  late AppLifecycleManager _lifecycleManager;

  @override
  void initState() {
    super.initState();
    _lifecycleManager = AppLifecycleManager();
    _lifecycleManager.initialize();
    
    // Set up lifecycle callbacks
    _lifecycleManager.onReturnToForeground = _handleReturnToForeground;
    _lifecycleManager.onLongBackground = _handleLongBackground;
  }

  @override
  void dispose() {
    _lifecycleManager.dispose();
    super.dispose();
  }

  void _handleReturnToForeground() {
    widget.onBackgroundReturn?.call();
    
    // Show a subtle indication that the app has returned
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Welcome back to Mind House'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
  }

  void _handleLongBackground() {
    // App has been in background for 15+ minutes
    // Could trigger data refresh, security lock, etc.
    AppStatePreserver.clearAllPageStates();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Custom back button handling
        final shouldPop = await _handleBackPressed();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: widget.child,
    );
  }

  Future<bool> _handleBackPressed() async {
    // Check if we're at the root of navigation
    if (!Navigator.of(context).canPop()) {
      // Show confirmation dialog for app exit
      return await _showExitConfirmation() ?? false;
    }
    
    return true;
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Mind House'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class TabPreservingWrapper extends StatefulWidget {
  final Widget child;
  final String tabKey;

  const TabPreservingWrapper({
    super.key,
    required this.child,
    required this.tabKey,
  });

  @override
  State<TabPreservingWrapper> createState() => _TabPreservingWrapperState();
}

class _TabPreservingWrapperState extends State<TabPreservingWrapper>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void dispose() {
    // Save any important state before disposal
    AppStatePreserver.savePageState(widget.tabKey, {
      'disposed_at': DateTime.now().toIso8601String(),
    });
    super.dispose();
  }
}