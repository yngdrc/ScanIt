import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:nil/nil.dart';
import 'package:scanit/ui/scanner/widgets/scanner/scanner_controller.dart';


class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    this.controller,
    this.scanWindowInitializer,
    this.overlayBuilder,
    this.child,
    required this.onBarcodesDetected,
    required this.onTextDetected,
  });

  final ScannerController? controller;
  final Rect Function(BoxConstraints)? scanWindowInitializer;
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ScannerControllerState scannerState,
  )?
  overlayBuilder;

  final Widget? child;

  final void Function(List<Barcode>, InputImage, CameraLensDirection)
  onBarcodesDetected;

  final void Function(RecognizedText, InputImage, CameraLensDirection)
  onTextDetected;

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with WidgetsBindingObserver {
  late final ScannerController _controller;
  StreamSubscription? _barcodesSubscription;
  StreamSubscription? _recognizedTextSubscription;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScannerController();
    WidgetsBinding.instance.addObserver(this);
    _setupListeners();
    unawaited(_controller.initializeScanner());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _disposeListeners();
      unawaited(_controller.disposeCamera());
    } else if (state == AppLifecycleState.resumed) {
      _setupListeners();
      unawaited(_controller.initializeScanner());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeListeners();
    _controller.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _barcodesSubscription = _controller.barcodes.listen((data) {
      widget.onBarcodesDetected(data.$1, data.$2, data.$3);
    });

    _recognizedTextSubscription = _controller.recognizedText.listen((data) {
      widget.onTextDetected(data.$1, data.$2, data.$3);
    });
  }

  void _disposeListeners() {
    _barcodesSubscription?.cancel();
    _recognizedTextSubscription?.cancel();
    _barcodesSubscription = null;
    _recognizedTextSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (_, state, _) {
        return LayoutBuilder(
          builder: (_, constraints) {
            _controller.setScanWindow(
              widget.scanWindowInitializer?.call(constraints),
            );

            final cameraController = _controller.value.cameraController;
            if (cameraController == null) {
              return Nil();
            }

            if (!cameraController.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            final Widget? overlay = widget.overlayBuilder?.call(
              context,
              constraints,
              state,
            );

            try {
              final size = MediaQuery.of(context).size;
              var scale = size.aspectRatio * cameraController.value.aspectRatio;
              if (scale < 1) scale = 1 / scale;

              return Stack(
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Center(
                      child: CameraPreview(
                        cameraController,
                        child: widget.child,
                      ),
                    ),
                  ),
                  ?overlay,
                ],
              );
            } catch (e) {
              return Center(child: Text('Error displaying camera preview: $e'));
            }
          },
        );
      },
    );
  }
}
