import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'core/scan_result_dialog_widgets.dart';

class WifiDialog extends StatelessWidget {
  const WifiDialog({super.key, required this.wifi});

  final WiFi wifi;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.wifi.name]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: DialogField(
                label: 'Network name',
                values: [wifi.ssid!],
              ),
            ),
            Expanded(
              child: DialogField(
                label: 'Password',
                values: [wifi.password!],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
