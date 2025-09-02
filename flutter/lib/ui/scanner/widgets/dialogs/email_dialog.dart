import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'core/scan_result_dialog_widgets.dart';

class EmailDialog extends StatelessWidget {
  const EmailDialog({super.key, required this.email});

  final BarcodeEmail email;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.email.name]),
        DialogField(label: 'Email address', values: [email.address!]),
        DialogField(label: 'Subject', values: [email.subject!]),
        DialogField(label: 'Body', values: [email.body!]),
      ],
    );
  }
}