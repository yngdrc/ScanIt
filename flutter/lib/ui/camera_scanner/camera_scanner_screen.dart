import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import '../../core/processing/scanit_processor.dart';
import '../../core/scanit_controller.dart';
import '../../core/ui/scanit_widget.dart';
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
  ScanAreaInitializer get _scanAreaInitializer =>
      ({required Rect bounds}) {
        final scanAreaSize = bounds.shortestSide / 2;
        return Rect.fromLTWH(100, 100, scanAreaSize, scanAreaSize);
        // return Rect.fromCenter(
        //   center: bounds.center,
        //   width: scanAreaSize,
        //   height: scanAreaSize,
        // );
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
    return ScanItWidget(
      controller: _scanItController,
      scanAreaInitializer: _scanAreaInitializer,
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
      scanArea: scannerState.scanArea,
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
