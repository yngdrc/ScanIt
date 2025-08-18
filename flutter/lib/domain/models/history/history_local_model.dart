import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../core/local_model.dart';

class HistoryLocalModel implements LocalModel {
  const HistoryLocalModel({
    required this.uuid,
    required this.barcodeData,
    required this.barcodeType,
    required this.scannedAtMillis,
  });

  @override
  final UuidValue uuid;

  final String barcodeData;
  final String barcodeType;
  final int scannedAtMillis;

  HistoryLocalModel.fromJson(Map<String, dynamic> json)
    : uuid = UuidValue.fromString(json['uuid'] as String),
      barcodeData = json['barcodeData'] as String,
      barcodeType = json['barcodeType'] as String,
      scannedAtMillis = json['scannedAtMillis'] as int;

  HistoryLocalModel.fromBarcode(Barcode barcode)
    : uuid = UuidValue.fromString(barcode.rawValue ?? ''),
      barcodeData = barcode.rawValue ?? '',
      barcodeType = barcode.type.name,
      scannedAtMillis = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
    'uuid': uuid.toString(),
    'barcodeData': barcodeData,
    'scannedAtMillis': scannedAtMillis,
  };
}
