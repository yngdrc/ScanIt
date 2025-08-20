import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanit/navigation/navigation_screen.dart';

import '../ui/scan_history/widgets/scan_history_screen.dart';
import '../ui/scanner/widgets/scanner_screen.dart';

enum NavigationKey { scanner, scan_history }

extension NavigationKeyExtension on NavigationKey {
  String get title {
    switch (this) {
      case NavigationKey.scanner:
        return "Scan";
      case NavigationKey.scan_history:
        return "History";
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationKey.scanner:
        return Icons.document_scanner;
      case NavigationKey.scan_history:
        return Icons.history;
    }
  }

  NavigationScreen getScreen(BuildContext context) {
    switch (this) {
      case NavigationKey.scanner:
        return ScannerScreen(
          viewModel: context.watch(),
        );
      case NavigationKey.scan_history:
        return ScanHistoryScreen(
          viewModel: context.watch(),
        );
    }
  }
}
