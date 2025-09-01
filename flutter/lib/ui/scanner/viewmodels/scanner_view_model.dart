import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/ui/scanner/painters/barcode_detector_painter.dart';
import 'package:scanit/ui/scanner/viewmodels/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/mobile_scanner_detection_mode.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../painters/text_detector_painter.dart';
import '../widgets/dialogs/core/scan_result_dialog.dart';

class ScannerUiState {
  ScannerUiState({
    required this.cameraController,
    required this.detectionMode,
    required this.barcode,
    required this.ocrText,
    required this.size,
    required this.rotation,
  });

  final CameraController? cameraController;
  final DetectionMode detectionMode;
  final Barcode? barcode;
  final RecognizedText? ocrText;
  final Size? size;
  final InputImageRotation? rotation;

  CustomPaint? get customPaint {
    final size = this.size;
    final rotation = this.rotation;
    final barcode = this.barcode;
    final ocrText = this.ocrText;
    final lensDirection = cameraController?.description.lensDirection;

    if (size == null || rotation == null || lensDirection == null) return null;

    CustomPainter painter;
    switch (detectionMode) {
      case DetectionMode.barcode when barcode != null:
        painter = BarcodeDetectorPainter(
          [barcode],
          size,
          rotation,
          lensDirection,
        );
      case DetectionMode.ocr when ocrText != null:
        painter = TextRecognizerPainter(ocrText, size, rotation, lensDirection);
      default:
        return null;
    }

    return CustomPaint(painter: painter);
  }

  ScannerUiState copyWith({
    required CameraController? cameraController,
    required DetectionMode detectionMode,
    required Barcode? barcode,
    required RecognizedText? ocrText,
    required Size? size,
    required InputImageRotation? rotation,
  }) {
    return ScannerUiState(
      cameraController: cameraController,
      detectionMode: detectionMode,
      barcode: barcode,
      ocrText: ocrText,
      size: size,
      rotation: rotation,
    );
  }
}

class ScannerViewModel extends ValueNotifier<ScannerUiState> {
  ScannerViewModel({required DetectionMode initialDetectionMode})
    : _cameraProcessor = CameraProcessor(),
      super(
        ScannerUiState(
          cameraController: null,
          detectionMode: initialDetectionMode,
          barcode: null,
          ocrText: null,
          size: null,
          rotation: null,
        ),
      );

  final CameraProcessor _cameraProcessor;
  ListenableSubscription? _cameraControllerSubscription;

  ListenableSubscription barcodeChanges(Function(Barcode?) onBarcodeChanged) {
    return select(
      (uiState) => uiState.barcode,
    ).listen((barcode, _) => onBarcodeChanged(barcode));
  }

  Future<void> initializeScanner({
    DetectionMode? detectionMode,
    CameraLensDirection? cameraLensDirection,
  }) async {
    final currentCameraController = value.cameraController;
    final cameras = await availableCameras();
    final cameraDescription = cameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (cameraLensDirection ??
              currentCameraController?.description.lensDirection ??
              CameraLensDirection.back),
      orElse: () => cameras.first,
    );

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraControllerSubscription?.cancel();
    value = value.copyWith(
      cameraController: cameraController,
      detectionMode: detectionMode ?? value.detectionMode,
      barcode: null,
      ocrText: null,
      size: null,
      rotation: null,
    );

    _cameraControllerSubscription = cameraController.listen((cameraValue, _) {
      value = value.copyWith(
        cameraController: cameraController..value = cameraValue,
        detectionMode: detectionMode ?? value.detectionMode,
        barcode: value.barcode,
        ocrText: value.ocrText,
        size: value.size,
        rotation: value.rotation,
      );
    });

    await currentCameraController?.dispose();
    await cameraController.initialize();

    await startScanning(
      cameraController: cameraController,
      detectionMode: detectionMode ?? value.detectionMode,
    );
  }

  Future<void> startScanning({
    required CameraController cameraController,
    required DetectionMode detectionMode,
  }) async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }

    await cameraController.startImageStream((image) async {
      switch (detectionMode) {
        case DetectionMode.barcode:
          await _processBarcode(image, cameraController, (data) async {
            // cameraController.stopImageStream();
            value = value.copyWith(
              cameraController: value.cameraController,
              detectionMode: detectionMode,
              barcode: data.$1,
              ocrText: null,
              size: data.$2.metadata?.size,
              rotation: data.$2.metadata?.rotation,
            );
          });
        case DetectionMode.ocr:
          await _processOCR(image, cameraController, (data) async {
            // cameraController.stopImageStream();
            value = value.copyWith(
              cameraController: value.cameraController,
              detectionMode: detectionMode,
              barcode: null,
              ocrText: data.$1,
              size: data.$2.metadata?.size,
              rotation: data.$2.metadata?.rotation,
            );
          });
      }
    });
  }

  Future<void> _processBarcode(
    CameraImage image,
    CameraController cameraController,
    Function((Barcode, InputImage)) onImageProcessed,
  ) async {
    final data = await _cameraProcessor.processBarcode(cameraController, image);
    if (data == null) return;

    final barcodes = data.$1;
    if (barcodes.isEmpty) return;

    final inputImage = data.$2;
    onImageProcessed((barcodes.first, inputImage));
  }

  Future<void> _processOCR(
    CameraImage image,
    CameraController cameraController,
    Function((RecognizedText, InputImage)) onTextRecognized,
  ) async {
    final data = await _cameraProcessor.processOCR(cameraController, image);
    if (data == null) return;

    onTextRecognized(data);
  }

  void clearScanResult() {
    value = value.copyWith(
      cameraController: value.cameraController,
      detectionMode: value.detectionMode,
      barcode: null,
      ocrText: null,
      size: null,
      rotation: null,
    );

    unawaited(initializeScanner());
  }

  @override
  void dispose() {
    _cameraControllerSubscription?.cancel();
    value.cameraController?.dispose();
    _cameraProcessor.dispose();
    super.dispose();
  }
}
