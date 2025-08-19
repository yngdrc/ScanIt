import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:mobile_scanner/mobile_scanner.dart';

extension BarcodeExtension on Barcode {
  barcode_widget.BarcodeType? get barcodeWidgetType {
    switch (format) {
      case BarcodeFormat.code128:
        return barcode_widget.BarcodeType.Code128;
      case BarcodeFormat.code39:
        return barcode_widget.BarcodeType.Code39;
      case BarcodeFormat.code93:
        return barcode_widget.BarcodeType.Code93;
      case BarcodeFormat.codabar:
        return barcode_widget.BarcodeType.Codabar;
      case BarcodeFormat.dataMatrix:
        return barcode_widget.BarcodeType.DataMatrix;
      case BarcodeFormat.ean13:
        return barcode_widget.BarcodeType.CodeEAN13;
      case BarcodeFormat.ean8:
        return barcode_widget.BarcodeType.CodeEAN8;
      case BarcodeFormat.itf:
        return barcode_widget.BarcodeType.Itf;
      case BarcodeFormat.qrCode:
        return barcode_widget.BarcodeType.QrCode;
      case BarcodeFormat.upcA:
        return barcode_widget.BarcodeType.CodeUPCA;
      case BarcodeFormat.upcE:
        return barcode_widget.BarcodeType.CodeUPCE;
      case BarcodeFormat.pdf417:
        return barcode_widget.BarcodeType.PDF417;
      case BarcodeFormat.aztec:
        return barcode_widget.BarcodeType.Aztec;
      default:
        return null;
    }
  }
}
