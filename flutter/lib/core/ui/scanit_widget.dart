import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';
import 'package:scanit/core/scanit_controller.dart';
import 'package:scanit/core/ui/scanit_camera_preview.dart';


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
  final Rect Function(Size widgetSize)? onInitializeScanArea;
  final Function(Rect scanArea)? overlayBuilder;
  final void Function(BarcodesDetectedEvent event)? onBarcodesDetected;
  final void Function(TextRecognizedEvent event)? onTextDetected;
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
        BarcodesDetectedEvent() => widget.onBarcodesDetected?.call(event),
        TextRecognizedEvent() => widget.onTextDetected?.call(event),
      },
    );
  }

  void _removeListeners() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void _onCameraInitialized(Size widgetSize) {
    Rect? scanArea = widget.onInitializeScanArea?.call(widgetSize);
    widget._controller.onCameraInitialized(
      scanArea: scanArea,
      widgetSize: widgetSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (_, constraints) {
            return ScanItCameraPreview(
              constraints: constraints,
              onCameraImage:
                  (cameraImage, cameraDescription, deviceOrientation) {
                    widget._controller.onCameraImage(
                      cameraImage: cameraImage,
                      cameraDescription: cameraDescription,
                      deviceOrientation: deviceOrientation,
                    );
                  },
              onCameraInitialized: _onCameraInitialized,
              onCameraDisposed: widget._controller.onCameraDisposed,
              onCameraError: (error) {},
              child: widget.child,
            );
          },
        ),

        ValueListenableBuilder(
          valueListenable: widget._controller,
          builder: (_, scannerState, child) {
            final scanArea = scannerState.scanArea;
            final overlay = scanArea != null
                ? widget.overlayBuilder?.call(scanArea)
                : null;

            return overlay ?? Container();
          },
        ),
      ],
    );
  }
}
