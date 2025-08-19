import 'package:flutter/material.dart';

import '../../../navigation/navigation_key.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageViewController;
  NavigationKey _currentPage = NavigationKey.scanner;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = NavigationKey.values[index];
    });
  }

  void _onDestinationSelected(int index) {
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentPage.title), centerTitle: true),
      body: PageView.builder(
        controller: _pageViewController,
        itemCount: NavigationKey.values.length,
        itemBuilder: (context, index) {
          return NavigationKey.values[index].screen;
        },
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPage.index,
        destinations: [
          NavigationDestination(
            icon: Icon(NavigationKey.scanner.icon),
            label: NavigationKey.scanner.title,
          ),
          NavigationDestination(
            icon: Icon(NavigationKey.scan_history.icon),
            label: NavigationKey.scan_history.title,
          ),
        ],
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
