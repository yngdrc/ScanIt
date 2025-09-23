import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/core/detection_mode.dart';
import 'package:scanit/core/scanit_controller_state.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import 'processing/scanit_processor.dart';

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
        cameraLensDirection: cameraController.description.lensDirection,
        deviceOrientation: cameraController.value.applicableOrientation,
      );
    });

    return Result.capture(imageStreamFuture);
  }

  Future<void> _processCameraImage({
    required CameraImage cameraImage,
    required CameraLensDirection cameraLensDirection,
    required DeviceOrientation deviceOrientation,
  }) async {
    final scanArea = value.scanArea;
    final widgetSize = value.widgetSize;
    final inputImageRotation = value.inputImageRotation;
    if (scanArea == null || widgetSize == null || inputImageRotation == null) {
      return;
    }

    final imageBounds = Rect.fromLTWH(
      0,
      0,
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final scale = imageBounds.longestSide / widgetSize.longestSide;
    final scaledBounds = Rect.fromCenter(
      center: imageBounds.center,
      width: widgetSize.width * scale,
      height: widgetSize.height * scale,
    ).rotateBy(angle: -inputImageRotation.rawValue);

    final calculatedScanArea =
        Rect.fromLTWH(
          scanArea.left * scale,
          scanArea.top * scale,
          scanArea.width * scale,
          scanArea.height * scale,
        ).transform((rect) {
          final newRect = switch (inputImageRotation) {
            InputImageRotation.rotation0deg => rect.shift(scaledBounds.topLeft),
            InputImageRotation.rotation90deg =>
              rect
                  .shift(scaledBounds.bottomLeft)
                  .rotateBy(
                    angle: -inputImageRotation.rawValue,
                    anchor: scaledBounds.bottomLeft,
                  ),
            InputImageRotation.rotation180deg =>
              rect
                  .shift(scaledBounds.bottomRight)
                  .rotateBy(
                    angle: inputImageRotation.rawValue,
                    anchor: scaledBounds.bottomRight,
                  ),
            InputImageRotation.rotation270deg =>
              rect
                  .shift(scaledBounds.topRight)
                  .rotateBy(
                    angle: inputImageRotation.rawValue,
                    anchor: scaledBounds.topRight,
                  ),
          };

          return newRect;
        });

    final future = _scanItProcessor
        .processCameraImage(
          cameraImage: cameraImage,
          detectionMode: value.detectionMode,
          scanArea: calculatedScanArea,
          inputImageRotation: inputImageRotation,
          cameraLensDirection: cameraLensDirection,
          scale: scale,
        )
        .then((event) {
          if (event == null) return;
          _handleProcessorEvent(event: event);
        });

    _processingOperation = CancelableOperation.fromFuture(future);
  }

  Future<void> processImageFile({required FilePickerResult result}) async {
    final scanArea = value.scanArea;
    final xFile = result.xFiles.firstOrNull;
    if (xFile == null || scanArea == null) return;

    await _cancelProcessing();
    final future = _scanItProcessor
        .processXFile(
          xFile: xFile,
          detectionMode: value.detectionMode,
          scanArea: scanArea,
          scale: 0,
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

  void onPreviewReady({
    required Rect scanArea,
    required Size widgetSize,
    required Size previewSize,
    required CameraDescription cameraDescription,
    required DeviceOrientation deviceOrientation,
  }) {
    final sensorOrientation = cameraDescription.sensorOrientation;
    final lensDirection = cameraDescription.lensDirection;

    /**
     * get image rotation
     * it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
     * `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
     * in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
     */
    InputImageRotation? inputImageRotation;
    if (Platform.isIOS) {
      inputImageRotation = InputImageRotationValue.fromRawValue(
        sensorOrientation,
      );
    } else if (Platform.isAndroid) {
      final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

      var rotationCompensation = orientations[deviceOrientation];

      if (rotationCompensation == null) return;
      if (lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      inputImageRotation = InputImageRotationValue.fromRawValue(
        rotationCompensation,
      );
    }

    if (inputImageRotation == null) return;

    value = value.copyWith(
      scanArea: scanArea,
      widgetSize: widgetSize,
      previewSize: previewSize,
      inputImageRotation: inputImageRotation,
    );
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
