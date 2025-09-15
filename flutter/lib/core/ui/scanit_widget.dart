import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/scanit_controller.dart';
import 'package:scanit/core/ui/scanit_camera_preview.dart';

import '../processing/scanit_processor.dart';

typedef ScanAreaInitializer = Rect Function({required Rect bounds});

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
  StreamSubscription? _barcodesSubscription;
  StreamSubscription? _recognizedTextSubscription;

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
    _barcodesSubscription = widget.controller.barcodesStream.listen(
      (event) => widget.onBarcodesDetected?.call(event: event),
    );

    _recognizedTextSubscription = widget.controller.ocrStream.listen(
      (event) => widget.onTextDetected?.call(event: event),
    );
  }

  void _disposeListeners() {
    _barcodesSubscription?.cancel();
    _recognizedTextSubscription?.cancel();
    _barcodesSubscription = null;
    _recognizedTextSubscription = null;
  }

  void _onPreviewReady({
    required BoxConstraints constraints,
    required Size previewSize,
  }) {
    final size = constraints.biggest;
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanArea = widget.scanAreaInitializer?.call(bounds: bounds);
    widget.controller.setScanArea(
      scanArea: scanArea?.intersect(bounds) ?? bounds,
      bounds: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, scannerState, child) {
        final cameraController = scannerState.cameraController;
        if (cameraController == null) {
          return Nil();
        }

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
