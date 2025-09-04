import 'dart:async';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/ui/scanner/processing/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/mobile_scanner_detection_mode.dart';

class ScannerControllerState {
  const ScannerControllerState({
    required this.detectionMode,
    this.cameraController,
    this.scanWindow,
  });

  final DetectionMode detectionMode;
  final CameraController? cameraController;
  final Rect? scanWindow;

  ScannerControllerState copyWith({
    CameraController? cameraController,
    DetectionMode? detectionMode,
    Rect? scanWindow,
  }) {
    return ScannerControllerState(
      detectionMode: detectionMode ?? this.detectionMode,
      cameraController: cameraController ?? this.cameraController,
      scanWindow: scanWindow ?? this.scanWindow,
    );
  }
}

class ScannerController extends ValueNotifier<ScannerControllerState> {
  ScannerController({
    DetectionMode initialDetectionMode = DetectionMode.barcode,
  }) : super(ScannerControllerState(detectionMode: initialDetectionMode));

  final CameraProcessor _cameraProcessor = CameraProcessor();
  CancelableOperation<void>? _processingOperation;
  ListenableSubscription? _cameraControllerSubscription;

  final StreamController<(List<Barcode>, InputImage, CameraLensDirection)>
  _barcodesStreamController = StreamController.broadcast();

  final StreamController<(RecognizedText, InputImage, CameraLensDirection)>
  _recognizedTextStreamController = StreamController.broadcast();

  Stream<(List<Barcode>, InputImage, CameraLensDirection)> get barcodes =>
      _barcodesStreamController.stream;

  Stream<(RecognizedText, InputImage, CameraLensDirection)>
  get recognizedText => _recognizedTextStreamController.stream;

  // scan window (460, 180, 820, 540)
  Future<void> setScanWindow(Rect? scanWindow) async {
    if (value.scanWindow == scanWindow) return;
    value = value.copyWith(scanWindow: scanWindow);

    final cameraController = value.cameraController;
    if (cameraController == null) {
      await _cancelProcessing();
    } else {
      await _startScanning(cameraController);
    }
  }

  Future<void> setDetectionMode(DetectionMode detectionMode) async {
    if (value.detectionMode == detectionMode) return;
    value = value.copyWith(detectionMode: detectionMode);

    final cameraController = value.cameraController;
    if (cameraController == null) {
      await _cancelProcessing();
    } else {
      await _startScanning(cameraController);
    }
  }

  Future<void> toggleTorch() async {
    final cameraController = value.cameraController;
    if (cameraController == null) return;

    final currentFlashMode = cameraController.value.flashMode;
    FlashMode newFlashMode;
    switch (currentFlashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.torch;
      case FlashMode.auto:
      case FlashMode.always:
      case FlashMode.torch:
        newFlashMode = FlashMode.off;
    }

    await cameraController.setFlashMode(newFlashMode);
  }

  Future<void> switchCamera() async {
    final cameraController = value.cameraController;
    if (cameraController == null) return;

    CameraLensDirection cameraLensDirection;
    switch (cameraController.value.description.lensDirection) {
      case CameraLensDirection.back:
        cameraLensDirection = CameraLensDirection.front;
      case CameraLensDirection.front:
      case CameraLensDirection.external:
        cameraLensDirection = CameraLensDirection.back;
    }

    await initializeScanner(cameraLensDirection: cameraLensDirection);
  }

  Future<void> initializeScanner({
    CameraLensDirection? cameraLensDirection,
  }) async {
    try {
      final currentLensDirection =
          value.cameraController?.description.lensDirection;

      await disposeCamera();

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
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

      _cameraControllerSubscription = cameraController.listen((_, _) {
        notifyListeners();
      });

      value = value.copyWith(cameraController: cameraController);
      await cameraController.initialize();
      await _startScanning(cameraController);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: ${e.code} - ${e.description}');
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _startScanning(CameraController cameraController) async {
    await _cancelProcessing();
    return cameraController.startImageStream((image) {
      _processingOperation = _process(image, cameraController);
    });
  }

  CancelableOperation<void> _process(
    CameraImage image,
    CameraController cameraController,
  ) {
    Future<void> future;
    switch (value.detectionMode) {
      case DetectionMode.barcode:
        future = _cameraProcessor
            .processBarcodes(cameraController, image, value.scanWindow)
            .then((data) {
              if (data == null) return;
              _barcodesStreamController.add((
                data.$1,
                data.$2,
                cameraController.description.lensDirection,
              ));
            });
      case DetectionMode.ocr:
        future = _cameraProcessor
            .processOCR(cameraController, image, value.scanWindow)
            .then((data) {
              if (data == null) return;
              _recognizedTextStreamController.add((
                data.$1,
                data.$2,
                cameraController.description.lensDirection,
              ));
            });
    }

    return CancelableOperation.fromFuture(future);
  }

  Future<void> _cancelProcessing() async {
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
    _cameraControllerSubscription?.cancel();
    await _cancelProcessing();
    final currentCameraController = value.cameraController;
    value = ScannerControllerState(
      cameraController: null,
      detectionMode: value.detectionMode,
    );

    await currentCameraController?.dispose();
  }

  @override
  void dispose() {
    _barcodesStreamController.close();
    unawaited(disposeCamera().then((_) => _cameraProcessor.dispose()));
    super.dispose();
  }
}
