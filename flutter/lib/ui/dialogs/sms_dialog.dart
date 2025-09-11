import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'core/scan_result_dialog_widgets.dart';

class SmsDialog extends StatelessWidget {
  const SmsDialog({super.key, required this.sms});

  final BarcodeSMS sms;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.sms.name]),
        DialogField(label: 'Number', values: [sms.phoneNumber!]),
        DialogField(label: 'Message', values: [sms.message!]),
      ],
    );
  }
}