import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'mobile_scanner_detection_mode.dart';

class ScannerDetectionModePicker extends StatelessWidget {
  const ScannerDetectionModePicker({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  final DetectionMode currentMode;
  final ValueChanged<DetectionMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: DetectionMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return IconButton(
          icon: Icon(
            mode == DetectionMode.barcode
                ? Symbols.qr_code_scanner
                : Symbols.document_scanner,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            size: isSelected ? 32 : 24,
          ),
          onPressed: () => onModeSelected(mode),
        );
      }).toList(),
    );
  }
}
