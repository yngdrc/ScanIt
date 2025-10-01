import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

class ScanItCameraPreview extends StatefulWidget {
  const ScanItCameraPreview({
    super.key,
    required this.constraints,
    required this.onCameraInitialized,
    required this.onCameraError,
    required this.onCameraDisposed,
    required this.onCameraImage,
    this.cameraLensDirection = CameraLensDirection.back,
    this.child,
  });

  final BoxConstraints constraints;
  final void Function(Size) onCameraInitialized;
  final void Function(ErrorResult) onCameraError;
  final VoidCallback onCameraDisposed;
  final void Function(CameraImage, CameraDescription, DeviceOrientation)
  onCameraImage;

  final CameraLensDirection cameraLensDirection;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ScanItCameraPreviewState();
}

class _ScanItCameraPreviewState extends State<ScanItCameraPreview>
    with WidgetsBindingObserver {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize(cameraLensDirection: widget.cameraLensDirection));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(_disposeCamera());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCamera());
    super.dispose();
  }

  Future<void> _initialize({CameraLensDirection? cameraLensDirection}) async {
    final currentLensDirection = _cameraController?.description.lensDirection;
    await _disposeCamera();

    final availableCamerasResult = await Result.capture(availableCameras());
    if (availableCamerasResult.isError) {
      return widget.onCameraError(availableCamerasResult.asError!);
    }

    final cameras = availableCamerasResult.asValue!.value;
    if (cameras.isEmpty) {
      return widget.onCameraError(ErrorResult("No available cameras found"));
    }

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

    setState(() {
      _cameraController = cameraController;
    });

    // TODO catchError instead of result?
    final initializeCameraFuture = cameraController
        .initialize()
        .then((_) => widget.onCameraInitialized(widget.constraints.biggest))
        .then((_) => _startScanning());

    await Result.capture(initializeCameraFuture).then((result) async {
      if (result.isError) return widget.onCameraError(result.asError!);
    });
  }

  Future<void> _startScanning() async {
    final cameraController = _cameraController;
    if (cameraController == null) {
      return widget.onCameraError(ErrorResult("Camera not initialized"));
    }

    final imageStreamFuture = cameraController.startImageStream((cameraImage) {
      final cameraDescription = cameraController.description;
      final deviceOrientation = cameraController.value.applicableOrientation;

      widget.onCameraImage(cameraImage, cameraDescription, deviceOrientation);
    });

    return Result.capture(imageStreamFuture).then((result) {
      if (result.isError) return widget.onCameraError(result.asError!);
    });
  }

  Future<void> _disposeCamera() async {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    final future = cameraController.stopImageStream().then((_) {
      setState(() {
        _cameraController = null;
      });

      cameraController.dispose();
      widget.onCameraDisposed();
    });

    await Result.capture(future).then((result) {
      if (result.isError) return widget.onCameraError(result.asError!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _cameraController;
    if (cameraController == null) return Nil();

    return ValueListenableBuilder<CameraValue>(
      valueListenable: cameraController,
      builder: (context, cameraValue, child) {
        if (!cameraValue.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize = cameraValue.previewSize;
        if (previewSize == null) return Nil();

        final aspectRatio = cameraValue.isLandscape
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
                    child: cameraController.buildPreview(),
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
    return RotatedBox(quarterTurns: cameraValue.quarterTurns, child: child);
  }
}
