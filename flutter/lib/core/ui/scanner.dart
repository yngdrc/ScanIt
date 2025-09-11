import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/scanit_controller.dart';
import 'package:scanit/core/ui/scanner_preview.dart';

import '../processing/scanit_processor.dart';

typedef ScanWindowInitializer =
    Rect Function({
      required BoxConstraints constraints,
      required Size previewSize,
    });

typedef OnBarcodesDetected =
    void Function({required BarcodesDetectedEvent event});

typedef OnTextDetected = void Function({required TextRecognizedEvent event});

typedef OverlayBuilder =
    Widget? Function({
      required BuildContext context,
      required BoxConstraints constraints,
      required ScanItControllerState scannerState,
    });

class Scanner extends StatefulWidget {
  Scanner({
    super.key,
    ScanItController? controller,
    this.scanWindowInitializer,
    this.overlayBuilder,
    this.child,
    this.onBarcodesDetected,
    this.onTextDetected,
  }) : controller = controller ?? ScanItController();

  final ScanItController controller;
  final ScanWindowInitializer? scanWindowInitializer;
  final OverlayBuilder? overlayBuilder;
  final Widget? child;
  final OnBarcodesDetected? onBarcodesDetected;
  final OnTextDetected? onTextDetected;

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with WidgetsBindingObserver {
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
    if (!widget.controller.value.isCameraControllerInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _disposeListeners();
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
    final scanWindow = widget.scanWindowInitializer?.call(
      constraints: constraints,
      previewSize: previewSize,
    );

    widget.controller.setScanWindow(scanWindow: scanWindow);
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
                ScannerPreview(
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
