import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/barcode/barcode_local_model.dart';
import '../../../navigation/navigation_screen.dart';
import '../viewmodels/scan_history_view_model.dart';

class ScanHistoryScreen extends StatefulWidget implements NavigationScreen {
  const ScanHistoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  ScanHistoryViewModel get _viewModel =>
      Provider.of<ScanHistoryViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _viewModel.loadHistoryCommand.executeWithFuture(),
      child: CommandBuilder(
        command: _viewModel.loadHistoryCommand,
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
            return _ScanHistoryItemWidget(item: data[index]);
          },
        ),
      ),
    );
  }
}

class _ScanHistoryItemWidget extends StatelessWidget {
  const _ScanHistoryItemWidget({required this.item});

  final BarcodeLocalModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: null, // TODO icon based on barcode type / barcode format
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.barcodeFormat.name),
          Text(item.barcodeData.toString()),
        ],
      ),
      subtitle: Text(
        DateTime.fromMillisecondsSinceEpoch(
          item.scannedAtMillis,
        ).toLocal().toString(),
      ),
      onTap: () {
        // TODO show QR / barcode image with sharing options
      },
    );
  }
}
