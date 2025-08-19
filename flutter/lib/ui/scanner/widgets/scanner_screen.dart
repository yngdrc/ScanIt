import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../../../navigation/navigation_screen.dart';

class ScannerScreen extends StatefulWidget implements NavigationScreen {
  const ScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.fastLinearToSlowEaseIn,
  ).drive(Tween(begin: 1, end: 0.8));

  ScannerViewModel get _viewModel =>
      Provider.of<ScannerViewModel>(context, listen: false);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture barcodeCapture) async {
    if (_viewModel.barcode != null) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode == null) return;

    await _viewModel.saveScan(barcode).then((_) async {
      _animationController.reset();
      await _animationController.repeat(reverse: true, count: 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final Size layoutSize = constraints.biggest;
        final double scanWindowSize = layoutSize.shortestSide / 2;

        return MobileScanner(
          scanWindow: Rect.fromCenter(
            center: layoutSize.center(Offset.zero),
            width: scanWindowSize,
            height: scanWindowSize,
          ),
          controller: MobileScannerController(),
          overlayBuilder: (context, constraints) {
            return _ScanRectangleWidget(
              size: scanWindowSize,
              listener: _animation,
            );
          },
          onDetect: _onDetect,
        );
      },
    );
  }
}

class _ScanRectangleWidget extends AnimatedWidget {
  const _ScanRectangleWidget({
    required this.size,
    required Animation<double> listener,
  }) : super(listenable: listener);

  final double size;

  Animation<double> get _progress => listenable as Animation<double>;

  void _onTap(BuildContext context) {
    Provider.of<ScannerViewModel>(context, listen: false).clearScan();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _progress.value,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: DashedBorder.all(
            color: Colors.white,
            dashLength: size / 8,
            width: 2,
            isOnlyCorner: true,
            strokeCap: StrokeCap.round,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: _createBarcodeWidget(
          context,
          Provider.of<ScannerViewModel>(context, listen: true).barcode,
        ),
      ),
    );
  }

  Widget? _createBarcodeWidget(BuildContext context, Barcode? barcode) {
    final barcodeData = barcode?.rawValue;
    final barcodeType = barcode?.barcodeWidgetType;
    if (barcodeData == null || barcodeType == null) {
      return null;
    }

    return GestureDetector(
      onTap: () => _onTap(context),
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
