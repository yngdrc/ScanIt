import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:scanit/core/navigation/navigation_model.dart';

import '../../ui/scan_history/widgets/scan_history_screen.dart';
import '../../ui/scanner/widgets/scanner_screen.dart';

enum NavigationKey { scanner, scanHistory }

extension NavigationKeyExtension on NavigationKey {
  NavigationModel createNavigationModel() {
    switch (this) {
      case NavigationKey.scanner:
        return NavigationModel(
          globalKey: GlobalKey<NavigatorState>(),
          navigationKey: this,
        );
      case NavigationKey.scanHistory:
        return NavigationModel(
          globalKey: GlobalKey<NavigatorState>(),
          navigationKey: this,
        );
    }
  }

  String get title {
    switch (this) {
      case NavigationKey.scanner:
        return 'Scan';
      case NavigationKey.scanHistory:
        return 'History';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationKey.scanner:
        return Symbols.camera;
      case NavigationKey.scanHistory:
        return Symbols.history;
    }
  }
}

extension NavigationModelExtension on NavigationModel {
  Widget createPage(BuildContext context, GlobalKey bottomNavigationBarKey) {
    switch (navigationKey) {
      case NavigationKey.scanner:
        return ScannerScreen(key: globalKey);
      case NavigationKey.scanHistory:
        return ScanHistoryScreen(key: globalKey, viewModel: context.watch());
    }
  }
}
