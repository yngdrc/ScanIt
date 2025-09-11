import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../utils/coordinates_translator.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter({
    required this.imageSize,
    required this.rotation,
    required this.recognizedText,
    required this.cameraLensDirection,
    required this.scanWindow,
  });

  final Size imageSize;
  final InputImageRotation rotation;
  final RecognizedText recognizedText;
  final CameraLensDirection cameraLensDirection;
  final Rect? scanWindow;

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
    for (final textBlock in recognizedText.blocks) {
      _drawTextBlockEdges(textBlock: textBlock, canvas: canvas, size: size);
      _drawTextBlockText(textBlock: textBlock, canvas: canvas, size: size);
    }
  }

  void _drawTextBlockEdges({
    required TextBlock textBlock,
    required Canvas canvas,
    required Size size,
  }) {
    final cornerPoints = <Offset>[];
    for (final point in textBlock.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
        scanWindow,
      );

      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
        scanWindow,
      );

      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  scanWindow,
                );

                y =
                    size.height -
                        translateY(
                          point.x.toDouble(),
                          size,
                          imageSize,
                          rotation,
                          cameraLensDirection,
                          scanWindow,
                        );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x =
                    size.width -
                        translateX(
                          point.y.toDouble(),
                          size,
                          imageSize,
                          rotation,
                          cameraLensDirection,
                          scanWindow,
                        );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  scanWindow,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, _edgePaint);
  }

  void _drawTextBlockText({
    required TextBlock textBlock,
    required Canvas canvas,
    required Size size,
  }) {
    final builder = ParagraphBuilder(_paragraphStyle);
    builder.pushStyle(_textStyle);
    builder.addText(textBlock.text);
    builder.pop();

    final left = translateX(
      textBlock.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
      scanWindow,
    );

    final top = translateY(
      textBlock.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
      scanWindow,
    );

    final right = translateX(
      textBlock.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
      scanWindow,
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
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}
