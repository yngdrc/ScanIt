import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:uuid/uuid.dart';

import '../core/local_model.dart';

class BarcodeLocalModel implements LocalModel {
  BarcodeLocalModel({
    required this.uuid,
    required this.scannedAtMillis,
    required this.barcodeData,
    this.barcodeType = BarcodeType.unknown,
    this.barcodeFormat = BarcodeFormat.unknown,
  });

  @override
  final UuidValue uuid;
  final int scannedAtMillis;

  final String barcodeData;
  final BarcodeType barcodeType;
  final BarcodeFormat barcodeFormat;

  BarcodeLocalModel.fromJson(Map<String, dynamic> json)
    : uuid = UuidValue.fromString(json['uuid'] as String),
      scannedAtMillis = json['scannedAtMillis'] as int,
      barcodeData = json['barcodeData'] as String,
      barcodeType = BarcodeType.values.elementAt(json['barcodeType'] as int),
      barcodeFormat = BarcodeFormat.values.elementAt(
        json['barcodeFormat'] as int,
      );

  static BarcodeLocalModel? fromBarcode(Barcode barcode) {
    final barcodeData = barcode.rawValue;
    if (barcodeData == null || barcodeData.isEmpty) {
      return null;
    }

    return BarcodeLocalModel(
      uuid: UuidValue.fromString(barcodeData),
      scannedAtMillis: DateTime.now().millisecondsSinceEpoch,
      barcodeData: barcodeData,
      barcodeType: barcode.type,
      barcodeFormat: barcode.format,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid.toString(),
    'scannedAtMillis': scannedAtMillis,
    'barcodeData': barcodeData,
    'barcodeType': barcodeType.index,
    'barcodeFormat': barcodeFormat.rawValue,
  };

  static String createTableSql() {
    return '''
    CREATE TABLE barcode(
      uuid TEXT PRIMARY KEY,
      scannedAtMillis INTEGER NOT NULL,
      barcodeData TEXT NOT NULL,
      barcodeType INTEGER NOT NULL,
      barcodeFormat INTEGER NOT NULL
    )
  ''';
  }
}
