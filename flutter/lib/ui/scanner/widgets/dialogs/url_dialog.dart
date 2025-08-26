import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'core/scan_result_dialog_widgets.dart';

class UrlDialog extends StatelessWidget {
  const UrlDialog({super.key, required this.url});

  final UrlBookmark url;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.url.name]),
        DialogField(label: url.title ?? 'Url', values: [url.url]),
      ],
    );
  }
}