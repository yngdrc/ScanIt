import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanit/plugins/converter_plugin.dart';
import 'package:scanit/ui/scanner/viewmodels/camera_processor.dart';
import 'package:scanit/ui/scanner/widgets/mobile_scanner_detection_mode.dart';

import '../../../data/repositories/barcode/barcode_repository_local.dart';
import '../../../domain/models/barcode/barcode_local_model.dart';
import '../painters/barcode_detector_painter.dart';

class ScannerViewModel extends ChangeNotifier {
  ScannerViewModel({required BarcodeRepositoryLocal barcodeRepository})
    : _barcodeRepository = barcodeRepository;

  CameraController? _cameraController;
  final CameraProcessor _cameraProcessor = CameraProcessor();

  CameraController? get cameraController => _cameraController;

  List<CameraDescription> _cameras = [];

  List<CameraDescription> get cameras => _cameras;
  int _cameraIndex = -1;

  int get cameraIndex => _cameraIndex;

  final BarcodeRepositoryLocal _barcodeRepository;
  Barcode? _barcode;

  Barcode? get barcode => _barcode;
  DetectionMode _detectionMode = DetectionMode.ocr;

  DetectionMode get detectionMode => _detectionMode;

  CustomPaint? _customPaint;

  CustomPaint? get customPaint => _customPaint;

  Future<CameraController?> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      return await initializeCameraController(_cameras.first);
    } on CameraException catch (e) {
      return null;
    }
  }

  Future<CameraController?> initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    _cameraIndex = cameras.indexOf(cameraDescription);
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _cameraController = cameraController;

    try {
      return await cameraController.initialize().then((_) {
        return cameraController;
      });
    } on CameraException catch (e) {
      return null;
    }
  }

  Future<void> processCameraImage(CameraImage image) async {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    final cameraIndex = _cameraIndex;
    final cameras = _cameras;
    if (cameras.isEmpty || cameraIndex < 0) return;
    final cameraDescription = cameras[cameraIndex];

    await _cameraProcessor.processImage(
      cameraController,
      cameraDescription,
      image
    ).then((data) {
      if (data == null) return;
      final barcodes = data.$1;
      final inputImage = data.$2;

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = BarcodeDetectorPainter(
          barcodes,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          cameraDescription.lensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        _customPaint = null;
      }

      notifyListeners();
    });
  }

  void clear() {
    _cameraProcessor.dispose();
    _cameraController?.dispose();

    notifyListeners();
  }
}
