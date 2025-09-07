import 'dart:async';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:scanit/ui/scanner/processing/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner_detection_mode.dart';

class ScannerControllerState {
  const ScannerControllerState({
    required this.detectionMode,
    this.cameraController,
    this.scanWindow,
  });

  final DetectionMode detectionMode;
  final CameraController? cameraController;
  final Rect? scanWindow;

  FlashMode? get flashMode => cameraController?.value.flashMode;

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

  final StreamController<BarcodesDetectedEvent>
  _barcodeDetectedEventsController = StreamController.broadcast();

  final StreamController<TextRecognizedEvent> _textRecognizedEventsController =
      StreamController.broadcast();

  Stream<BarcodesDetectedEvent> get barcodesStream =>
      _barcodeDetectedEventsController.stream;

  Stream<TextRecognizedEvent> get ocrStream =>
      _textRecognizedEventsController.stream;

  Future<void> setScanWindow({required Rect? scanWindow}) async {
    if (value.scanWindow == scanWindow) return;
    value = value.copyWith(scanWindow: scanWindow);

    final cameraController = value.cameraController;
    if (cameraController == null) {
      await _cancelProcessing();
    } else {
      await _startScanning(cameraController: cameraController);
    }
  }

  Future<void> setDetectionMode({required DetectionMode detectionMode}) async {
    if (value.detectionMode == detectionMode) return;
    value = value.copyWith(detectionMode: detectionMode);

    final cameraController = value.cameraController;
    if (cameraController == null) {
      await _cancelProcessing();
    } else {
      await _startScanning(cameraController: cameraController);
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

      _cameraControllerSubscription = cameraController.listen((cameraValue, _) {
        notifyListeners();
      });

      value = value.copyWith(cameraController: cameraController);
      await cameraController.initialize();
      await _startScanning(cameraController: cameraController);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: ${e.code} - ${e.description}');
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _startScanning({
    required CameraController cameraController,
  }) async {
    await _cancelProcessing();
    return cameraController.startImageStream((cameraImage) {
      _processingOperation = _process(
        cameraImage: cameraImage,
        cameraController: cameraController,
      );
    });
  }

  CancelableOperation<void> _process({
    required CameraImage cameraImage,
    required CameraController cameraController,
  }) {
    final future = _cameraProcessor
        .processImage(
          cameraController: cameraController,
          cameraImage: cameraImage,
          detectionMode: value.detectionMode,
          scanWindow: value.scanWindow,
        )
        .then((event) {
          switch (event) {
            case BarcodesDetectedEvent _:
              return _barcodeDetectedEventsController.add(event);
            case TextRecognizedEvent _:
              return _textRecognizedEventsController.add(event);
            default:
              return;
          }
        });

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
    _cameraControllerSubscription = null;

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
    _barcodeDetectedEventsController.close();
    _textRecognizedEventsController.close();
    unawaited(disposeCamera().then((_) => _cameraProcessor.dispose()));
    super.dispose();
  }
}
