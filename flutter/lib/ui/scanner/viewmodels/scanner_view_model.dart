import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../../../domain/models/barcode/barcode_local_model.dart';

class ScannerViewModel {
  ScannerViewModel() {
    saveScanCommand = Command.createAsyncNoResult(saveScan);
  }

  final BarcodeRepositoryLocal _barcodeRepository = BarcodeRepositoryLocal(
    databaseService: GetIt.instance.get(),
  );

  late Command<Barcode, void> saveScanCommand;

  Future<void> saveScan(Barcode barcode) async {
    final barcodeModel = BarcodeLocalModel.fromBarcode(barcode);
    if (barcodeModel == null) {
      return;
    }

    await _barcodeRepository.insertOrReplace(barcodeModel);
  }
}
