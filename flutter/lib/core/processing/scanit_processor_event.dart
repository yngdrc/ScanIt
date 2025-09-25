import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

sealed class ScanItProcessorEvent {
  const ScanItProcessorEvent({
    required this.widgetSize,
    required this.inputImage,
    required this.lensDirection,
    required this.imageSize,
    required this.scanArea,
  });

  final InputImage inputImage;
  final CameraLensDirection lensDirection;
  final Size widgetSize;
  final Size imageSize;
  final Rect scanArea;
}

class BarcodesDetectedEvent extends ScanItProcessorEvent {
  BarcodesDetectedEvent({
    required this.barcodes,
    required super.widgetSize,
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
    required super.widgetSize,
    required super.inputImage,
    required super.lensDirection,
    required super.imageSize,
    required super.scanArea,
  });

  final RecognizedText recognizedText;
}