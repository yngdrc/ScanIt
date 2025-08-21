import 'package:flutter/cupertino.dart';
import 'package:scanit/core/navigation/navigation_key.dart';

class NavigationModel {
  const NavigationModel({
    required this.globalKey,
    required this.navigationKey,
  });

  final GlobalKey<NavigatorState> globalKey;
  final NavigationKey navigationKey;
}
