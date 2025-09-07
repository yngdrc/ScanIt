import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/ui/scanner/processing/camera_image_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner_detection_mode.dart';

sealed class CameraProcessorEvent {
  const CameraProcessorEvent({
    required this.inputImage,
    required this.lensDirection,
    required this.cameraImageSize,
    required this.scanWindow,
  });

  final InputImage inputImage;
  final CameraLensDirection lensDirection;
  final Size cameraImageSize;
  final Rect? scanWindow;
}

class BarcodesDetectedEvent extends CameraProcessorEvent {
  BarcodesDetectedEvent({
    required this.barcodes,
    required super.inputImage,
    required super.lensDirection,
    required super.cameraImageSize,
    required super.scanWindow,
  });

  final List<Barcode> barcodes;
}

class TextRecognizedEvent extends CameraProcessorEvent {
  TextRecognizedEvent({
    required this.recognizedText,
    required super.inputImage,
    required super.lensDirection,
    required super.cameraImageSize,
    required super.scanWindow,
  });

  final RecognizedText recognizedText;
}

class CameraProcessor {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _canProcess = true;
  bool _isBusy = false;

  Future<CameraProcessorEvent?> processImage({
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

    final cameraImageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    CameraProcessorEvent event;
    switch (detectionMode) {
      case DetectionMode.barcode:
        final barcodes = await _barcodeScanner.processImage(inputImage);
        event = BarcodesDetectedEvent(
          barcodes: barcodes,
          inputImage: inputImage,
          lensDirection: lensDirection,
          cameraImageSize: cameraImageSize,
          scanWindow: scanWindow,
        );
      case DetectionMode.ocr:
        final recognizedText = await _textRecognizer.processImage(inputImage);
        event = TextRecognizedEvent(
          recognizedText: recognizedText,
          inputImage: inputImage,
          lensDirection: lensDirection,
          cameraImageSize: cameraImageSize,
          scanWindow: scanWindow
        );
    }

    _isBusy = false;
    return event;
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
