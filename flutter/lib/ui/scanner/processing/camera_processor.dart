
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/ui/scanner/processing/camera_image_extension.dart';

class CameraProcessor {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _canProcess = true;
  bool _isBusy = false;

  Future<(List<Barcode>, InputImage)?> processBarcodes(
    CameraController cameraController,
    CameraImage image,
    Rect? cropRect,
  ) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final cameraDescription = cameraController.description;
    final deviceOrientation = cameraController.value.deviceOrientation;
    final sensorOrientation = cameraDescription.sensorOrientation;
    final lensDirection = cameraDescription.lensDirection;

    final inputImage = await image.inputImageFromBytes(
        cropRect,
        sensorOrientation,
        lensDirection,
        deviceOrientation
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
    Rect? cropRect,
  ) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final cameraDescription = cameraController.description;
    final deviceOrientation = cameraController.value.deviceOrientation;
    final sensorOrientation = cameraDescription.sensorOrientation;
    final lensDirection = cameraDescription.lensDirection;

    final inputImage = await image.inputImageFromBytes(
        cropRect,
        sensorOrientation,
        lensDirection,
        deviceOrientation
    );

    if (inputImage == null) {
      _isBusy = false;
      return null;
    }

    final recognizedText = await _textRecognizer.processImage(inputImage);

    _isBusy = false;
    return (recognizedText, inputImage);
  }

  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
