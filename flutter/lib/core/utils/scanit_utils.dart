import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

import '../painters/barcode_detector_painter.dart';
import '../painters/text_detector_painter.dart';
import '../processing/scanit_processor_event.dart';

extension ScanItProcessorEventExtension on ScanItProcessorEvent {
  CustomPainter? get painter {
    return switch (this) {
      BarcodesDetectedEvent barcodesEvent => barcodesEvent.painter,
      TextRecognizedEvent textRecognizedEvent => textRecognizedEvent.painter,
    };
  }
}

extension BarcodesDetectedEventExtension on BarcodesDetectedEvent {
  BarcodeDetectorPainter? get painter {
    final rotation = inputImage.metadata?.rotation;
    if (barcodes.isEmpty || rotation == null) return null;

    return BarcodeDetectorPainter(
      widgetSize: widgetSize,
      imageSize: imageSize,
      inputImageRotation: rotation,
      barcodes: barcodes,
      cameraLensDirection: lensDirection,
      scanArea: scanArea,
    );
  }
}

extension TextRecognizedEventExtension on TextRecognizedEvent {
  TextRecognizerPainter? get painter {
    final rotation = inputImage.metadata?.rotation;
    if (recognizedText.text.isEmpty || rotation == null) return null;

    return TextRecognizerPainter(
      imageSize: imageSize,
      inputImageRotation: rotation,
      recognizedText: recognizedText,
      cameraLensDirection: lensDirection,
      scanArea: scanArea,
      widgetSize: widgetSize,
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

extension SizeExtension on Size {
  Rect get asBounds {
    return Rect.fromLTWH(0, 0, width, height);
  }
}

extension CameraImageExtension on CameraImage {
  Size get size {
    return Size(width.toDouble(), height.toDouble());
  }
}

extension ObjectExtension on Object? {
  T? castOrNull<T>() {
    if (this is T) return this as T;
    return null;
  }
}
