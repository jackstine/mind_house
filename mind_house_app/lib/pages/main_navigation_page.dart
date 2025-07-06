import 'package:flutter/material.dart';
import 'package:mind_house_app/pages/store_information_page_enhanced.dart';
import 'package:mind_house_app/pages/information_page.dart';
import 'package:mind_house_app/pages/list_information_page.dart';
import 'package:mind_house_app/widgets/navigation_wrapper.dart';
import 'package:mind_house_app/services/app_lifecycle_manager.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Wrap pages with state preservation
  late final List<Widget> _pages = [
    const TabPreservingWrapper(
      tabKey: 'store_tab',
      child: EnhancedStoreInformationPage(),
    ),
    const TabPreservingWrapper(
      tabKey: 'browse_tab',
      child: ListInformationPage(),
    ),
    const TabPreservingWrapper(
      tabKey: 'view_tab',
      child: InformationPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Restore last tab index if available
    final savedState = AppStatePreserver.getPageState('main_navigation');
    if (savedState != null && savedState['tab_index'] != null) {
      _tabController.index = savedState['tab_index'] as int;
    }
    
    // Listen to tab changes to save state
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Save current tab index
    AppStatePreserver.savePageState('main_navigation', {
      'tab_index': _tabController.index,
      'last_changed': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: _pages,
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return NavigationBar(
              selectedIndex: _tabController.index,
              onDestinationSelected: (index) {
                _tabController.animateTo(index);
              },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_outlined),
              selectedIcon: Icon(Icons.list),
              label: 'Browse',
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: 'View',
            ),
          ],
            );
          },
        ),
      ),
    );
  }
}