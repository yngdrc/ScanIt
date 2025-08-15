import 'package:flutter/material.dart';
import 'package:scanit/ui/navigation/navigation_screen.dart';

import '../camera/widgets/camera_screen.dart';

enum NavigationKey {
  camera
}

extension NavigationKeyExtension on NavigationKey {
  String get title {
    switch (this) {
      case NavigationKey.camera:
        return "Camera";
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationKey.camera:
        return Icons.document_scanner;
    }
  }

  NavigationScreen get screen {
    switch (this) {
      case NavigationKey.camera:
        return CameraScreen();
    }
  }
}