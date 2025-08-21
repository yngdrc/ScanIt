import 'package:flutter/material.dart' hide NavigationDestination;
import 'package:scanit/core/navigation/navigation_destination.dart';

import 'navigation_key.dart';
import 'navigation_model.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.destinations,
    required this.currentNavigationKey,
    required this.onDestinationSelected,
  });

  final List<NavigationModel> destinations;
  final NavigationKey currentNavigationKey;
  final ValueChanged<NavigationKey> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(34),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 40,
          children: destinations.map((destination) {
            final isSelected =
                destination.navigationKey == currentNavigationKey;

            return NavigationDestination(
              navigationKey: destination.navigationKey,
              isSelected: isSelected,
              onTap: onDestinationSelected,
            );
          }).toList(),
        ),
      ),
    );
  }
}
