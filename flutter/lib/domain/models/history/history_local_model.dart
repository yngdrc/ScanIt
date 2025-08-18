import 'package:uuid/uuid.dart';

import '../core/local_model.dart';

class HistoryLocalModel implements LocalModel {
  const HistoryLocalModel({
    required this.uuid,
    required this.barcodeData,
    required this.scannedAtMillis,
  });

  @override
  final UuidValue uuid;

  final String barcodeData;
  final int scannedAtMillis;

  HistoryLocalModel.fromJson(Map<String, dynamic> json)
    : uuid = UuidValue.fromString(json['uuid'] as String),
      barcodeData = json['barcodeData'] as String,
      scannedAtMillis = json['scannedAtMillis'] as int;

  Map<String, dynamic> toJson() => {
    'uuid': uuid.toString(),
    'barcodeData': barcodeData,
    'scannedAtMillis': scannedAtMillis,
  };
}
