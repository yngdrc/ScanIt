import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:nil/nil.dart';

typedef OnPreviewReady =
    void Function({
      required Size widgetSize,
      required Size previewSize,
      required InputImageRotation inputImageRotation,
    });

class ScanItCameraPreview extends StatefulWidget {
  const ScanItCameraPreview({
    super.key,
    required this.cameraController,
    required this.constraints,
    this.onPreviewReady,
    this.child,
  });

  final CameraController cameraController;
  final BoxConstraints constraints;
  final OnPreviewReady? onPreviewReady;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ScanItCameraPreviewState();
}

class _ScanItCameraPreviewState extends State<ScanItCameraPreview>
    with WidgetsBindingObserver {
  ListenableSubscription? _previewSizeSubscription;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.inactive:
        _disposeListeners();
      case AppLifecycleState.resumed:
        _setupListeners();
    }
  }

  @override
  void dispose() {
    _disposeListeners();
    super.dispose();
  }

  ValueListenable<Size?> get _previewSizeListenable =>
      widget.cameraController.select((cameraValue) => cameraValue.previewSize);

  ValueListenable<DeviceOrientation> get _deviceOrientationListenable => widget
      .cameraController
      .select((cameraValue) => cameraValue.deviceOrientation);

  void _setupListeners() {
    _previewSizeSubscription = _previewSizeListenable
        .combineLatest(
          _deviceOrientationListenable,
          (previewSize, deviceOrientation) => (previewSize, deviceOrientation),
        )
        .listen((data, _) {
          final (previewSize, deviceOrientation) = data;
          if (previewSize == null) return;

          final cameraDescription = widget.cameraController.description;
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
              rotationCompensation =
                  (sensorOrientation + rotationCompensation) % 360;
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

          widget.onPreviewReady?.call(
            widgetSize: widget.constraints.biggest,
            previewSize: previewSize,
            inputImageRotation: inputImageRotation,
          );
        });
  }

  void _disposeListeners() {
    _previewSizeSubscription?.cancel();
    _previewSizeSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: widget.cameraController,
      builder: (context, cameraValue, child) {
        if (!cameraValue.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize = cameraValue.previewSize;
        if (previewSize == null) return Nil();

        final aspectRatio = _isLandscape(cameraValue: cameraValue)
            ? previewSize.aspectRatio
            : (1 / previewSize.aspectRatio);

        final scale =
            max(widget.constraints.biggest.aspectRatio, aspectRatio) /
            min(widget.constraints.biggest.aspectRatio, aspectRatio);

        return Transform.scale(
          scale: scale,
          child: Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _wrapInRotatedBox(
                    cameraValue: cameraValue,
                    child: widget.cameraController.buildPreview(),
                  ),
                  ?child,
                ],
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _wrapInRotatedBox({
    required CameraValue cameraValue,
    required Widget child,
  }) {
    if (defaultTargetPlatform != TargetPlatform.android) return child;
    return RotatedBox(
      quarterTurns: _getQuarterTurns(cameraValue: cameraValue),
      child: child,
    );
  }

  bool _isLandscape({required CameraValue cameraValue}) {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(_getApplicableOrientation(cameraValue: cameraValue));
  }

  int _getQuarterTurns({required CameraValue cameraValue}) {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation(cameraValue: cameraValue)]!;
  }

  DeviceOrientation _getApplicableOrientation({
    required CameraValue cameraValue,
  }) {
    return cameraValue.isRecordingVideo
        ? cameraValue.recordingOrientation!
        : (cameraValue.previewPauseOrientation ??
              cameraValue.lockedCaptureOrientation ??
              cameraValue.deviceOrientation);
  }
}
