import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:scanit/ui/history/viewmodels/history_view_model.dart';

import '../../../navigation/navigation_screen.dart';
import '../../../domain/models/history/history_local_model.dart';

class HistoryScreen extends StatelessWidget implements NavigationScreen {
  HistoryScreen({super.key, required this.viewModel}) {
    viewModel.loadHistoryCommand.execute();
  }

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: CommandBuilder(
        command: viewModel.loadHistoryCommand,
        whileExecuting: (_, _, _) => Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(),
          ),
        ),
        onError: (_, error, _, _) => Text(error.toString()),
        onData: (_, data, _) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return _HistoryItemWidget(item: data[index]);
          },
        ),
      ),
      onRefresh: () => viewModel.loadHistoryCommand.executeWithFuture(),
    );
  }
}

class _HistoryItemWidget extends StatelessWidget {
  const _HistoryItemWidget({required this.item});

  final HistoryLocalModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title.toString()),
      subtitle: Text(
        DateTime.fromMillisecondsSinceEpoch(
          item.scannedAtMillis,
        ).toLocal().toString(),
      ),
      leading: Icon(Icons.history),
      onTap: () {
        // Handle item tap
      },
    );
  }
}
