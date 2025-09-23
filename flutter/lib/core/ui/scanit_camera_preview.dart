import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

typedef OnPreviewReady =
    void Function({
      required Size widgetSize,
      required Size previewSize,
      required CameraDescription cameraDescription,
      required DeviceOrientation deviceOrientation,
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
  ValueListenable<(Size?, DeviceOrientation)> get _previewReadyListenable =>
      widget.cameraController.valueListenableCombiner(
        (cameraValue) =>
            (cameraValue.previewSize, cameraValue.deviceOrientation),
      );

  ListenableSubscription? _previewReadySubscription;

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

  void _setupListeners() {
    _previewReadySubscription = _previewReadyListenable.listen((data, _) {
      final (previewSize, deviceOrientation) = data;
      if (previewSize == null) return;

      widget.onPreviewReady?.call(
        widgetSize: widget.constraints.biggest,
        previewSize: previewSize,
        cameraDescription: widget.cameraController.description,
        deviceOrientation: deviceOrientation,
      );
    });
  }

  void _disposeListeners() {
    _previewReadySubscription?.cancel();
    _previewReadySubscription = null;
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
    return RotatedBox(quarterTurns: cameraValue.quarterTurns, child: child);
  }
}
