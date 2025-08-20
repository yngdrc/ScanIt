import 'package:flutter/material.dart' hide NavigationBar;
import 'package:scanit/navigation/navigation_model.dart';

import '../../../navigation/navigation_key.dart';
import '../../../navigation/navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  final List<NavigationModel> _destinations = [
    NavigationKey.scanner,
    NavigationKey.scanHistory,
  ].map((navigationKey) => navigationKey.createNavigationModel()).toList();

  NavigationKey _currentNavigationKey = NavigationKey.scanner;

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
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _destinations.map((destination) {
          return destination.createPage(context);
        }).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        currentNavigationKey: _currentNavigationKey,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
