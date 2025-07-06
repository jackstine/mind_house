import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  Timer? _backgroundTimer;
  DateTime? _backgroundTime;
  final Duration _backgroundThreshold = const Duration(minutes: 15);
  
  // Callbacks
  VoidCallback? onReturnToForeground;
  VoidCallback? onEnterBackground;
  VoidCallback? onLongBackground; // Called after 15 minutes in background

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppBackground();
        break;
      
      case AppLifecycleState.resumed:
        _handleAppForeground();
        break;
      
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }

  void _handleAppBackground() {
    if (kDebugMode) {
      print('App went to background');
    }
    
    _backgroundTime = DateTime.now();
    onEnterBackground?.call();
    
    // Start timer for long background detection
    _backgroundTimer = Timer(_backgroundThreshold, () {
      if (kDebugMode) {
        print('App has been in background for ${_backgroundThreshold.inMinutes} minutes');
      }
      onLongBackground?.call();
    });
  }

  void _handleAppForeground() {
    if (kDebugMode) {
      print('App returned to foreground');
    }
    
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    if (_backgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundTime!);
      if (kDebugMode) {
        print('App was in background for ${backgroundDuration.inMinutes} minutes');
      }
      
      // Check if app was in background for more than threshold
      if (backgroundDuration >= _backgroundThreshold) {
        onLongBackground?.call();
      }
    }
    
    onReturnToForeground?.call();
    _backgroundTime = null;
  }

  void _handleAppDetached() {
    if (kDebugMode) {
      print('App detached');
    }
    
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  Duration? get backgroundDuration {
    if (_backgroundTime == null) return null;
    return DateTime.now().difference(_backgroundTime!);
  }

  bool get isInBackground => _backgroundTime != null;
}

class AppStatePreserver {
  static const String _storageKey = 'app_state';
  
  // Page state preservation
  static final Map<String, dynamic> _pageStates = {};
  
  static void savePageState(String pageKey, Map<String, dynamic> state) {
    _pageStates[pageKey] = state;
  }
  
  static Map<String, dynamic>? getPageState(String pageKey) {
    return _pageStates[pageKey];
  }
  
  static void clearPageState(String pageKey) {
    _pageStates.remove(pageKey);
  }
  
  static void clearAllPageStates() {
    _pageStates.clear();
  }
  
  // Navigation state preservation
  static String? _lastRoute;
  static Map<String, dynamic>? _lastRouteArguments;
  
  static void saveNavigationState(String route, [Map<String, dynamic>? arguments]) {
    _lastRoute = route;
    _lastRouteArguments = arguments;
  }
  
  static String? get lastRoute => _lastRoute;
  static Map<String, dynamic>? get lastRouteArguments => _lastRouteArguments;
  
  static void clearNavigationState() {
    _lastRoute = null;
    _lastRouteArguments = null;
  }
}