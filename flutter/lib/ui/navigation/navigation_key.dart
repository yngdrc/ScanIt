import 'package:flutter/material.dart';
import 'package:scanit/ui/navigation/navigation_screen.dart';

import '../camera/widgets/camera_screen.dart';
import '../history/widgets/history_screen.dart';

enum NavigationKey { camera, history }

extension NavigationKeyExtension on NavigationKey {
  String get title {
    switch (this) {
      case NavigationKey.camera:
        return "Camera";
      case NavigationKey.history:
        return "History";
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationKey.camera:
        return Icons.document_scanner;
      case NavigationKey.history:
        return Icons.history;
    }
  }

  NavigationScreen get screen {
    switch (this) {
      case NavigationKey.camera:
        return const CameraScreen();
      case NavigationKey.history:
        return const HistoryScreen();
    }
  }
}
