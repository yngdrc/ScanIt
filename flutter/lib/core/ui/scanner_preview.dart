
import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';

typedef OnPreviewReady =
    void Function({
      required BoxConstraints constraints,
      required Size previewSize,
    });

class ScannerPreview extends StatefulWidget {
  const ScannerPreview({
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
  State<StatefulWidget> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<ScannerPreview>
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

  void _setupListeners() {
    if (widget.onPreviewReady != null) {
      _previewSizeSubscription = widget.cameraController
          .select((cameraValue) => cameraValue.previewSize)
          .listen((previewSize, _) {
            if (previewSize == null) return;
            widget.onPreviewReady?.call(
              constraints: widget.constraints,
              previewSize: previewSize,
            );
          });
    }
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
            widget.constraints.biggest.longestSide / previewSize.shortestSide;

        return Transform.scale(
          scale: scale,
          child: Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
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
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

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
