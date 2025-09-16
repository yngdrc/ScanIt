import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

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

extension RectExtension on Rect {
  Rect rotateBy({required int angle}) {
    final radians = angle * (pi / 180);
    final center = this.center;
    final matrix = Matrix4.identity()
      ..translateByVector3(Vector3(center.dx, center.dy, 0))
      ..rotateZ(radians)
      ..translateByVector3(Vector3(-center.dx, -center.dy, 0));

    return MatrixUtils.transformRect(matrix, this);
  }
}
