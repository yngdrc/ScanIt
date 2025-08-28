import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:nil/nil.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/core/scan_result_dialog.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../painters/barcode_detector_painter.dart';
import 'mobile_scanner_detection_mode.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addObserver(this);
    unawaited(
      widget.viewModel.initializeCamera().then((cameraController) async {
        if (!mounted || cameraController == null) return;
        await cameraController.startImageStream((image) async {
          await widget.viewModel.processCameraImage(image);
        });

        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    widget.viewModel.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = widget.viewModel.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      widget.viewModel.clear();
    } else if (state == AppLifecycleState.resumed) {
      unawaited(
        widget.viewModel.initializeCameraController(
          cameraController.description,
        ),
      );
    }
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
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return ValueListenableBuilder(
          valueListenable: cameraController,
          builder: (_, value, _) {
            final size = MediaQuery.of(context).size;
            var scale = size.aspectRatio * cameraController.value.aspectRatio;
            if (scale < 1) scale = 1 / scale;

            return Stack(
              children: [
                // Transform.scale(
                //   scale: scale,
                //   child: Center(child: cameraController.buildPreview()),
                // ),
                CameraPreview(
                  cameraController,
                  child: widget.viewModel.customPaint,
                ),
                // MobileScannerOverlay(
                //   constraints: constraints,
                //   barcode: widget.viewModel.barcode,
                //   detectionMode: widget.viewModel.detectionMode,
                //   onModeSelected: (mode) {},
                //   isFlashlightOn: false,
                //   onFlashlightToggle: () {},
                //   onCameraSwitch: () {},
                // ),
                // _customPaint ?? Column(),
              ],
            );
          },
        );
      },
    );
  }
}
