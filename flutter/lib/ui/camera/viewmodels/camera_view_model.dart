import '../../../data/repositories/history/history_repository_local.dart';
import '../../../domain/models/history/history_local_model.dart';

class CameraViewModel {
  CameraViewModel({required HistoryRepositoryLocal historyRepository})
      : _historyRepository = historyRepository;

  final HistoryRepositoryLocal _historyRepository;

  Future<void> saveScan(String scanData) async {
    final historyItem = HistoryLocalModel(
      id: 0,
      title: scanData,
      scannedAtMillis: DateTime.now().millisecond,
    );

    // Save the history item using the repository
    await _historyRepository.insertOrReplace(historyItem);
  }
}