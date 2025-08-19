import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../../../domain/models/barcode/barcode_local_model.dart';

class ScannerViewModel {
  ScannerViewModel() {
    saveScanCommand = Command.createAsync(saveScan, initialValue: null);
  }

  final BarcodeRepositoryLocal _barcodeRepository = BarcodeRepositoryLocal(
    databaseService: GetIt.instance.get(),
  );

  late Command<Barcode, Barcode?> saveScanCommand;

  Future<Barcode?> saveScan(Barcode barcode) async {
    final barcodeModel = BarcodeLocalModel.fromBarcode(barcode);
    if (barcodeModel == null) {
      return null;
    }

    return await _barcodeRepository.insertOrReplace(barcodeModel).then((_) {
      return barcode;
    });
  }
}
