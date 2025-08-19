import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../../../domain/models/barcode/barcode_local_model.dart';

class ScannerViewModel extends ChangeNotifier {
  ScannerViewModel({
    required BarcodeRepositoryLocal barcodeRepository
  }) : _barcodeRepository = barcodeRepository;

  final BarcodeRepositoryLocal _barcodeRepository;
  Barcode? _barcode;
  Barcode? get barcode => _barcode;

  Future<void> saveScan(Barcode barcode) async {
    _barcode = barcode;
    final barcodeModel = BarcodeLocalModel.fromBarcode(barcode);
    if (barcodeModel == null) {
      return;
    }

    await _barcodeRepository.insertOrReplace(barcodeModel);
    notifyListeners();
  }

  void clearScan() {
    _barcode = null;
    notifyListeners();
  }
}
