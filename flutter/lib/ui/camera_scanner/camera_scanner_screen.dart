import 'package:flutter/material.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import '../../core/processing/scanit_processor_event.dart';
import '../../core/scanit_controller.dart';
import '../../core/ui/scanit_widget.dart';
import 'camera_scanner_overlay.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  final ScanItController _scanItController = ScanItController();
  CustomPaint? _customPaint;

  Rect _initializeScanArea(Size widgetSize) {
    final scanAreaSize = widgetSize.shortestSide / 2;
    return Rect.fromLTWH(100, 200, scanAreaSize, scanAreaSize);
  }

  Widget _buildOverlay(Rect scanArea) {
    return ScanItCameraOverlay(scanArea: scanArea);
  }

  void _setCustomPaint(ScanItProcessorEvent event) {
    final painter = event.painter;
    final customPaint = painter != null ? CustomPaint(painter: painter) : null;
    setState(() => _customPaint = customPaint);
  }

  @override
  Widget build(BuildContext context) {
    return ScanItWidget(
      controller: _scanItController,
      onInitializeScanArea: _initializeScanArea,
      overlayBuilder: _buildOverlay,
      onBarcodesDetected: _setCustomPaint,
      onTextDetected: _setCustomPaint,
      child: _customPaint,
    );
  }
}
