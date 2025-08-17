import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:scanit/data/repositories/history/history_repository_local.dart';
import 'package:scanit/utils/result.dart';

import '../../../domain/models/history/history_local_model.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({required HistoryRepositoryLocal historyRepository})
    : _historyRepository = historyRepository;

  final HistoryRepositoryLocal _historyRepository;

  List<HistoryLocalModel> _historyItems = [];
  UnmodifiableListView<HistoryLocalModel> get historyItems =>
      UnmodifiableListView(_historyItems);

  Future<void> loadHistory() async {
    await _historyRepository.getAll().then((result) {
      switch (result) {
        case Ok<List<HistoryLocalModel>>():
          _historyItems = result.value;
          break;
        case Error<List<HistoryLocalModel>>():
          _historyItems = [];
      }
    });

    notifyListeners();
  }
}
