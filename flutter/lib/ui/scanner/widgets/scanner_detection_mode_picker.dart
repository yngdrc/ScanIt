import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'scanner/scanner_detection_mode.dart';

class ScannerDetectionModePicker extends StatelessWidget {
  const ScannerDetectionModePicker({
    super.key,
    required this.currentMode,
    required this.onDetectionModeSelected,
  });

  final DetectionMode currentMode;
  final Function({required DetectionMode detectionMode})
  onDetectionModeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: DetectionMode.values.map((detectionMode) {
        final isSelected = detectionMode == currentMode;
        return IconButton(
          icon: Icon(
            detectionMode == DetectionMode.barcode
                ? Symbols.qr_code_scanner
                : Symbols.document_scanner,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            size: isSelected ? 32 : 24,
          ),
          onPressed: () =>
              onDetectionModeSelected(detectionMode: detectionMode),
        );
      }).toList(),
    );
  }
}
