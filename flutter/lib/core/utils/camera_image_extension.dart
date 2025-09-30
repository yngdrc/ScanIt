import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

extension CameraImageExtension on CameraImage {
  Future<InputImage?> inputImageFromBytes({
    required Rect cropRect,
    required InputImageRotation rotation,
  }) async {
    final format = InputImageFormatValue.fromRawValue(this.format.raw);
    if (format == null) return null;

    switch (format) {
      case InputImageFormat.yv12:
      case InputImageFormat.yuv420:
        throw UnimplementedError();
      case InputImageFormat.yuv_420_888:
        return _yuv420888(cropRect, rotation);
      case InputImageFormat.nv21:
      case InputImageFormat.bgra8888:
        return _nv21_bgra8888(cropRect, rotation, format);
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
    Rect cropRect,
    InputImageRotation rotation,
    InputImageFormat format,
  ) async {
    if (planes.length != 1) return null;
    final plane = planes.first;

    final startX = cropRect.left.toInt();
    final startY = cropRect.top.toInt();
    final cropWidth = cropRect.width.toInt();
    final cropHeight = cropRect.height.toInt();

    final bytesPerPixel = format == InputImageFormat.bgra8888 ? 4 : 1;
    final croppedBytes = Uint8List(cropWidth * cropHeight * bytesPerPixel);

    for (int y = 0; y < cropHeight; y++) {
      final srcStart =
          ((startY + y) * plane.bytesPerRow) + (startX * bytesPerPixel);
      final dstStart = y * cropWidth * bytesPerPixel;
      croppedBytes.setRange(
        dstStart,
        dstStart + cropWidth * bytesPerPixel,
        plane.bytes,
        srcStart,
      );
    }

    return InputImage.fromBytes(
      bytes: croppedBytes,
      metadata: InputImageMetadata(
        size: Size(cropWidth.toDouble(), cropHeight.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: cropWidth * bytesPerPixel,
      ),
    );
  }
}
