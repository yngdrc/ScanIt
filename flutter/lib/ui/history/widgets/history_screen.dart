import 'package:flutter/material.dart';
import 'package:scanit/ui/history/viewmodels/history_view_model.dart';

import '../../../navigation/navigation_screen.dart';
import '../../../domain/models/history/history_local_model.dart';

class HistoryScreen extends StatelessWidget implements NavigationScreen {
  const HistoryScreen({super.key, required this.viewModel});

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: viewModel.loadHistory(),
      builder: (context, snapshot) {
        return MediaQuery(
          data: MediaQuery.of(context).removePadding(removeTop: true),
          child: Expanded(
            child: ListView.builder(
              itemCount: viewModel.historyItems.length,
              itemBuilder: (context, index) {
                return _HistoryItemWidget(item: viewModel.historyItems[index]);
              },
            ),
          ),
        );
      },
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
