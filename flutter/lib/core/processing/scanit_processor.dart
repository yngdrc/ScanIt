import 'dart:math';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/widgets.dart';
import 'package:scanit/core/utils/camera_image_extension.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import '../detection_mode.dart';

sealed class ScanItProcessorEvent {
  const ScanItProcessorEvent({
    required this.inputImage,
    required this.lensDirection,
    required this.imageSize,
    required this.scanArea,
    required this.scale,
  });

  final InputImage inputImage;
  final CameraLensDirection lensDirection;
  final Size imageSize;
  final Rect scanArea;
  final double scale;
}

class BarcodesDetectedEvent extends ScanItProcessorEvent {
  BarcodesDetectedEvent({
    required this.barcodes,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanArea,
    required super.scale,
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
    required super.scale,
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
    required CameraImage cameraImage,
    required DetectionMode detectionMode,
    required Rect scanArea,
    required InputImageRotation inputImageRotation,
    required CameraLensDirection cameraLensDirection,
    required double scale,
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    ScanItProcessorEvent? event;
    try {
      final inputImage = await cameraImage.inputImageFromBytes(
        cropRect: scanArea,
        rotation: inputImageRotation,
      );

      if (inputImage == null) {
        _isBusy = false;
        return null;
      }

      event = await _process(
        inputImage: inputImage,
        lensDirection: cameraLensDirection,
        detectionMode: detectionMode,
        imageSize: Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        ),
        scanArea: scanArea,
        scale: scale,
      );
    } catch (e) {
      // TODO: handle error
    }

    _isBusy = false;
    return event;
  }

  // TODO: scanWindow support
  Future<ScanItProcessorEvent?> processXFile({
    required XFile xFile,
    required DetectionMode detectionMode,
    required Rect scanArea,
    required double scale,
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
      scale: scale,
    );

    _isBusy = false;
    return event;
  }

  Future<ScanItProcessorEvent> _process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size imageSize,
    required Rect scanArea,
    required double scale,
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
          scale: scale
        );
      case DetectionMode.ocr:
        final recognizedText = await _textRecognizer.processImage(inputImage);
        return TextRecognizedEvent(
          recognizedText: recognizedText,
          inputImage: inputImage,
          lensDirection: lensDirection,
          imageSize: imageSize,
          scanArea: scanArea,
          scale: scale,
        );
    }
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
