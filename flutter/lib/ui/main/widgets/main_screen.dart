import 'package:flutter/material.dart';

import '../../../navigation/navigation_key.dart';

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
    return Scaffold(body: _buildPage(_currentPage));
  }

  Widget _buildPage(NavigationKey key) {
    switch (key) {
      case NavigationKey.camera:
        return Stack(
          children: [
            _currentPage.screen,
            _ScanItAppBar(title: _currentPage.title),
            _ScanItNavigationBar(
              selectedIndex: _currentPage.index,
              onDestinationSelected: _onDestinationSelected,
            ),
          ],
        );
      case NavigationKey.history:
        return Column(
          children: [
            _ScanItAppBar(title: _currentPage.title),
            _currentPage.screen,
            _ScanItNavigationBar(
              selectedIndex: _currentPage.index,
              onDestinationSelected: _onDestinationSelected,
            ),
          ],
        );
    }
  }
}

class _ScanItAppBar extends StatelessWidget {
  const _ScanItAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.paddingOf(context).top, 0, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.black, Colors.transparent],
        ),
      ),
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ScanItNavigationBar extends StatelessWidget {
  const _ScanItNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[Colors.black, Colors.transparent],
          ),
        ),
        width: double.infinity,
        child: Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(context).removeViewPadding(removeTop: true),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                destinations: [
                  NavigationDestination(
                    icon: Icon(NavigationKey.camera.icon),
                    label: NavigationKey.camera.title,
                  ),
                  NavigationDestination(
                    icon: Icon(NavigationKey.history.icon),
                    label: NavigationKey.history.title,
                  ),
                ],
                onDestinationSelected: onDestinationSelected,
                backgroundColor: Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }
}
