
import 'package:flutter/material.dart' hide NavigationDestination;
import 'package:scanit/navigation/navigation_destination.dart';
import 'package:scanit/ui/colors.dart';

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
      color: ScanItColors.surface,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
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
