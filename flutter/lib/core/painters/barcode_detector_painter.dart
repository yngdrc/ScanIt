import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../utils/coordinates_translator.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter({
    required this.widgetSize,
    required this.imageSize,
    required this.inputImageRotation,
    required this.barcodes,
    required this.cameraLensDirection,
    required this.scanArea,
  });

  final Size widgetSize;
  final Size imageSize;
  final InputImageRotation inputImageRotation;
  final List<Barcode> barcodes;
  final CameraLensDirection cameraLensDirection;
  final Rect scanArea;

  final _edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..color = Colors.lightGreenAccent;

  final _paragraphStyle = ParagraphStyle(
    textAlign: TextAlign.left,
    fontSize: 16,
    textDirection: TextDirection.ltr,
  );

  final _textStyle = ui.TextStyle(
    color: Colors.lightGreenAccent,
    background: Paint()..color = Color(0x99000000),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var barcode in barcodes) {
      _drawBarcodeEdges(barcode: barcode, canvas: canvas, size: size);
      _drawBarcodeText(barcode: barcode, canvas: canvas, size: size);
    }
  }

  void _drawBarcodeEdges({
    required Barcode barcode,
    required Canvas canvas,
    required Size size,
  }) {
    final cornerPoints = <Offset>[];
    for (final point in barcode.cornerPoints) {
      final x = translateX(
        x: point.x.toDouble(),
        widgetSize: widgetSize,
        canvasSize: size,
        imageSize: imageSize,
        inputImageRotation: inputImageRotation,
        cameraLensDirection: cameraLensDirection,
        scanArea: scanArea,
      );

      final y = translateY(
        y: point.y.toDouble(),
        canvasSize: size,
        imageSize: imageSize,
        inputImageRotation: inputImageRotation,
        cameraLensDirection: cameraLensDirection,
        scanArea: scanArea,
      );

      cornerPoints.add(Offset(x, y));
    }

    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, _edgePaint);
  }

  void _drawBarcodeText({
    required Barcode barcode,
    required Canvas canvas,
    required Size size,
  }) {
    final builder = ParagraphBuilder(_paragraphStyle)
      ..pushStyle(_textStyle)
      ..addText('${barcode.displayValue}')
      ..pop();

    final left = translateX(
      x: barcode.boundingBox.left,
      widgetSize: widgetSize,
      canvasSize: size,
      imageSize: imageSize,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      scanArea: scanArea,
    );

    final top = translateY(
      y: barcode.boundingBox.top,
      canvasSize: size,
      imageSize: imageSize,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      scanArea: scanArea,
    );

    final right = translateX(
      x: barcode.boundingBox.right,
      widgetSize: widgetSize,
      canvasSize: size,
      imageSize: imageSize,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      scanArea: scanArea,
    );

    final paragraphConstraints = ParagraphConstraints(
      width: (right - left).abs(),
    );

    final offset = Offset(
      Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
          ? right
          : left,
      top,
    );

    canvas.drawParagraph(builder.build()..layout(paragraphConstraints), offset);
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.barcodes != barcodes;
  }
}
