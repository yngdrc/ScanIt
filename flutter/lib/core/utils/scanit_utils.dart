import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Rect rotateBy({required int angle, Offset? anchor}) {
    anchor ??= center;
    final radians = angle * (pi / 180);
    final matrix = Matrix4.identity()
      ..translateByVector3(Vector3(anchor.dx, anchor.dy, 0))
      ..rotateZ(radians)
      ..translateByVector3(Vector3(-anchor.dx, -anchor.dy, 0));

    return MatrixUtils.transformRect(matrix, this);
  }
}

extension CameraValueExtension on CameraValue {
  bool get isLandscape {
    return applicableOrientation.isLandscape;
  }

  int get quarterTurns {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[applicableOrientation]!;
  }

  DeviceOrientation get applicableOrientation {
    return isRecordingVideo
        ? recordingOrientation!
        : (previewPauseOrientation ??
              lockedCaptureOrientation ??
              deviceOrientation);
  }
}

extension DeviceOrientationExtension on DeviceOrientation {
  bool get isLandscape {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(this);
  }
}
