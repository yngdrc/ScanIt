import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/widgets.dart';
import 'package:scanit/core/utils/camera_image_extension.dart';

import '../detection_mode.dart';

sealed class ScanItProcessorEvent {
  const ScanItProcessorEvent({
    required this.inputImage,
    required this.lensDirection,
    required this.imageSize,
    required this.scanArea,
  });

  final InputImage inputImage;
  final CameraLensDirection lensDirection;
  final Size imageSize;
  final Rect? scanArea;
}

class BarcodesDetectedEvent extends ScanItProcessorEvent {
  BarcodesDetectedEvent({
    required this.barcodes,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanArea,
  });

  final List<Barcode> barcodes;
}

class TextRecognizedEvent extends ScanItProcessorEvent {
  TextRecognizedEvent({
    required this.recognizedText,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanArea,
  });

  final RecognizedText recognizedText;
}

class ScanItProcessor {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _canProcess = true;
  bool _isBusy = false;

  Future<ScanItProcessorEvent?> processCameraImage({
    required CameraController cameraController,
    required CameraImage cameraImage,
    required DetectionMode detectionMode,
    required Rect scanArea,
    required Size bounds,
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final cameraDescription = cameraController.description;
    final deviceOrientation = cameraController.value.deviceOrientation;
    final sensorOrientation = cameraDescription.sensorOrientation;
    final lensDirection = cameraDescription.lensDirection;

    final imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    if (deviceOrientation == DeviceOrientation.portraitUp ||
        deviceOrientation == DeviceOrientation.portraitDown) {
      bounds = bounds.flipped;
      scanArea = Rect.fromLTWH(
        scanArea.top,
        scanArea.left,
        scanArea.height,
        scanArea.width,
      );
    }

    final previewRect = Rect.fromCenter(
      center: imageSize.center(Offset.zero),
      width: bounds.width,
      height: bounds.height,
    );

    final translatedScanArea = Rect.fromLTWH(
      scanArea.left + previewRect.left,
      scanArea.top + previewRect.top,
      scanArea.width,
      scanArea.height,
    );

    final inputImage = await cameraImage.inputImageFromBytes(
      cropRect: translatedScanArea,
      sensorOrientation: sensorOrientation,
      lensDirection: lensDirection,
      deviceOrientation: deviceOrientation,
    );

    if (inputImage == null) {
      _isBusy = false;
      return null;
    }

    final event = await _process(
      inputImage: inputImage,
      lensDirection: lensDirection,
      detectionMode: detectionMode,
      imageSize: imageSize,
      scanArea: translatedScanArea,
    );

    _isBusy = false;
    return event;
  }

  // TODO: scanWindow support
  Future<ScanItProcessorEvent?> processXFile({
    required XFile xFile,
    required DetectionMode detectionMode,
    required Rect scanArea,
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final image = await decodeImageFromList(await xFile.readAsBytes());

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImage = InputImage.fromFilePath(xFile.path);
    final event = await _process(
      inputImage: inputImage,
      lensDirection: CameraLensDirection.back,
      detectionMode: detectionMode,
      imageSize: imageSize,
      scanArea: scanArea,
    );

    _isBusy = false;
    return event;
  }

  Future<ScanItProcessorEvent> _process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size imageSize,
    required Rect? scanArea,
  }) async {
    switch (detectionMode) {
      case DetectionMode.barcode:
        final barcodes = await _barcodeScanner.processImage(inputImage);
        return BarcodesDetectedEvent(
          barcodes: barcodes,
          inputImage: inputImage,
          lensDirection: lensDirection,
          imageSize: imageSize,
          scanArea: scanArea,
        );
      case DetectionMode.ocr:
        final recognizedText = await _textRecognizer.processImage(inputImage);
        return TextRecognizedEvent(
          recognizedText: recognizedText,
          inputImage: inputImage,
          lensDirection: lensDirection,
          imageSize: imageSize,
          scanArea: scanArea,
        );
    }
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
