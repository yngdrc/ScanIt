import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:scanit/utils/barcode_utils.dart';

class ScanRectangleWidget extends StatelessWidget {
  const ScanRectangleWidget({
    super.key,
    required this.scanWindow,
    required this.barcode,
  });

  final Rect scanWindow;
  final Barcode? barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scanWindow.width / 42,
        vertical: scanWindow.height / 42,
      ),
      width: scanWindow.width,
      height: scanWindow.height,
      decoration: BoxDecoration(
        border: DashedBorder.all(
          color: Colors.white,
          dashLength: scanWindow.shortestSide / 4,
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
