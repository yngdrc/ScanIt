import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/ui/scanner/viewmodels/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/mobile_scanner_detection_mode.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../widgets/dialogs/core/scan_result_dialog.dart';

class ScannerUiState {
  ScannerUiState({
    required this.cameraController,
    required this.detectionMode,
    required this.barcode,
    required this.ocrText,
  });

  final CameraController? cameraController;
  final DetectionMode detectionMode;
  final Barcode? barcode;
  final String? ocrText;

  ScannerUiState copyWith({
    required CameraController? cameraController,
    required DetectionMode detectionMode,
    required Barcode? barcode,
    required String? ocrText,
  }) {
    return ScannerUiState(
      cameraController: cameraController,
      detectionMode: detectionMode,
      barcode: barcode,
      ocrText: ocrText,
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
      barcode: value.barcode,
      ocrText: value.ocrText,
    );

    _cameraControllerSubscription = cameraController.listen((cameraValue, _) {
      value = value.copyWith(
        cameraController: cameraController..value = cameraValue,
        detectionMode: value.detectionMode,
        barcode: value.barcode,
        ocrText: value.ocrText,
      );
    });

    await currentCameraController?.dispose();
    await cameraController.initialize();

    startScanning(
      cameraController: cameraController,
      detectionMode: value.detectionMode,
    );
  }

  void startScanning({
    required CameraController cameraController,
    required DetectionMode detectionMode,
  }) {
    if (value.barcode != null) return;

    cameraController.startImageStream((image) async {
      switch (detectionMode) {
        case DetectionMode.barcode:
          await _processBarcode(image, cameraController, (barcode) async {
            cameraController.stopImageStream();
            value = value.copyWith(
              cameraController: value.cameraController,
              detectionMode: value.detectionMode,
              barcode: barcode,
              ocrText: null,
            );
          });
        case DetectionMode.ocr:
          await _processOCR(image, cameraController, (text) async {
            cameraController.stopImageStream();
            value = value.copyWith(
              cameraController: value.cameraController,
              detectionMode: value.detectionMode,
              barcode: null,
              ocrText: text,
            );
          });
      }
    });
  }

  Future<void> _processBarcode(CameraImage image,
      CameraController cameraController,
      Function(Barcode) onImageProcessed,) async {
    final data = await _cameraProcessor.processBarcode(cameraController, image);
    if (data == null) return;

    final barcodes = data.$1;
    if (barcodes.isEmpty) return;

    final inputImage = data.$2;
    onImageProcessed(barcodes.first);
  }

  Future<void> _processOCR(CameraImage image,
      CameraController cameraController,
      Function(String) onTextRecognized,) async {
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
