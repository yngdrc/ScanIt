import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

double translateX({
  required double x,
  required Size widgetSize,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  switch (inputImageRotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      final scale = Size(
        canvasSize.width,
        Platform.isIOS ? imageSize.width : imageSize.height,
      ).aspectRatio;

      return (scanArea.top + x) * scale;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      final scale = canvasSize.width / imageSize.width;
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return (scanArea.left + x)  * scale;
        default:
          return (scanArea.left + canvasSize.width - x) * scale;
      }
  }
}

double translateY({
  required double y,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  switch (inputImageRotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return (scanArea.left + y) *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return (scanArea.top + y) * canvasSize.height / imageSize.height;
  }
}
