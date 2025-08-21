import 'package:flutter/material.dart' hide NavigationBar, AppBar;
import 'package:scanit/ui/colors.dart';

import '../../../core/appbar/app_bar.dart';
import '../../../core/navigation/navigation_bar.dart';
import '../../../core/navigation/navigation_key.dart';
import '../../../core/navigation/navigation_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _bottomNavigationBarKey = GlobalKey();

  final PageController _pageController = PageController();
  final List<NavigationModel> _destinations = [
    NavigationKey.scanner,
    NavigationKey.scanHistory,
  ].map((navigationKey) => navigationKey.createNavigationModel()).toList();

  NavigationKey _currentNavigationKey = NavigationKey.scanner;

  bool get extendBody => _currentNavigationKey == NavigationKey.scanner;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentNavigationKey = _destinations[index].navigationKey;
    });
  }

  void _onDestinationSelected(NavigationKey navigationKey) {
    _pageController.jumpToPage(
      _destinations.indexWhere((destination) {
        return destination.navigationKey == navigationKey;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentNavigationKey.title,
        backgroundColor: _currentNavigationKey == NavigationKey.scanner
            ? Colors.transparent
            : ScanItColors.surface,
        textColor: _currentNavigationKey == NavigationKey.scanner
            ? Colors.white
            : Colors.black,
        fontSize: _currentNavigationKey == NavigationKey.scanner
            ? 20
            : 48,
        fontWeight: _currentNavigationKey == NavigationKey.scanner
            ? FontWeight.w500
            : FontWeight.w500,
        titleAlignment: _currentNavigationKey == NavigationKey.scanner
            ? Alignment.center
            : Alignment.centerLeft
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _destinations.map((destination) {
          return destination.createPage(context, _bottomNavigationBarKey);
        }).toList(),
      ),
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBody,
      bottomNavigationBar: NavigationBar(
        key: _bottomNavigationBarKey,
        destinations: _destinations,
        currentNavigationKey: _currentNavigationKey,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
