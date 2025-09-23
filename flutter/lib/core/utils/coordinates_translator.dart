import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation inputImageRotation,
  CameraLensDirection cameraLensDirection,
  Rect scanArea,
  double scale,
) {
  switch (inputImageRotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      final scale1 =
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);

      return (scanArea.left + x) / scale;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      final scale = canvasSize.width / imageSize.width;
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return (scanArea.left + x) * scale;
        default:
          return (scanArea.left + canvasSize.width - x) * scale;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
  Rect scanArea,
) {
  switch (rotation) {
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
