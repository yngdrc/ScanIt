
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/widgets.dart';
import 'package:scanit/core/processing/camera_image_extension.dart';

import '../scanner_detection_mode.dart';

sealed class ScanItProcessorEvent {
  const ScanItProcessorEvent({
    required this.inputImage,
    required this.lensDirection,
    required this.imageSize,
    required this.scanWindow,
  });

  final InputImage inputImage;
  final CameraLensDirection lensDirection;
  final Size imageSize;
  final Rect? scanWindow;
}

class BarcodesDetectedEvent extends ScanItProcessorEvent {
  BarcodesDetectedEvent({
    required this.barcodes,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanWindow,
  });

  final List<Barcode> barcodes;
}

class TextRecognizedEvent extends ScanItProcessorEvent {
  TextRecognizedEvent({
    required this.recognizedText,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanWindow,
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
    required Rect? scanWindow,
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final cameraDescription = cameraController.description;
    final deviceOrientation = cameraController.value.deviceOrientation;
    final sensorOrientation = cameraDescription.sensorOrientation;
    final lensDirection = cameraDescription.lensDirection;

    final inputImage = await cameraImage.inputImageFromBytes(
      scanWindow,
      sensorOrientation,
      lensDirection,
      deviceOrientation,
    );

    if (inputImage == null) {
      _isBusy = false;
      return null;
    }

    final imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final event = await _process(
      inputImage: inputImage,
        lensDirection: lensDirection,
        detectionMode: detectionMode,
        imageSize: imageSize,
        scanWindow: scanWindow,
    );

    _isBusy = false;
    return event;
  }


  // TODO: scanWindow support
  Future<ScanItProcessorEvent?> processXFile({
    required XFile xFile,
    required DetectionMode detectionMode,
    required Rect? scanWindow
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final image = await decodeImageFromList(
      await xFile.readAsBytes(),
    );

    final imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImage = InputImage.fromFilePath(xFile.path);
    final event = await _process(
      inputImage: inputImage,
      lensDirection: CameraLensDirection.back,
      detectionMode: detectionMode,
      imageSize: imageSize,
      scanWindow: scanWindow,
    );

    _isBusy = false;
    return event;
  }

  Future<ScanItProcessorEvent> _process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size imageSize,
    required Rect? scanWindow,
  }) async {
    switch (detectionMode) {
      case DetectionMode.barcode:
        final barcodes = await _barcodeScanner.processImage(inputImage);
        return BarcodesDetectedEvent(
          barcodes: barcodes,
          inputImage: inputImage,
          lensDirection: lensDirection,
          imageSize: imageSize,
          scanWindow: scanWindow,
        );
      case DetectionMode.ocr:
        final recognizedText = await _textRecognizer.processImage(inputImage);
        return TextRecognizedEvent(
          recognizedText: recognizedText,
          inputImage: inputImage,
          lensDirection: lensDirection,
          imageSize: imageSize,
          scanWindow: scanWindow,
        );
    }
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
