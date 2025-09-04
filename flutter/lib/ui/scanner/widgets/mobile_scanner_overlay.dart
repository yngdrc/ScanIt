import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/ui/scanner/widgets/scanner_controls.dart';
import 'package:scanit/ui/scanner/widgets/scanner_detection_mode_picker.dart';
import 'package:scanit/ui/scanner/widgets/scanner_rectangle_widget.dart';

import 'mobile_scanner_detection_mode.dart';

class MobileScannerOverlay extends StatelessWidget {
  MobileScannerOverlay({
    super.key,
    required this.scanWindow,
    required this.barcode,
    required this.detectionMode,
    required this.onModeSelected,
    required this.isFlashlightOn,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
  });

  final Rect scanWindow;
  final Barcode? barcode;
  final DetectionMode detectionMode;
  final ValueChanged<DetectionMode> onModeSelected;
  final bool isFlashlightOn;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraSwitch;

  final ConstraintId scannerControlsId = ConstraintId('scannerControlsId');
  final ConstraintId scannerDetectionModePickerId = ConstraintId(
    'scannerDetectionModePickerId',
  );

  final ConstraintId scanRectangleId = ConstraintId('scanRectangleId');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _MobileScannerClipper(scanWindow: scanWindow),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        ConstraintLayout(
          childConstraints: [
            Constraint(
              id: scannerControlsId,
              left: parent.left,
              top: parent.top,
              right: parent.right,
              bottom: scanRectangleId.top,
              verticalBias: 0,
            ),
            Constraint(
              id: scannerDetectionModePickerId,
              left: scanRectangleId.right,
              top: scanRectangleId.top,
              right: parent.right,
              bottom: scanRectangleId.bottom,
            ),
            Constraint(
              id: scanRectangleId,
              left: parent.left,
              top: parent.top,
              right: parent.right,
              bottom: parent.bottom,
            ),
          ],
          children: [
            SafeArea(
              left: false,
              right: false,
              bottom: false,
              child: ScannerControls(
                isFlashlightOn: isFlashlightOn,
                onFlashlightToggle: onFlashlightToggle,
                onCameraSwitch: onCameraSwitch,
              ),
            ).applyConstraintId(id: scannerControlsId),
            ScannerDetectionModePicker(
              currentMode: detectionMode,
              onModeSelected: onModeSelected,
            ).applyConstraintId(id: scannerDetectionModePickerId),
            ScanRectangleWidget(
              scanWindow: scanWindow,
              barcode: barcode,
            ).applyConstraintId(id: scanRectangleId),
          ],
        ),
      ],
    );
  }
}

class _MobileScannerClipper extends CustomClipper<Path> {
  const _MobileScannerClipper({required this.scanWindow});

  final Rect scanWindow;

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;

    final centerRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scanWindow.width * 2 / 2.1,
      height: scanWindow.height * 2 / 2.1,
    );

    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTWH(0, 0, width, height))
        ..close(),
      Path()
        ..addRRect(RRect.fromRectAndRadius(centerRect, Radius.circular(2)))
        ..close(),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
