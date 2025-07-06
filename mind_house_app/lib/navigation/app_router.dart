import 'package:flutter/material.dart';
import 'package:mind_house_app/pages/main_navigation_page.dart';
import 'package:mind_house_app/pages/information_page.dart';
import 'package:mind_house_app/pages/store_information_page_enhanced.dart';
import 'package:mind_house_app/pages/list_information_page.dart';

class AppRouter {
  static const String home = '/';
  static const String store = '/store';
  static const String browse = '/browse';
  static const String view = '/view';
  static const String informationDetail = '/information';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationPage(),
          settings: settings,
        );
      
      case store:
        return MaterialPageRoute(
          builder: (_) => const EnhancedStoreInformationPage(),
          settings: settings,
        );
      
      case browse:
        return MaterialPageRoute(
          builder: (_) => const ListInformationPage(),
          settings: settings,
        );
      
      case view:
        return MaterialPageRoute(
          builder: (_) => const InformationPage(),
          settings: settings,
        );
      
      case informationDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final informationId = args?['informationId'] as String?;
        return MaterialPageRoute(
          builder: (_) => InformationPage(informationId: informationId),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationPage(),
          settings: settings,
        );
    }
  }
}

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static void navigateToInformation(String informationId) {
    navigator?.pushNamed(
      AppRouter.informationDetail,
      arguments: {'informationId': informationId},
    );
  }
  
  static void navigateToStore() {
    navigator?.pushNamed(AppRouter.store);
  }
  
  static void navigateToBrowse() {
    navigator?.pushNamed(AppRouter.browse);
  }
  
  static void navigateToView() {
    navigator?.pushNamed(AppRouter.view);
  }
  
  static void pop() {
    navigator?.pop();
  }
  
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }
}