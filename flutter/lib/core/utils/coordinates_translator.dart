import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
  Rect? scanArea,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return ((scanArea?.top ?? 0) + x) *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return ((scanArea?.top ?? 0) + canvasSize.width - x) *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return ((scanArea?.left ?? 0) + x) *
              canvasSize.width /
              imageSize.width;
        default:
          return ((scanArea?.left ?? 0) + canvasSize.width - x) *
              canvasSize.width /
              imageSize.width;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
  Rect? scanArea,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return ((scanArea?.left ?? 0) + y) *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return ((scanArea?.top ?? 0) + y) *
          canvasSize.height /
          imageSize.height;
  }
}
