import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

extension CameraImageExtension on CameraImage {
  Future<InputImage?> inputImageFromBytes({
    required Rect cropRect,
    required int sensorOrientation,
    required CameraLensDirection lensDirection,
    required DeviceOrientation deviceOrientation,
  }) async {
    final format = InputImageFormatValue.fromRawValue(this.format.raw);
    if (format == null) return null;

    /**
     * get image rotation
     * it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
     * `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
     * in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
     */
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

      var rotationCompensation = orientations[deviceOrientation];

      if (rotationCompensation == null) return null;
      if (lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    switch (format) {
      case InputImageFormat.yv12:
      case InputImageFormat.yuv420:
        throw UnimplementedError();
      case InputImageFormat.yuv_420_888:
        return _yuv420888(cropRect, rotation);
      case InputImageFormat.nv21:
      case InputImageFormat.bgra8888:
        return _nv21_bgra8888(rotation, format);
    }
  }

  ///  Converts a YUV_420_888 CameraImage to an InputImage in NV21 format.
  Future<InputImage?> _yuv420888(
    Rect cropRect,
    InputImageRotation rotation,
  ) async {
    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final startX = cropRect.left.toInt();
    final startY = cropRect.top.toInt();
    final cropWidth = cropRect.width.toInt();
    final cropHeight = cropRect.height.toInt();

    final croppedY = Uint8List(cropWidth * cropHeight);
    for (int y = 0; y < cropHeight; y++) {
      final srcStart = (startY + y) * yPlane.bytesPerRow + startX;
      final dstStart = y * cropWidth;
      croppedY.setRange(dstStart, dstStart + cropWidth, yPlane.bytes, srcStart);
    }

    final uvWidth = cropWidth ~/ 2;
    final uvHeight = cropHeight ~/ 2;
    final uvStartX = startX ~/ 2;
    final uvStartY = startY ~/ 2;

    final croppedU = Uint8List(uvWidth * uvHeight);
    final croppedV = Uint8List(uvWidth * uvHeight);

    for (int y = 0; y < uvHeight; y++) {
      final uSrcStart = (uvStartY + y) * uPlane.bytesPerRow + uvStartX;
      final vSrcStart = (uvStartY + y) * vPlane.bytesPerRow + uvStartX;
      final dstStart = y * uvWidth;
      croppedU.setRange(dstStart, dstStart + uvWidth, uPlane.bytes, uSrcStart);
      croppedV.setRange(dstStart, dstStart + uvWidth, vPlane.bytes, vSrcStart);
    }

    final croppedBytes = Uint8List(
      croppedY.length + croppedU.length + croppedV.length,
    );
    croppedBytes.setRange(0, croppedY.length, croppedY);
    for (int i = 0; i < croppedU.length; i++) {
      croppedBytes[croppedY.length + i * 2] = croppedV[i];
      croppedBytes[croppedY.length + i * 2 + 1] = croppedU[i];
    }

    return InputImage.fromBytes(
      bytes: croppedBytes,
      metadata: InputImageMetadata(
        size: Size(cropWidth.toDouble(), cropHeight.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: cropWidth,
      ),
    );
  }

  Future<InputImage?> _nv21_bgra8888(
    InputImageRotation rotation,
    InputImageFormat format,
  ) async {
    // since format is constraint to nv21, it only has one plane
    if (planes.length != 1) return null;
    final plane = planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
