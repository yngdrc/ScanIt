import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/core/detection_mode.dart';
import 'package:scanit/core/processing/scanit_processor.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';

class BarcodeProcessor extends ScanItProcessor<BarcodesDetectedEvent> {
  BarcodeProcessor() : super(DetectionMode.barcode);

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  @override
  Future<BarcodesDetectedEvent> process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size widgetSize,
    required Size imageSize,
    required Rect scanArea,
  }) async {
    final barcodes = await _barcodeScanner.processImage(inputImage);
    return BarcodesDetectedEvent(
      barcodes: barcodes,
      widgetSize: widgetSize,
      inputImage: inputImage,
      lensDirection: lensDirection,
      imageSize: imageSize,
      scanArea: scanArea,
    );
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _barcodeScanner.close();
  }
}