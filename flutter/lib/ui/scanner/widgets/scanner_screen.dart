import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/core/scan_result_dialog.dart';
import 'package:scanit/utils/barcode_utils.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.viewModel});

  final ScannerViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Future<void> _onDetect(
    BuildContext context,
    BarcodeCapture barcodeCapture,
  ) async {
    if (widget.viewModel.barcode != null) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode == null) return;

    await widget.viewModel.saveScan(barcode).then((_) async {
      if (!context.mounted) return;
      await ScanResultDialog.show(
        context: context,
        barcode: barcode,
        onDismiss: widget.viewModel.clearScan,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return MobileScanner(
          scanWindow: _getScanWindow(constraints),
          controller: widget.viewModel.scannerController,
          onDetect: (barcodeCapture) {
            _onDetect(context, barcodeCapture);
          },
          overlayBuilder: (_, constraints) => ValueListenableBuilder(
            valueListenable: widget.viewModel.scannerController,
            builder: (context, data, child) {
              return _MobileScannerOverlay(
                constraints: constraints,
                barcode: widget.viewModel.barcode,
                isFlashlightOn: data.torchState == TorchState.on,
                onFlashlightToggle:
                    widget.viewModel.scannerController.toggleTorch,
                onCameraSwitch: widget.viewModel.scannerController.switchCamera,
              );
            },
          ),
        );
      },
    );
  }
}

class _MobileScannerOverlay extends StatelessWidget {
  _MobileScannerOverlay({
    required this.constraints,
    required this.barcode,
    required this.isFlashlightOn,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
  });

  final BoxConstraints constraints;
  final Barcode? barcode;
  final bool isFlashlightOn;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraSwitch;

  final ConstraintId scannerControlsId = ConstraintId('scannerControlsId');
  final ConstraintId scanRectangleId = ConstraintId('scanRectangleId');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: const _MobileScannerClipper(),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        ConstraintLayout(
          childConstraints: [
            Constraint(
              id: scannerControlsId,
              left: parent.left,
              top: parent.top,
              right: parent.right,
              bottom: scanRectangleId.top,
              verticalBias: 0,
            ),
            Constraint(
              id: scanRectangleId,
              left: parent.left,
              top: parent.top,
              right: parent.right,
              bottom: parent.bottom,
            ),
          ],
          children: [
            SafeArea(
              left: false,
              right: false,
              bottom: false,
              child: _ScannerControls(
                isFlashlightOn: isFlashlightOn,
                onFlashlightToggle: onFlashlightToggle,
                onCameraSwitch: onCameraSwitch,
              ),
            ).applyConstraintId(id: scannerControlsId),
            _ScanRectangleWidget(
              constraints: constraints,
              barcode: barcode,
            ).applyConstraintId(id: scanRectangleId),
          ],
        ),
      ],
    );
  }
}

class _MobileScannerClipper extends CustomClipper<Path> {
  const _MobileScannerClipper();

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double scanWindowSize = size.shortestSide / 2.1;

    final centerRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTWH(0, 0, width, height))
        ..close(),
      Path()
        ..addRRect(RRect.fromRectAndRadius(centerRect, Radius.circular(2)))
        ..close(),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ScanRectangleWidget extends StatelessWidget {
  const _ScanRectangleWidget({
    required this.constraints,
    required this.barcode,
  });

  final BoxConstraints constraints;
  final Barcode? barcode;

  double get size => constraints.biggest.shortestSide / 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(constraints.biggest.shortestSide / 84),
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: DashedBorder.all(
          color: Colors.white,
          dashLength: size / 4,
          width: 3,
          isOnlyCorner: true,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: _createBarcodeWidget(context, barcode),
    );
  }

  Widget? _createBarcodeWidget(BuildContext context, Barcode? barcode) {
    final barcodeData = barcode?.rawValue;
    final barcodeType = barcode?.barcodeWidgetType;
    if (barcodeData == null || barcodeType == null) {
      return null;
    }

    return Hero(
      tag: 'barcode_hero',
      child: barcode_widget.BarcodeWidget(
        data: barcodeData,
        barcode: barcode_widget.Barcode.fromType(barcodeType),
        padding: EdgeInsets.all(10),
        backgroundColor: Colors.white,
        color: Colors.black,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class _ScannerControls extends StatelessWidget {
  const _ScannerControls({
    required this.isFlashlightOn,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
  });

  final bool isFlashlightOn;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraSwitch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _createControlButton(
          icon: isFlashlightOn ? Symbols.flashlight_on : Symbols.flashlight_off,
          isSelected: isFlashlightOn,
          onPressed: onFlashlightToggle,
        ),
        _createControlButton(
          icon: Symbols.cameraswitch,
          isSelected: false,
          onPressed: onCameraSwitch,
        ),
      ],
    );
  }

  Widget _createControlButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.1),
            child: Icon(icon, size: 24, color: Colors.white, weight: 300),
          ),
        ),
      ),
    );
  }
}
