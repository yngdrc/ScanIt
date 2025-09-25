import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';
import 'package:scanit/core/scanit_controller.dart';
import 'package:scanit/core/ui/scanit_camera_preview.dart';

import '../processing/scanit_processor.dart';
import '../scanit_controller_state.dart';

/// A function that initializes the scanning area based on the size of the widget.
/// The function takes the size of the widget as a parameter and returns a [Rect]
typedef ScanAreaInitializer = Rect Function({required Size widgetSize});

typedef OnBarcodesDetected =
    void Function({required BarcodesDetectedEvent event});

typedef OnTextDetected = void Function({required TextRecognizedEvent event});

typedef OverlayBuilder =
    Widget? Function({
      required BuildContext context,
      required BoxConstraints constraints,
      required ScanItControllerState scannerState,
    });

class ScanItWidget extends StatefulWidget {
  ScanItWidget({
    super.key,
    ScanItController? controller,
    this.scanAreaInitializer,
    this.overlayBuilder,
    this.child,
    this.onBarcodesDetected,
    this.onTextDetected,
  }) : controller = controller ?? ScanItController();

  final ScanItController controller;
  final ScanAreaInitializer? scanAreaInitializer;
  final OverlayBuilder? overlayBuilder;
  final Widget? child;
  final OnBarcodesDetected? onBarcodesDetected;
  final OnTextDetected? onTextDetected;

  @override
  State<StatefulWidget> createState() => _ScanItWidgetState();
}

class _ScanItWidgetState extends State<ScanItWidget>
    with WidgetsBindingObserver {
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupListeners();
    unawaited(widget.controller.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _disposeListeners();

      if (!widget.controller.value.isCameraControllerInitialized) return;
      unawaited(widget.controller.disposeCamera());
    } else if (state == AppLifecycleState.resumed) {
      _setupListeners();
      unawaited(widget.controller.initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeListeners();
    widget.controller.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _eventSubscription = widget.controller.eventStream.listen(
      (event) => switch (event) {
        BarcodesDetectedEvent() => widget.onBarcodesDetected?.call(event: event),
        TextRecognizedEvent() => widget.onTextDetected?.call(event: event),
      },
    );
  }

  void _disposeListeners() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Calls the [ScanAreaInitializer] (if provided) to get the scan area
  /// and notifies the controller that the camera preview is ready.
  /// The max bounds of the scan area is the size of the widget.
  void _onPreviewReady({
    required Size widgetSize,
    required Size previewSize,
    required CameraDescription cameraDescription,
    required DeviceOrientation deviceOrientation,
  }) {
    final bounds = Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height);
    final scanArea = widget.scanAreaInitializer
        ?.call(widgetSize: widgetSize)
        .intersect(bounds);

    widget.controller.onPreviewReady(
      scanArea: scanArea ?? bounds,
      widgetSize: widgetSize,
      previewSize: previewSize,
      cameraDescription: cameraDescription,
      deviceOrientation: deviceOrientation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, scannerState, child) {
        final cameraController = scannerState.cameraController;
        if (cameraController == null) return Nil();

        return LayoutBuilder(
          builder: (_, constraints) {
            final Widget? overlay = widget.overlayBuilder?.call(
              context: context,
              constraints: constraints,
              scannerState: scannerState,
            );

            return Stack(
              children: [
                ScanItCameraPreview(
                  cameraController: cameraController,
                  constraints: constraints,
                  onPreviewReady: _onPreviewReady,
                  child: child,
                ),
                ?overlay,
              ],
            );
          },
        );
      },
      child: widget.child,
    );
  }
}
