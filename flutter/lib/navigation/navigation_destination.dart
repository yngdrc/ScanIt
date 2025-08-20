import 'package:flutter/material.dart';
import 'package:scanit/navigation/navigation_key.dart';

class NavigationDestination extends StatelessWidget {
  const NavigationDestination({
    super.key,
    required this.navigationKey,
    required this.isSelected,
    required this.onTap,
  });

  final NavigationKey navigationKey;
  final bool isSelected;
  final ValueChanged<NavigationKey> onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(16),
      splashColor: Colors.white,
      icon: Icon(navigationKey.icon, weight: 300,),
      selectedIcon: Icon(navigationKey.icon, weight: 300,),
      isSelected: isSelected,
      iconSize: 24,
      color: isSelected ? Colors.white : Colors.white30,
      onPressed: () => onTap(navigationKey),
    );
  }
}
