import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/ui/scanner/widgets/scanner_controls.dart';
import 'package:scanit/ui/scanner/widgets/scanner_detection_mode_picker.dart';
import 'package:scanit/utils/barcode_utils.dart';

import 'scanner/scanner_detection_mode.dart';

class ScannerOverlay extends StatelessWidget {
  ScannerOverlay({
    super.key,
    required Rect? scanWindow,
    required this.barcode,
    required this.detectionMode,
    required this.isFlashlightOn,
    required this.onDetectionModeSelected,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
  }) : _scanWindow = scanWindow;

  final Rect? _scanWindow;
  final Barcode? barcode;
  final DetectionMode detectionMode;
  final bool isFlashlightOn;
  final Function({required DetectionMode detectionMode})
  onDetectionModeSelected;
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
        if (_scanWindow != null)
          ClipPath(
            clipper: _MobileScannerClipper(scanWindow: _scanWindow),
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
              onDetectionModeSelected: onDetectionModeSelected,
            ).applyConstraintId(id: scannerDetectionModePickerId),

            if (_scanWindow != null)
              _ScanRectangleWidget(
                scanWindow: _scanWindow,
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

class _ScanRectangleWidget extends StatelessWidget {
  const _ScanRectangleWidget({
    required this.scanWindow,
    required this.barcode,
  });

  final Rect scanWindow;
  final Barcode? barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scanWindow.width / 42,
        vertical: scanWindow.height / 42,
      ),
      width: scanWindow.width,
      height: scanWindow.height,
      decoration: BoxDecoration(
        border: DashedBorder.all(
          color: Colors.white,
          dashLength: scanWindow.shortestSide / 4,
          width: 3,
          isOnlyCorner: true,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: _createBarcodeWidget(context, barcode),
    );
  }

  Widget? _createBarcodeWidget(BuildContext context, Barcode? barcode) {
    final barcodeData = barcode?.rawValue;
    final barcodeType = barcode?.barcodeWidgetType;
    if (barcodeData == null || barcodeType == null) {
      return null;
    }

    return Hero(
      tag: 'barcode_hero',
      child: barcode_widget.BarcodeWidget(
        data: barcodeData,
        barcode: barcode_widget.Barcode.fromType(barcodeType),
        padding: EdgeInsets.all(10),
        backgroundColor: Colors.white,
        color: Colors.black,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
