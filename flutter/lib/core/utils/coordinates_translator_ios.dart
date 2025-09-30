import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateXIos({
  required double x,
  required Size widgetSize,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  final scale = canvasSize.width / imageSize.width;
  return (scanArea.left + x) * scale;
}

double translateYIos({
  required double y,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  return (scanArea.top + y) * canvasSize.height / imageSize.height;
}
