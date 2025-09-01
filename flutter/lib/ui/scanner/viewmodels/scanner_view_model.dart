import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
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
    CameraController? cameraController,
    DetectionMode? detectionMode,
    Barcode? barcode,
    RecognizedText? ocrText,
    Size? size,
    InputImageRotation? rotation,
  }) {
    return ScannerUiState(
      cameraController: cameraController ?? this.cameraController,
      detectionMode: detectionMode ?? this.detectionMode,
      barcode: barcode ?? this.barcode,
      ocrText: ocrText ?? this.ocrText,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }

  ScannerUiState withResult({
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
  CancelableOperation<void>? _processingOperation;

  ListenableSubscription barcodeChanges(Function(Barcode?) onBarcodeChanged) {
    return select(
      (uiState) => uiState.barcode,
    ).listen((barcode, _) => onBarcodeChanged(barcode));
  }

  Future<void> initializeScanner({
    DetectionMode? detectionMode,
    CameraLensDirection? cameraLensDirection,
  }) async {
    try {
      final currentLensDirection =
          value.cameraController?.description.lensDirection;

      await disposeCamera();
      final cameras = await availableCameras();
      final cameraDescription = cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (cameraLensDirection ??
                currentLensDirection ??
                CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: false,
      )..setFlashMode(FlashMode.off);

      value = ScannerUiState(
        cameraController: cameraController,
        detectionMode: detectionMode ?? value.detectionMode,
        barcode: null,
        ocrText: null,
        size: null,
        rotation: null,
      );

      _cameraControllerSubscription = cameraController.listen((_, _) {
        notifyListeners();
      });

      await cameraController.initialize();
      await _startScanning(cameraController, value.detectionMode);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: ${e.code} - ${e.description}');
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _startScanning(
    CameraController cameraController,
    DetectionMode detectionMode,
  ) async {
    await cancelProcessing();
    return cameraController.startImageStream((image) {
      _processingOperation = _process(image, cameraController, detectionMode);
    });
  }

  CancelableOperation<void> _process(
    CameraImage image,
    CameraController cameraController,
    DetectionMode detectionMode,
  ) {
    Future<void> future;
    switch (detectionMode) {
      case DetectionMode.barcode:
        future = _cameraProcessor.processBarcodes(cameraController, image).then(
          (data) {
            if (data == null) return;
            value = value.withResult(
              barcode: data.$1.firstOrNull,
              ocrText: null,
              size: data.$2.metadata?.size,
              rotation: data.$2.metadata?.rotation,
            );
          },
        );
      case DetectionMode.ocr:
        future = _cameraProcessor.processOCR(cameraController, image).then((
          data,
        ) {
          if (data == null) return;
          value = value.withResult(
            barcode: null,
            ocrText: data.$1,
            size: data.$2.metadata?.size,
            rotation: data.$2.metadata?.rotation,
          );
        });
    }

    return CancelableOperation.fromFuture(future);
  }

  void clearScanResult() {
    value = ScannerUiState(
      cameraController: value.cameraController,
      detectionMode: value.detectionMode,
      barcode: null,
      ocrText: null,
      size: null,
      rotation: null,
    );

    unawaited(initializeScanner());
  }

  Future<void> cancelProcessing() async {
    try {
      await value.cameraController?.stopImageStream();
    } on CameraException catch (e) {
      debugPrint('Error stopping image stream: ${e.code} - ${e.description}');
    } on Exception catch (e) {
      debugPrint('Error stopping image stream: $e');
    }

    return _processingOperation?.cancel();
  }

  Future<void> disposeCamera() async {
    final currentCameraController = value.cameraController;
    _cameraControllerSubscription?.cancel();
    await cancelProcessing();

    value = ScannerUiState(
      cameraController: null,
      detectionMode: value.detectionMode,
      barcode: null,
      ocrText: null,
      size: null,
      rotation: null,
    );

    await currentCameraController?.dispose();
  }

  @override
  void dispose() {
    disposeCamera().then((_) async {
      _cameraProcessor.dispose();
    });

    super.dispose();
  }
}
