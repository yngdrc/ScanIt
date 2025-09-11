import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../../core/scanner_detection_mode.dart';
import 'camera_scanner_controls.dart';
import 'camera_scanner_detection_mode_picker.dart';

class CameraScannerOverlay extends StatelessWidget {
  CameraScannerOverlay({
    super.key,
    required Rect? scanWindow,
    required this.constraints,
    required this.barcode,
    required this.detectionMode,
    required this.isFlashlightOn,
    required this.onDetectionModeSelected,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
    required this.onFilePicked,
  }) : _scanWindow = scanWindow;

  final Rect? _scanWindow;
  final BoxConstraints constraints;
  final Barcode? barcode;
  final DetectionMode detectionMode;
  final bool isFlashlightOn;
  final OnDetectionModeSelected onDetectionModeSelected;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraSwitch;
  final OnFilePicked onFilePicked;

  final ConstraintId scannerControlsId = ConstraintId('scannerControlsId');
  final ConstraintId scannerDetectionModePickerId = ConstraintId(
    'scannerDetectionModePickerId',
  );

  final ConstraintId scannerFilePickerId = ConstraintId('scannerFilePickerId');
  final ConstraintId scanRectangleId = ConstraintId('scanRectangleId');

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_scanWindow != null)
          ClipPath(
            clipper: _ScannerClipper(scanWindow: _scanWindow),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),

        if (_scanWindow != null)
          _ScanRectangleWidget(
            scanWindow: _scanWindow,
            constraints: constraints,
            barcode: barcode,
          ),
      ],
    );
  }
}

class _ScannerClipper extends CustomClipper<Path> {
  const _ScannerClipper({required this.scanWindow});

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
    required this.constraints,
    required this.barcode,
  });

  final Rect scanWindow;
  final BoxConstraints constraints;
  final Barcode? barcode;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (constraints.maxWidth - scanWindow.width) / 2,
      top: (constraints.maxHeight - scanWindow.height) / 2,
      width: scanWindow.width,
      height: scanWindow.height,
      child: Container(
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
      ),
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
