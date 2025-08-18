import 'package:command_it/command_it.dart';

import '../../../data/repositories/history/history_repository_local.dart';
import '../../../domain/models/history/history_local_model.dart';

class CameraViewModel {
  CameraViewModel({required HistoryRepositoryLocal historyRepository})
    : _historyRepository = historyRepository {
    saveScanCommand = Command.createAsync(saveScan, initialValue: null);
  }

  final HistoryRepositoryLocal _historyRepository;
  late Command<String, int?> saveScanCommand;

  Future<int> saveScan(String scanData) async {
    final historyItem = HistoryLocalModel(
      id: 0,
      title: scanData,
      scannedAtMillis: DateTime.now().millisecond,
    );

    return await _historyRepository.insertOrReplace(historyItem);
  }
}
