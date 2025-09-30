import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/core/scanit_controller_state.dart';
import 'package:scanit/ui/camera_scanner/camera_scanner_overlay_clipper.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../../core/detection_mode.dart';
import 'camera_scanner_controls.dart';
import 'camera_scanner_detection_mode_picker.dart';

class ScanItCameraOverlay extends StatelessWidget {
  const ScanItCameraOverlay({super.key, required this.scanArea});

  final Rect scanArea;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: CameraScannerOverlayClipper(scanArea: scanArea),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        _ScanRectangleWidget(scanArea: scanArea),
      ],
    );
  }
}

class _ScanRectangleWidget extends StatelessWidget {
  const _ScanRectangleWidget({required this.scanArea});

  final Rect scanArea;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: scanArea.left,
      top: scanArea.top,
      width: scanArea.width,
      height: scanArea.height,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scanArea.width / 42,
          vertical: scanArea.height / 42,
        ),
        width: scanArea.width,
        height: scanArea.height,
        decoration: BoxDecoration(
          border: DashedBorder.all(
            color: Colors.white,
            dashLength: scanArea.shortestSide / 4,
            width: 3,
            isOnlyCorner: true,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
