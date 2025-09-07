
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scanit/ui/scanner/processing/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner_controller.dart';
import 'package:scanit/ui/scanner/widgets/scanner_utils.dart';

import 'scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ScannerController _scannerController = ScannerController();
  CustomPaint? _customPaint;

  ScanWindowInitializer get _scanWindowInitializer =>
      ({required BoxConstraints constraints, required Size previewSize}) {
        final size = constraints.biggest;
        final scanWindowSize = size.shortestSide / 2;
        return Rect.fromCenter(
          center: previewSize.center(Offset.zero),
          width: scanWindowSize,
          height: scanWindowSize,
        );
      };

  void _setCustomPaint({required CameraProcessorEvent event}) {
    final painter = ScannerUtils.painterFromEvent(event: event);
    setState(() {
      if (painter == null) {
        _customPaint = null;
      } else {
        _customPaint = CustomPaint(painter: painter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scanner(
      controller: _scannerController,
      scanWindowInitializer: _scanWindowInitializer,
      overlayBuilder: _buildOverlay,
      onBarcodesDetected: _setCustomPaint,
      onTextDetected: _setCustomPaint,
      child: _customPaint,
    );
  }

  Widget? _buildOverlay({
    required BuildContext context,
    required BoxConstraints constraints,
    required ScannerControllerState scannerState,
  }) {
    return ScannerOverlay(
      scanWindow: scannerState.scanWindow,
      barcode: null,
      detectionMode: scannerState.detectionMode,
      isFlashlightOn: scannerState.flashMode == FlashMode.torch,
      onDetectionModeSelected: _scannerController.setDetectionMode,
      onFlashlightToggle: _scannerController.toggleTorch,
      onCameraSwitch: _scannerController.switchCamera,
    );
  }
}
