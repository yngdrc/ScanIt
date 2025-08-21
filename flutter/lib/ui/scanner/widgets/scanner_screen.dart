import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/ui/scanner/widgets/scan_result_widget.dart';
import 'package:scanit/utils/barcode_utils.dart';

import 'mobile_scanner_mask.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.viewModel,
    required this.bottomNavigationBarKey,
  });

  final ScannerViewModel viewModel;
  final GlobalKey bottomNavigationBarKey;

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture barcodeCapture) async {
    if (widget.viewModel.barcode != null) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode == null) return;

    await widget.viewModel.saveScan(barcode).then((_) async {
      _animationController.reset();
      await _animationController.repeat(reverse: true, count: 2);
    });
  }

  void _clearScan() {
    widget.viewModel.clearScan();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final navbarRenderBox =
            widget.bottomNavigationBarKey.currentContext?.findRenderObject()
                as RenderBox?;

        final navbarPosition = navbarRenderBox?.localToGlobal(Offset.zero);
        final layoutSize = constraints.biggest;
        final scanWindowSize = layoutSize.shortestSide / 2;
        final scanWindow = Rect.fromCenter(
          center: layoutSize.center(Offset.zero),
          width: scanWindowSize,
          height: scanWindowSize,
        );

        return Stack(
          children: [
            MobileScanner(
              scanWindow: scanWindow,
              controller: MobileScannerController(),
              onDetect: _onDetect,
            ),
            MobileScannerMask(),
            Container(
              alignment: Alignment.center,
              child: _ScanRectangleWidget(
                size: scanWindowSize,
                padding: EdgeInsets.all(
                  (scanWindowSize - (layoutSize.shortestSide / 2.1)) / 2,
                ),
                barcode: widget.viewModel.barcode,
                listener: _animation,
              ),
            ),

            if (widget.viewModel.barcode != null)
              Positioned(
                left: layoutSize.center(Offset.zero).dx - (48 / 2),
                top: scanWindow.bottom + 16,
                child: IconButton.filled(
                  color: Colors.black,
                  onPressed: _clearScan,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(48, 48),
                  ),
                  icon: Icon(Symbols.clear),
                ),
              ),

            if (widget.viewModel.barcode != null)
              Positioned(
                left: layoutSize.center(Offset.zero).dx - (260 / 2),
                width: 260,
                top: (navbarPosition?.dy ?? 0) - 85,
                height: 85,
                child: ScanResultWidget(
                  barcode: widget.viewModel.barcode!,
                  onTap: () {
                    // TODO navigate to scan details
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ScanRectangleWidget extends AnimatedWidget {
  const _ScanRectangleWidget({
    required this.size,
    required this.padding,
    required this.barcode,
    required Animation<double> listener,
  }) : super(listenable: listener);

  final double size;
  final EdgeInsets padding;
  final Barcode? barcode;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding,
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

    return barcode_widget.BarcodeWidget(
      data: barcodeData,
      barcode: barcode_widget.Barcode.fromType(barcodeType),
      padding: EdgeInsets.all(10),
      backgroundColor: Colors.white,
      color: Colors.black,
      style: TextStyle(color: Colors.black),
    );
  }
}
