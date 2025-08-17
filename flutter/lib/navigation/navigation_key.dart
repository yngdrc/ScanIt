import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scanit/navigation/navigation_screen.dart';

import '../ui/camera/viewmodels/camera_view_model.dart';
import '../ui/camera/widgets/camera_screen.dart';
import '../ui/history/viewmodels/history_view_model.dart';
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
        return CameraScreen(
          viewModel: CameraViewModel(historyRepository: GetIt.instance.get()),
        );
      case NavigationKey.history:
        return HistoryScreen(
          viewModel: HistoryViewModel(historyRepository: GetIt.instance.get()),
        );
    }
  }
}
