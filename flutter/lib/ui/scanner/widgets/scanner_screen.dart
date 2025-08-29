import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    unawaited(
      widget.viewModel.initializeCamera().then((cameraController) async {
        if (!mounted || cameraController == null) return;

        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.viewModel.clear());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(widget.viewModel.clear());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(widget.viewModel.initializeCamera());
    }
  }

  Future<void> startImageStream(CameraController cameraController) async {
    await widget.viewModel.startImageStream(cameraController, (barcode) async {
      if (!mounted) return;
      await ScanResultDialog.show(
        context: context,
        barcode: barcode,
        onDismiss: () async {
          widget.viewModel.clearBarcode();
          await startImageStream(cameraController);
        },
      );
    });
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
    return _buildCameraPreview();
  }

  Widget _buildCameraPreview() {
    final cameraController = widget.viewModel.cameraController;
    if (cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return ValueListenableBuilder(
          valueListenable: cameraController,
          builder: (_, value, _) {
            if (!value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            final size = MediaQuery.of(context).size;
            var scale = size.aspectRatio * cameraController.value.aspectRatio;
            if (scale < 1) scale = 1 / scale;

            return Stack(
              children: [
                Transform.scale(
                  scale: scale,
                  child: Center(child: CameraPreview(cameraController)),
                ),
                MobileScannerOverlay(
                  constraints: constraints,
                  barcode: widget.viewModel.barcode,
                  detectionMode: widget.viewModel.detectionMode,
                  onModeSelected: (mode) {},
                  isFlashlightOn: false,
                  onFlashlightToggle: () {},
                  onCameraSwitch: () {},
                ),
              ],
            );
          },
        );
      },
    );
  }
}
