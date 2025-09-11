import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:scanit/core/utils/scanner_utils.dart';

import '../../core/processing/scanit_processor.dart';
import '../../core/scanit_controller.dart';
import '../../core/ui/scanner.dart';
import 'camera_scanner_overlay.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  final ScanItController _scanItController = ScanItController();
  CustomPaint? _customPaint;

  // TODO: limit rect position to be inside the visible preview area
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

  void _setCustomPaint({required ScanItProcessorEvent event}) {
    final painter = painterFromEvent(event: event);
    setState(() {
      if (painter == null) {
        _customPaint = null;
      } else {
        _customPaint = CustomPaint(painter: painter);
      }
    });
  }

  void _onFilePicked({required FilePickerResult result}) {
    // TODO: Implement file picking handling
  }

  @override
  Widget build(BuildContext context) {
    return Scanner(
      controller: _scanItController,
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
    required ScanItControllerState scannerState,
  }) {
    return CameraScannerOverlay(
      scanWindow: scannerState.scanWindow,
      constraints: constraints,
      barcode: null,
      detectionMode: scannerState.detectionMode,
      isFlashlightOn: scannerState.flashMode == FlashMode.torch,
      onDetectionModeSelected: _scanItController.setDetectionMode,
      onFlashlightToggle: _scanItController.toggleTorch,
      onCameraSwitch: _scanItController.switchCamera,
      onFilePicked: _onFilePicked,
    );
  }
}
