import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scanit/navigation/navigation_screen.dart';

import '../data/repositories/barcode/barcode_repository_local.dart';
import '../ui/scan_history/viewmodels/scan_history_view_model.dart';
import '../ui/scan_history/widgets/scan_history_screen.dart';
import '../ui/scanner/viewmodels/scanner_view_model.dart';
import '../ui/scanner/widgets/scanner_screen.dart';

enum NavigationKey { scanner, scan_history }

extension NavigationKeyExtension on NavigationKey {
  String get title {
    switch (this) {
      case NavigationKey.scanner:
        return "Camera";
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

  NavigationScreen get screen {
    switch (this) {
      case NavigationKey.scanner:
        return ScannerScreen(
          viewModel: ScannerViewModel(),
        );
      case NavigationKey.scan_history:
        return ScanHistoryScreen(
          viewModel: ScanHistoryViewModel(),
        );
    }
  }
}
