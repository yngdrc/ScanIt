import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:nil/nil.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';
import 'package:scanit/core/scanit_controller.dart';
import 'package:scanit/core/ui/scanit_camera_preview.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import '../processing/scanit_processor.dart';
import '../scanit_controller_state.dart';
import '../utils/scanit_utils.dart';

class ScanItWidget extends StatefulWidget {
  ScanItWidget({
    super.key,
    ScanItController? controller,
    this.onInitializeScanArea,
    this.overlayBuilder,
    this.onBarcodesDetected,
    this.onTextDetected,
    this.child,
  }) : _controller = controller ?? ScanItController();

  final ScanItController _controller;
  final Rect Function({required Size widgetSize})? onInitializeScanArea;
  final Function({required Rect scanArea})? overlayBuilder;

  final void Function({required BarcodesDetectedEvent event})?
  onBarcodesDetected;

  final void Function({required TextRecognizedEvent event})? onTextDetected;
  final Widget? child;

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _removeListeners();
    } else if (state == AppLifecycleState.resumed) {
      _setupListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeListeners();
    widget._controller.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _eventSubscription = widget._controller.eventStream.listen(
      (event) => switch (event) {
        BarcodesDetectedEvent() => widget.onBarcodesDetected?.call(
          event: event,
        ),
        TextRecognizedEvent() => widget.onTextDetected?.call(event: event),
      },
    );
  }

  void _removeListeners() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void _onCameraInitialized({
    required Size widgetSize,
    required CameraController cameraController,
  }) {
    Rect? scanArea = widget.onInitializeScanArea?.call(widgetSize: widgetSize);
    widget._controller.onCameraInitialized(
      scanArea: scanArea,
      widgetSize: widgetSize,
      cameraController: cameraController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget._controller,
      builder: (_, scannerState, child) {
        final scanArea = scannerState.scanArea;
        final overlay = scanArea != null
            ? widget.overlayBuilder?.call(scanArea: scanArea)
            : null;

        return Stack(
          children: [
            LayoutBuilder(
              builder: (_, constraints) {
                return ScanItCameraPreview(
                  onCameraInitialized: (cameraController) {
                    _onCameraInitialized.call(
                      widgetSize: constraints.biggest,
                      cameraController: cameraController,
                    );
                  },
                  onCameraDisposed: widget._controller.onCameraDisposed,
                  onCameraError: (error) {},
                  child: child,
                );
              },
            ),
            ?overlay,
          ],
        );
      },
      child: widget.child,
    );
  }
}
