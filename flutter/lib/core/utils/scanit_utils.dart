import 'package:flutter/material.dart';

import '../painters/barcode_detector_painter.dart';
import '../painters/text_detector_painter.dart';
import '../processing/scanit_processor.dart';

CustomPainter? painterFromEvent({required ScanItProcessorEvent event}) {
  final rotation = event.inputImage.metadata?.rotation;
  if (rotation == null) return null;

  switch (event) {
    case BarcodesDetectedEvent _:
      if (event.barcodes.isEmpty) return null;
      return BarcodeDetectorPainter(
        imageSize: event.imageSize,
        rotation: rotation,
        barcodes: event.barcodes,
        cameraLensDirection: event.lensDirection,
        scanArea: event.scanArea,
      );
    case TextRecognizedEvent _:
      if (event.recognizedText.text.isEmpty) return null;
      return TextRecognizerPainter(
        imageSize: event.imageSize,
        rotation: rotation,
        recognizedText: event.recognizedText,
        cameraLensDirection: event.lensDirection,
        scanArea: event.scanArea,
      );
  }
}
