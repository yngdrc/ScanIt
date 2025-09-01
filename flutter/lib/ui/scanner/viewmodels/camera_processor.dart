import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/plugins/converter_plugin.dart';

class CameraProcessor {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _canProcess = true;
  bool _isBusy = false;

  Future<(List<Barcode>, InputImage)?> processBarcode(
    CameraController cameraController,
    CameraImage image,
  ) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final inputImage = await _inputImageFromCameraImage(
      cameraController,
      image,
    );

    if (inputImage == null) {
      _isBusy = false;
      return null;
    }

    final barcodes = await _barcodeScanner.processImage(inputImage);
    _isBusy = false;

    return (barcodes, inputImage);
  }

  Future<(RecognizedText, InputImage)?> processOCR(
    CameraController cameraController,
    CameraImage image,
  ) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final inputImage = await _inputImageFromCameraImage(
      cameraController,
      image,
    );

    if (inputImage == null) {
      _isBusy = false;
      return null;
    }

    final recognizedText = await _textRecognizer.processImage(inputImage);

    _isBusy = false;
    return (recognizedText, inputImage);
  }

  Future<InputImage?> _inputImageFromCameraImage(
    CameraController cameraController,
    CameraImage image,
  ) async {
    /**
     * get image rotation
     * it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
     * `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
     * in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
     */
    final cameraDescription = cameraController.description;
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

    return await image.inputImageFromBytes(rotation);
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}

extension _CameraImageExtension on CameraImage {
  Future<InputImage?> inputImageFromBytes(InputImageRotation rotation) async {
    final format = InputImageFormatValue.fromRawValue(this.format.raw);
    if (format == null) return null;

    switch (format) {
      case InputImageFormat.yv12:
      case InputImageFormat.yuv420:
        throw UnimplementedError();
      case InputImageFormat.yuv_420_888:
        return _yuv_420_888(rotation);
      case InputImageFormat.nv21:
        return _nv21(rotation);
      case InputImageFormat.bgra8888:
        return _bgra8888(rotation);
    }
  }

  Future<InputImage?> _yuv_420_888(InputImageRotation rotation) async {
    if (!Platform.isAndroid) return null;

    final data = await ConverterPlugin.yuv420888ToNv21(this);
    if (data == null) return null;

    return InputImage.fromBytes(
      bytes: data,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: data.length,
      ),
    );
  }

  Future<InputImage?> _nv21(InputImageRotation rotation) async {
    if (!Platform.isAndroid) return null;

    // since format is constraint to nv21, it only has one plane
    if (planes.length != 1) return null;
    final plane = planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<InputImage?> _bgra8888(InputImageRotation rotation) async {
    if (!Platform.isIOS) return null;

    // since format is constraint to nv21, it only has one plane
    if (planes.length != 1) return null;
    final plane = planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
