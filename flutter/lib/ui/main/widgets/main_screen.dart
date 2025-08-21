import 'package:flutter/material.dart' hide NavigationBar;

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
        backgroundColor: Colors.transparent,
        title: Text(
          _currentNavigationKey.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: _currentNavigationKey == NavigationKey.scanner,
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _destinations.map((destination) {
          return destination.createPage(context, _bottomNavigationBarKey);
        }).toList(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: _currentNavigationKey == NavigationKey.scanner,
      bottomNavigationBar: NavigationBar(
        key: _bottomNavigationBarKey,
        destinations: _destinations,
        currentNavigationKey: _currentNavigationKey,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
