import 'package:flutter/material.dart';
import 'package:scanit/ui/scanner/processing/camera_processor.dart';

import '../painters/barcode_detector_painter.dart';
import '../painters/text_detector_painter.dart';

abstract class ScannerUtils {
  static CustomPainter? painterFromEvent({
    required CameraProcessorEvent event,
  }) {
    final rotation = event.inputImage.metadata?.rotation;
    if (rotation == null) return null;

    switch (event) {
      case BarcodesDetectedEvent _:
        if (event.barcodes.isEmpty) return null;
        return BarcodeDetectorPainter(
          imageSize: event.cameraImageSize,
          rotation: rotation,
          barcodes: event.barcodes,
          cameraLensDirection: event.lensDirection,
          scanWindow: event.scanWindow,
        );
      case TextRecognizedEvent _:
        if (event.recognizedText.text.isEmpty) return null;
        return TextRecognizerPainter(
          imageSize: event.cameraImageSize,
          rotation: rotation,
          recognizedText: event.recognizedText,
          cameraLensDirection: event.lensDirection,
          scanWindow: event.scanWindow,
        );
    }
  }
}
