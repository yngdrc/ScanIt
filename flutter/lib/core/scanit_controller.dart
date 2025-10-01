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
import 'package:scanit/core/processing/scanit_processor_event.dart';
import 'package:scanit/core/scanit_controller_state.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import 'processing/scanit_processor.dart';

class ScanItController extends ValueNotifier<ScanItControllerState> {
  ScanItController({DetectionMode initialDetectionMode = DetectionMode.barcode})
    : _scanItProcessor = ScanItProcessor.factoryConstructor(
        detectionMode: initialDetectionMode,
      ),
      super(ScanItControllerState(detectionMode: initialDetectionMode));

  final ScanItProcessor _scanItProcessor;

  Stream<ScanItProcessorEvent> get eventStream => _scanItProcessor.eventStream;

  void onCameraImage({
    required CameraImage cameraImage,
    required CameraDescription cameraDescription,
    required DeviceOrientation deviceOrientation,
  }) {
    final sensorOrientation = cameraDescription.sensorOrientation;
    final cameraLensDirection = cameraDescription.lensDirection;

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
      if (cameraLensDirection == CameraLensDirection.front) {
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

    processCameraImage(
      cameraImage: cameraImage,
      cameraLensDirection: cameraLensDirection,
      deviceOrientation: deviceOrientation,
      inputImageRotation: inputImageRotation,
    );
  }

  void onCameraInitialized({
    required Rect? scanArea,
    required Size widgetSize,
  }) => value = value.copyWith(scanArea: scanArea, widgetSize: widgetSize);

  void onCameraDisposed() => _scanItProcessor.cancelProcessing();

  void processCameraImage({
    required CameraImage cameraImage,
    required CameraLensDirection cameraLensDirection,
    required DeviceOrientation deviceOrientation,
    required InputImageRotation inputImageRotation,
  }) {
    final scanArea = value.scanArea;
    final widgetSize = value.widgetSize;
    if (widgetSize == null) return;

    _scanItProcessor.processCameraImage(
      cameraImage: cameraImage,
      scanArea: scanArea ?? widgetSize.asBounds,
      inputImageRotation: inputImageRotation,
      cameraLensDirection: cameraLensDirection,
      widgetSize: widgetSize,
      deviceOrientation: deviceOrientation,
    );
  }

  Future<void> processImageFile(FilePickerResult result) async {
    // TODO
  }

  void setDetectionMode(DetectionMode detectionMode) {
    if (value.detectionMode == detectionMode) return;
    value = value.copyWith(detectionMode: detectionMode);
  }

  // Future<Result<void>> toggleTorch() {
  //   final cameraController = _cameraController;
  //   if (cameraController == null) {
  //     return Future.value(Result.error("Camera not initialized"));
  //   }
  //
  //   final currentFlashMode = cameraController.value.flashMode;
  //   final newFlashMode = switch (currentFlashMode) {
  //     FlashMode.off => FlashMode.torch,
  //     _ => FlashMode.off,
  //   };
  //
  //   return Result.capture(cameraController.setFlashMode(newFlashMode));
  // }

  // Future<Result<void>> switchCamera() {
  //   final cameraController = _cameraController;
  //   if (cameraController == null) {
  //     return Future.value(Result.error("Camera not initialized"));
  //   }
  //
  //   final cameraDescription = cameraController.description;
  //   final lensDirection = cameraDescription.lensDirection;
  //   final cameraLensDirection = switch (lensDirection) {
  //     CameraLensDirection.back => CameraLensDirection.front,
  //     _ => CameraLensDirection.back,
  //   };
  //
  //   return Result.capture(cameraController.setDescription(cameraDescription));
  //   // return initialize(cameraLensDirection: cameraLensDirection);
  // }

  @override
  void dispose() {
    unawaited(
      _scanItProcessor.cancelProcessing().then(
        (_) => _scanItProcessor.dispose(),
      ),
    );

    super.dispose();
  }
}
