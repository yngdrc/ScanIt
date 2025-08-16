import 'package:flutter/material.dart';

import '../../../navigation/navigation_screen.dart';
import '../../../domain/models/history/history_item.dart';

class HistoryScreen extends StatefulWidget implements NavigationScreen {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryItem> _historyItems = List.generate(20, (index) {
    return HistoryItem(
      id: index,
      title: "$index Scan",
      scannedAt: DateTime.now().add(Duration(days: index)),
    );
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: Expanded(
        child: ListView.builder(
          itemCount: _historyItems.length,
          itemBuilder: (context, index) {
            return _HistoryItemWidget(item: _historyItems[index]);
          },
        ),
      ),
    );
  }
}

class _HistoryItemWidget extends StatelessWidget {
  const _HistoryItemWidget({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.scannedAt.toLocal().toString()),
      leading: Icon(Icons.history),
      onTap: () {
        // Handle item tap
      },
    );
  }
}
