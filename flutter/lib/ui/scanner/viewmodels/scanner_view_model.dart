import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/ui/scanner/viewmodels/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/mobile_scanner_detection_mode.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../widgets/dialogs/core/scan_result_dialog.dart';

class ScannerViewModel extends ChangeNotifier {
  ScannerViewModel();

  CameraController? _cameraController;

  CameraController? get cameraController => _cameraController;

  final CameraProcessor _cameraProcessor = CameraProcessor();
  List<CameraDescription> _cameras = [];

  Barcode? _barcode;

  Barcode? get barcode => _barcode;

  final DetectionMode _detectionMode = DetectionMode.barcode;

  DetectionMode get detectionMode => _detectionMode;

  CustomPaint? _customPaint;

  CustomPaint? get customPaint => _customPaint;

  Future<CameraController?> initializeCamera({
    CameraDescription? cameraDescription,
  }) async {
    try {
      final currentCameraController = _cameraController;

      if (cameraDescription == null) {
        final cameras = await availableCameras();
        _cameras = cameras;
        if (cameras.isEmpty) return null;

        cameraDescription = cameras.firstWhere(
          (camera) => currentCameraController == null
              ? camera.lensDirection == CameraLensDirection.back
              : camera.lensDirection ==
                    currentCameraController.description.lensDirection,
          orElse: () => cameras.first,
        );
      }

      final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController
          .initialize()
          .then(
            (_) {
              _cameraController = cameraController;
            },
            onError: (_) {
              _cameraController = null;
            },
          )
          .whenComplete(() {
            _cameraProcessor.dispose();

            if (currentCameraController?.value.isStreamingImages == true) {
              currentCameraController?.stopImageStream();
            }

            currentCameraController?.dispose();
            notifyListeners();
          });

      return cameraController;
    } on CameraException {
      return null;
    }
  }

  Future<void> startImageStream(
    CameraController cameraController,
    Function(Barcode) onImageProcessed,
  ) async {
    await cameraController.startImageStream((image) async {
      await _processCameraImage(image, (barcode) async {
        await cameraController.stopImageStream();
        onImageProcessed(barcode);
      });
    });
  }

  Future<void> stopImageStream(CameraController cameraController) async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }
  }

  Future<void> _processCameraImage(
    CameraImage image,
    Function(Barcode) onImageProcessed,
  ) async {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    await _cameraProcessor.processImage(cameraController, image).then((data) {
      if (data == null) return;

      final barcodes = data.$1;
      if (barcodes.isEmpty) return;

      final inputImage = data.$2;

      _barcode = barcodes.first;
      notifyListeners();

      onImageProcessed(barcodes.first);
    });
  }

  void clearBarcode() {
    _barcode = null;
    notifyListeners();
  }

  Future<void> clear() async {
    _cameraProcessor.dispose();

    final cameraController = _cameraController;
    if (cameraController?.value.isStreamingImages == true) {
      await cameraController?.stopImageStream();
    }

    await cameraController?.dispose();
  }
}
