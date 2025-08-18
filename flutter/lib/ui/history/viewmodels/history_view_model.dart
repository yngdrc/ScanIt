
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:scanit/data/repositories/history/history_repository_local.dart';

import '../../../domain/models/history/history_local_model.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({required HistoryRepositoryLocal historyRepository})
    : _historyRepository = historyRepository {
    loadHistoryCommand = Command.createAsyncNoParam(
      _historyRepository.getAll,
      initialValue: [],
    )..execute();
  }

  final HistoryRepositoryLocal _historyRepository;
  late Command<void, List<HistoryLocalModel>> loadHistoryCommand;
}
