
import 'package:flutter/services.dart';

import 'detection_mode.dart';

class ScanItControllerState {
  const ScanItControllerState({
    required this.detectionMode,
    this.scanArea,
    this.widgetSize,
  });

  final DetectionMode detectionMode;
  final Rect? scanArea;
  final Size? widgetSize;

  ScanItControllerState copyWith({
    DetectionMode? detectionMode,
    Rect? scanArea,
    Size? widgetSize,
  }) {
    return ScanItControllerState(
      detectionMode: detectionMode ?? this.detectionMode,
      scanArea: scanArea ?? this.scanArea,
      widgetSize: widgetSize ?? this.widgetSize,
    );
  }
}