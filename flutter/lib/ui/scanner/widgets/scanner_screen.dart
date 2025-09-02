import 'dart:async';

import 'package:camera/camera.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:nil/nil.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/core/scan_result_dialog.dart';

import 'mobile_scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.viewModel});

  final ScannerViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  ListenableSubscription? _barcodeSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    // _barcodeSubscription = widget.viewModel.barcodeChanges(_onBarcodeChanged);
    unawaited(widget.viewModel.initializeScanner());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeSubscription?.cancel();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(widget.viewModel.disposeCamera());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(widget.viewModel.initializeScanner());
    }
  }

  void _onBarcodeChanged(Barcode? barcode) {
    if (barcode == null) return;

    ScanResultDialog.show(
      context: context,
      barcode: barcode,
      onDismiss: widget.viewModel.clearScanResult,
    );
  }

  Rect _getScanWindow(BoxConstraints constraints) {
    final scanWindowSize = constraints.biggest.shortestSide / 2;
    return Rect.fromCenter(
      center: constraints.biggest.center(Offset.zero),
      width: scanWindowSize,
      height: scanWindowSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ValueListenableBuilder(
          valueListenable: widget.viewModel,
          builder: (_, uiState, _) {
            final cameraController = uiState.cameraController;
            if (cameraController == null) {
              return Nil();
            }

            if (!cameraController.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

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
                      child: uiState.customPaint,
                    ),
                  ),
                ),
                MobileScannerOverlay(
                  constraints: constraints,
                  barcode: null,
                  detectionMode: uiState.detectionMode,
                  onModeSelected: (mode) async {
                    await widget.viewModel.initializeScanner(
                      detectionMode: mode,
                    );
                  },
                  isFlashlightOn:
                      cameraController.value.flashMode == FlashMode.torch,
                  onFlashlightToggle: () async {
                    FlashMode flashMode;
                    switch (cameraController.value.flashMode) {
                      case FlashMode.off:
                        flashMode = FlashMode.torch;
                      case FlashMode.auto:
                      case FlashMode.always:
                      case FlashMode.torch:
                        flashMode = FlashMode.off;
                    }

                    await cameraController.setFlashMode(flashMode);
                  },
                  onCameraSwitch: () async {
                    CameraLensDirection cameraLensDirection;
                    switch (cameraController.value.description.lensDirection) {
                      case CameraLensDirection.back:
                        cameraLensDirection = CameraLensDirection.front;
                      case CameraLensDirection.front:
                      case CameraLensDirection.external:
                        cameraLensDirection = CameraLensDirection.back;
                    }

                    await widget.viewModel.initializeScanner(
                      cameraLensDirection: cameraLensDirection,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
