import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:scanit/ui/navigation/navigation_key.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationKey _currentPage = NavigationKey.camera;

  void _onDestinationSelected(int index) {
    setState(() {
      _currentPage = NavigationKey.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentPage.screen,
          Container(
            alignment: Alignment.bottomCenter,
            child: NavigationBar(
              selectedIndex: _currentPage.index,
              destinations: [
                NavigationDestination(
                  icon: Icon(NavigationKey.camera.icon),
                  label: NavigationKey.camera.title,
                ),
                Nil()
              ],
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
