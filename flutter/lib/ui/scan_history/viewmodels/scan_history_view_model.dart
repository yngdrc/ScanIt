import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:scanit/data/repositories/barcode/barcode_repository_local.dart';

import '../../../domain/models/barcode/barcode_local_model.dart';

class ScanHistoryViewModel extends ChangeNotifier {
  ScanHistoryViewModel() {
    loadHistoryCommand = Command.createAsyncNoParam(
      _barcodeRepository.getAll,
      initialValue: [],
    )..execute();
  }

  final BarcodeRepositoryLocal _barcodeRepository = BarcodeRepositoryLocal(
    databaseService: GetIt.instance.get(),
  );

  late Command<void, List<BarcodeLocalModel>> loadHistoryCommand;
}
