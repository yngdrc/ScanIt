import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/plugins/converter_plugin.dart';

import '../painters/barcode_detector_painter.dart';

class CameraProcessor {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _canProcess = true;
  bool _isBusy = false;

  Future<InputImage?> _inputImageFromCameraImage(
    CameraController cameraController,
    CameraDescription cameraDescription,
    CameraImage image,
  ) async {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final sensorOrientation = cameraDescription.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[cameraController.value.deviceOrientation];

      if (rotationCompensation == null) return null;
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
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

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == InputImageFormat.yuv_420_888) {
      final data = await ConverterPlugin.yuv420888ToNv21(image);
      return InputImage.fromBytes(
        bytes: data!,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation, // used only in Android
          format: InputImageFormat.nv21, // used only in iOS
          bytesPerRow: data.length, // used only in iOS
        ),
      );
    }

    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  Future<(List<Barcode>, InputImage)?> processImage(
    CameraController cameraController,
    CameraDescription cameraDescription,
    CameraImage image,
  ) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final inputImage = await _inputImageFromCameraImage(
      cameraController,
      cameraDescription,
      image,
    );

    if (inputImage == null) return null;

    final barcodes = await _barcodeScanner.processImage(inputImage);
    _isBusy = false;

    return (barcodes, inputImage);
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
  }
}
