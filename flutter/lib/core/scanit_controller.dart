import 'dart:async';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:scanit/core/scanner_detection_mode.dart';

import 'processing/scanit_processor.dart';

class ScanItControllerState {
  const ScanItControllerState({
    required this.detectionMode,
    this.cameraController,
    this.scanWindow,
  });

  final DetectionMode detectionMode;
  final CameraController? cameraController;
  final Rect? scanWindow;

  FlashMode? get flashMode => cameraController?.value.flashMode;

  bool get isCameraControllerInitialized =>
      cameraController?.value.isInitialized ?? false;

  ScanItControllerState copyWith({
    CameraController? cameraController,
    DetectionMode? detectionMode,
    Rect? scanWindow,
  }) {
    return ScanItControllerState(
      detectionMode: detectionMode ?? this.detectionMode,
      cameraController: cameraController ?? this.cameraController,
      scanWindow: scanWindow ?? this.scanWindow,
    );
  }
}

class ScanItController extends ValueNotifier<ScanItControllerState> {
  ScanItController({DetectionMode initialDetectionMode = DetectionMode.barcode})
    : super(ScanItControllerState(detectionMode: initialDetectionMode));

  final ScanItProcessor _scanItProcessor = ScanItProcessor();
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

  Future<Result<void>> initialize({
    CameraLensDirection? cameraLensDirection,
    bool autoStartScanning = true,
  }) async {
    final currentLensDirection =
        value.cameraController?.description.lensDirection;

    await disposeCamera();

    final availableCamerasResult = await Result.capture(availableCameras());
    if (availableCamerasResult.isError) return availableCamerasResult.asError!;

    final cameras = availableCamerasResult.asValue!.value;
    if (cameras.isEmpty) return Result.error("No available cameras found");
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
    );

    value = value.copyWith(cameraController: cameraController);
    _cameraControllerSubscription = cameraController.listen((cameraValue, _) {
      notifyListeners();
    });

    final initializeCameraFuture = cameraController.initialize().then(
      (_) => cameraController.setFlashMode(FlashMode.off),
    );

    return Result.capture(initializeCameraFuture).then((result) {
      if (!autoStartScanning || result.isError) return result;
      return startScanning();
    });
  }

  Future<Result<void>> startScanning() {
    final cameraController = value.cameraController;
    if (cameraController == null) {
      return Future.value(Result.error("Camera not initialized"));
    }

    final imageStreamFuture = cameraController.startImageStream((cameraImage) {
      _processCameraImage(
        cameraImage: cameraImage,
        cameraController: cameraController,
      );
    });

    return Result.capture(imageStreamFuture);
  }

  Future<void> _processCameraImage({
    required CameraImage cameraImage,
    required CameraController cameraController,
  }) async {
    final future = _scanItProcessor
        .processCameraImage(
          cameraController: cameraController,
          cameraImage: cameraImage,
          detectionMode: value.detectionMode,
          scanWindow: value.scanWindow,
        )
        .then((event) {
          if (event == null) return;
          _handleProcessorEvent(event: event);
        });

    _processingOperation = CancelableOperation.fromFuture(future);
  }

  Future<void> processImageFile({
    required FilePickerResult result,
    required scanWindow,
  }) async {
    final xFile = result.xFiles.firstOrNull;
    if (xFile == null) return;

    await _cancelProcessing();
    final future = _scanItProcessor
        .processXFile(
          xFile: xFile,
          detectionMode: value.detectionMode,
          scanWindow: scanWindow,
        )
        .then((event) {
          if (event == null) return;
          _handleProcessorEvent(event: event);
        });

    _processingOperation = CancelableOperation.fromFuture(future);
  }

  void _handleProcessorEvent({required ScanItProcessorEvent event}) {
    switch (event) {
      case BarcodesDetectedEvent _:
        return _barcodeDetectedEventsController.add(event);
      case TextRecognizedEvent _:
        return _textRecognizedEventsController.add(event);
    }
  }

  void setScanWindow({required Rect? scanWindow}) {
    if (value.scanWindow == scanWindow) return;
    value = value.copyWith(scanWindow: scanWindow);
  }

  void setDetectionMode({required DetectionMode detectionMode}) {
    if (value.detectionMode == detectionMode) return;
    value = value.copyWith(detectionMode: detectionMode);
  }

  Future<Result<void>> toggleTorch() {
    final cameraController = value.cameraController;
    if (cameraController == null) {
      return Future.value(Result.error("Camera not initialized"));
    }

    final currentFlashMode = cameraController.value.flashMode;
    final newFlashMode = switch (currentFlashMode) {
      FlashMode.off => FlashMode.torch,
      _ => FlashMode.off,
    };

    return Result.capture(cameraController.setFlashMode(newFlashMode));
  }

  Future<Result<void>> switchCamera() {
    final cameraController = value.cameraController;
    if (cameraController == null) {
      return Future.value(Result.error("Camera not initialized"));
    }

    final lensDirection = cameraController.value.description.lensDirection;
    final cameraLensDirection = switch (lensDirection) {
      CameraLensDirection.back => CameraLensDirection.front,
      _ => CameraLensDirection.back,
    };

    return initialize(cameraLensDirection: cameraLensDirection);
  }

  Future<Result<void>> _cancelProcessing() async {
    final stopImageStreamFuture =
        value.cameraController?.stopImageStream() ?? Future.value();

    final stopProcessingFuture =
        _processingOperation?.cancel().then((_) {
          _processingOperation = null;
        }) ??
        Future.value();

    return Result.capture(stopImageStreamFuture).then((result) async {
      final stopProcessingResult = await Result.capture(stopProcessingFuture);
      return result.asError ?? stopProcessingResult;
    });
  }

  Future<Result<void>> disposeCamera() {
    final future = _cancelProcessing().then((_) async {
      final currentCameraController = value.cameraController;
      value = ScanItControllerState(
        cameraController: null,
        detectionMode: value.detectionMode,
      );

      await currentCameraController?.dispose();
      _cameraControllerSubscription?.cancel();
      _cameraControllerSubscription = null;
    });

    return Result.capture(future);
  }

  @override
  void dispose() {
    unawaited(_barcodeDetectedEventsController.close());
    unawaited(_textRecognizedEventsController.close());
    unawaited(disposeCamera().then((_) => _scanItProcessor.dispose()));
    super.dispose();
  }
}
