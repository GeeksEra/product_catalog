import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_catalog/screens/product_list/product_list_screen.dart';
import 'package:product_catalog/screens/settings/settings_screen.dart';
import 'package:product_catalog/widgets/app_tab_bar.dart';

/// Fires when the user taps the tab they are already on, with nothing left to
/// pop. The tab's root screen scrolls back to the top.
class TabReselection extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// The app's root: a bottom tab bar over one navigator per tab.
///
/// Each tab keeps its own navigation stack and scroll position while the user
/// switches away, and the tab bar stays visible on pushed screens. Re-tapping
/// the current tab pops it to its root, then scrolls that root to the top.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<AppTab> _tabs = [
    AppTab(
      label: 'Products',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
    ),
    AppTab(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  int _index = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    for (final _ in _tabs) GlobalKey<NavigatorState>(),
  ];

  // Nested navigators don't get the app's HeroController, so each needs its
  // own for the list-to-detail Hero to fly.
  final List<HeroController> _heroControllers = [
    for (final _ in _tabs) MaterialApp.createMaterialHeroController(),
  ];
  final List<TabReselection> _reselections = [
    for (final _ in _tabs) TabReselection(),
  ];
  final List<_TopRouteObserver> _topRoutes = [
    for (final _ in _tabs) _TopRouteObserver(),
  ];

  @override
  void dispose() {
    for (final controller in _heroControllers) {
      controller.dispose();
    }
    for (final reselection in _reselections) {
      reselection.dispose();
    }
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() => _index = index);
    // The new tab decides what back does now, so tell the platform again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NavigationNotification(
        canHandlePop: _shellHandlesBack(_tabHandlesBack(_index)),
      ).dispatch(context);
    });
  }

  /// Whether the tab has something to go back to: a pushed screen, or a root
  /// screen that is blocking pops (the list while search is active).
  bool _tabHandlesBack(int index) {
    final navigator = _navigatorKeys[index].currentState;
    final top = _topRoutes[index].top;
    return (navigator?.canPop() ?? false) ||
        top?.popDisposition == RoutePopDisposition.doNotPop;
  }

  /// Off the first tab, back always stays in the app: it returns to Products.
  bool _shellHandlesBack(bool tabHandlesBack) => tabHandlesBack || _index != 0;

  /// With Android predictive back, each navigator tells the platform whether
  /// the app wants the next back gesture. A tab's navigator only knows about
  /// its own routes, so on the Settings tab it would report "no" and Android
  /// would close the app. Correct the answer here, and ignore the hidden tab.
  bool _onTabNavigation(int tab, NavigationNotification notification) {
    if (tab != _index) return true;
    final canHandlePop = _shellHandlesBack(notification.canHandlePop);
    if (canHandlePop == notification.canHandlePop) return false;
    NavigationNotification(canHandlePop: canHandlePop).dispatch(context);
    return true;
  }

  void _onTabTapped(int index) {
    if (index != _index) {
      _selectTab(index);
      return;
    }
    final navigator = _navigatorKeys[index].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      _reselections[index].fire();
    }
  }

  void _onBack(bool didPop, Object? _) {
    if (!didPop) unawaited(_handleBack());
  }

  /// Android back: let the current tab handle it (pop a screen, or cancel an
  /// active search), then return to the first tab, then leave the app.
  Future<void> _handleBack() async {
    final navigator = _navigatorKeys[_index].currentState;
    if (navigator != null && await navigator.maybePop()) return;
    if (!mounted) return;
    if (_index != 0) {
      _selectTab(0);
    } else {
      await SystemNavigator.pop();
    }
  }

  Widget _buildTab(int index) {
    final reselection = _reselections[index];
    final Widget root = switch (index) {
      0 => ProductListScreen(scrollToTop: reselection),
      _ => SettingsScreen(scrollToTop: reselection),
    };
    return TickerMode(
      // Pauses shimmer and other animations on the hidden tab.
      enabled: index == _index,
      child: NotificationListener<NavigationNotification>(
        onNotification: (notification) => _onTabNavigation(index, notification),
        child: Navigator(
          key: _navigatorKeys[index],
          observers: [_heroControllers[index], _topRoutes[index]],
          onGenerateRoute: (settings) =>
              MaterialPageRoute<void>(settings: settings, builder: (_) => root),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _index,
          children: [for (var i = 0; i < _tabs.length; i++) _buildTab(i)],
        ),
        bottomNavigationBar: AppTabBar(
          tabs: _tabs,
          currentIndex: _index,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

/// Remembers the route on top of a navigator, to read its pop disposition.
class _TopRouteObserver extends NavigatorObserver {
  Route<dynamic>? top;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      top = route;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      top = previousRoute;

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route == top) top = previousRoute;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute == top) top = newRoute;
  }
}
