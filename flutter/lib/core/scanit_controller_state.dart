
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'detection_mode.dart';

class ScanItControllerState {
  const ScanItControllerState({
    required this.detectionMode,
    this.scanArea,
    this.widgetSize,
    this.previewSize,
    this.inputImageRotation,
    this.cameraController,
  });

  final DetectionMode detectionMode;
  final Rect? scanArea;
  final Size? widgetSize;
  final Size? previewSize;
  final InputImageRotation? inputImageRotation;
  final CameraController? cameraController;

  FlashMode? get flashMode => cameraController?.value.flashMode;

  bool get isCameraControllerInitialized =>
      cameraController?.value.isInitialized ?? false;

  ScanItControllerState copyWith({
    DetectionMode? detectionMode,
    Rect? scanArea,
    Size? widgetSize,
    Size? previewSize,
    DeviceOrientation? deviceOrientation,
    InputImageRotation? inputImageRotation,
    CameraController? cameraController,
  }) {
    return ScanItControllerState(
      detectionMode: detectionMode ?? this.detectionMode,
      scanArea: scanArea ?? this.scanArea,
      widgetSize: widgetSize ?? this.widgetSize,
      previewSize: previewSize ?? this.previewSize,
      inputImageRotation: inputImageRotation ?? this.inputImageRotation,
      cameraController: cameraController ?? this.cameraController,
    );
  }
}