import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:scanit/data/repositories/barcode/barcode_repository_local.dart';

import '../../../domain/models/barcode/barcode_local_model.dart';

class ScanHistoryViewModel extends ChangeNotifier {
  ScanHistoryViewModel({required BarcodeRepositoryLocal barcodeRepository})
    : _barcodeRepository = barcodeRepository {
    loadHistoryCommand = Command.createAsyncNoParam(
      _barcodeRepository.getAll,
      initialValue: [],
    )..execute();
  }

  final BarcodeRepositoryLocal _barcodeRepository;

  late Command<void, List<BarcodeLocalModel>> loadHistoryCommand;
}
