import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'core/scan_result_dialog_widgets.dart';

class PhoneDialog extends StatelessWidget {
  const PhoneDialog({super.key, required this.phone});

  final Phone phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.phone.name]),
        DialogField(label: 'Phone', values: [phone.number!]),
      ],
    );
  }
}