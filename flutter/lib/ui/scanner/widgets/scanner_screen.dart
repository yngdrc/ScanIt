import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:nil/nil.dart';
import 'package:scanit/plugins/converter_plugin.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner_controller.dart';

import '../painters/barcode_detector_painter.dart';
import '../painters/text_detector_painter.dart';
import 'mobile_scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerController _scannerController = ScannerController();
  CustomPaint? _customPaint;

  void _onBarcodesDetected(
    List<Barcode> barcodes,
    InputImage inputImage,
    CameraLensDirection lensDirection,
  ) async {
    final barcode = barcodes.firstOrNull;
    final size = inputImage.metadata?.size;
    final rotation = inputImage.metadata?.rotation;

    if (barcode == null ||
        size == null ||
        rotation == null ||
        inputImage.bytes == null) {
      setState(() {
        _customPaint = null;
      });

      return;
    }

    final painter = BarcodeDetectorPainter(
      [barcode],
      size,
      rotation,
      lensDirection,
    );

    setState(() {
      _customPaint = CustomPaint(painter: painter);
    });
  }

  void _onTextDetected(
    RecognizedText recognizedText,
    InputImage inputImage,
    CameraLensDirection lensDirection,
  ) {
    final size = inputImage.metadata?.size;
    final rotation = inputImage.metadata?.rotation;

    if (size == null || rotation == null) {
      setState(() {
        _customPaint = null;
      });

      return;
    }

    CustomPainter painter = TextRecognizerPainter(
      recognizedText,
      size,
      rotation,
      lensDirection,
    );

    setState(() {
      _customPaint = CustomPaint(painter: painter);
    });
  }

  // preview size 1280x720
  // box constraints 485.4x1078.7
  Rect _getScanWindow(BoxConstraints constraints, ui.Size previewSize) {
    ui.Size size;
    // if (constraints.biggest.shortestSide < previewSize.shortestSide) {
    //   size = constraints.biggest;
    // } else {
    size = previewSize;
    // }

    // final scanWindowSize = constraints.biggest.shortestSide / 2;
    // final center = constraints.biggest.center(Offset.zero);
    final scanWindowSize = size.shortestSide / 2;
    return Rect.fromCenter(
      // center: Offset(center.dy, center.dx),
      center: size.center(Offset.zero),
      width: scanWindowSize,
      height: scanWindowSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scanner(
      controller: _scannerController,
      scanWindowInitializer: (constraints, previewSize) {
        return _getScanWindow(constraints, previewSize);
      },
      overlayBuilder: (context, constraints, state) {
        // final bytes = _inputImageBytes;
        // if (bytes == null) return Container();
        // return Image.memory(bytes);

        final scanWindow = state.scanWindow;
        if (scanWindow == null) return null;
        return MobileScannerOverlay(
          scanWindow: scanWindow,
          barcode: null,
          detectionMode: state.detectionMode,
          onModeSelected: (mode) async {
            await _scannerController.setDetectionMode(mode);
          },
          isFlashlightOn:
              state.cameraController?.value.flashMode == FlashMode.torch,
          onFlashlightToggle: () async {
            await _scannerController.toggleTorch();
          },
          onCameraSwitch: () async {
            await _scannerController.switchCamera();
          },
        );
      },
      onBarcodesDetected: _onBarcodesDetected,
      onTextDetected: _onTextDetected,
      child: _customPaint,
    );
  }
}
