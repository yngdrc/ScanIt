import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scanit/core/navigation/navigation_key.dart';

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
    return GestureDetector(
      onTap: () => onTap(navigationKey),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            color: isSelected ? Colors.black : Colors.transparent,
            child: Icon(navigationKey.icon, size: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
