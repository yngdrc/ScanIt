import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanit/ui/camera/viewmodels/camera_view_model.dart';

import '../../../navigation/navigation_screen.dart';

class CameraScreen extends StatelessWidget implements NavigationScreen {
  const CameraScreen({super.key, required this.viewModel});

  final CameraViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
      onDetect: (barcodeCapture) {
        final scanData = barcodeCapture.barcodes.firstOrNull?.rawValue;
        if (scanData == null) {
          return;
        }

        viewModel.saveScanCommand.execute(scanData);
      },
    );
  }
}
