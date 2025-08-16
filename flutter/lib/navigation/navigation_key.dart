import 'package:flutter/material.dart';
import 'package:scanit/navigation/navigation_screen.dart';

import '../ui/camera/view_model/CameraViewModel.dart';
import '../ui/camera/widgets/camera_screen.dart';
import '../ui/history/widgets/history_screen.dart';

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
        return CameraScreen(viewModel: CameraViewModel(),);
      case NavigationKey.history:
        return const HistoryScreen();
    }
  }
}
