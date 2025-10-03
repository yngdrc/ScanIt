import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'coordinates_translator_android.dart';
import 'coordinates_translator_ios.dart';

double translateX({
  required double x,
  required Size widgetSize,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  if (Platform.isIOS) {
    return translateXIos(
      x: x,
      widgetSize: widgetSize,
      canvasSize: canvasSize,
      imageSize: imageSize,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      scanArea: scanArea,
    );
  }

  return translateXAndroid(
    x: x,
    widgetSize: widgetSize,
    canvasSize: canvasSize,
    imageSize: imageSize,
    inputImageRotation: inputImageRotation,
    cameraLensDirection: cameraLensDirection,
    scanArea: scanArea,
  );
}

double translateY({
  required double y,
  required Size canvasSize,
  required Size imageSize,
  required InputImageRotation inputImageRotation,
  required CameraLensDirection cameraLensDirection,
  required Rect scanArea,
}) {
  if (Platform.isIOS) {
    return translateYIos(
      y: y,
      canvasSize: canvasSize,
      imageSize: imageSize,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      scanArea: scanArea,
    );
  }

  return translateYAndroid(
    y: y,
    canvasSize: canvasSize,
    imageSize: imageSize,
    inputImageRotation: inputImageRotation,
    cameraLensDirection: cameraLensDirection,
    scanArea: scanArea,
  );
}
