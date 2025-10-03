import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/widgets.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';
import 'package:scanit/core/processing/text_processor.dart';
import 'package:scanit/core/utils/camera_image_extension.dart';
import 'package:scanit/core/utils/scanit_utils.dart';

import '../detection_mode.dart';
import 'barcode_processor.dart';

abstract class ScanItProcessor<TEvent extends ScanItProcessorEvent> {
  ScanItProcessor(this.detectionMode);

  static ScanItProcessor<ScanItProcessorEvent> factoryConstructor({
    required DetectionMode detectionMode,
  }) => switch (detectionMode) {
    DetectionMode.barcode => BarcodeProcessor(),
    DetectionMode.ocr => TextProcessor(),
  };

  // factory ScanItProcessor.factory({required DetectionMode detectionMode}) =>
  //     switch (detectionMode) {
  //       DetectionMode.barcode => BarcodeProcessor() as ScanItProcessor<TEvent>,
  //       DetectionMode.ocr => TextProcessor() as ScanItProcessor<TEvent>,
  //     };

  final DetectionMode detectionMode;

  bool _canProcess = true;
  CancelableOperation<void>? _processingOperation;

  bool get _isBusy {
    return _processingOperation != null &&
        !_processingOperation!.isCompleted &&
        !_processingOperation!.isCanceled;
  }

  final StreamController<TEvent> _eventController =
      StreamController.broadcast();

  Stream<TEvent> get eventStream => _eventController.stream;

  // TODO handle errors
  Future<TEvent> process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size widgetSize,
    required Size imageSize,
    required Rect scanArea,
  });

  Rect calculateScanArea({
    required Size imageSize,
    required Size widgetSize,
    required InputImageRotation inputImageRotation,
    required Rect scanArea,
  }) {
    final scale = imageSize.longestSide / widgetSize.longestSide;
    final scaledBounds = Rect.fromCenter(
      center: imageSize.center(Offset.zero),
      width: widgetSize.width * scale,
      height: widgetSize.height * scale,
    ).rotateBy(angle: Platform.isIOS ? 0 : -inputImageRotation.rawValue);

    final scaledScanArea = Rect.fromLTWH(
      scanArea.left * scale,
      scanArea.top * scale,
      scanArea.width * scale,
      scanArea.height * scale,
    );

    if (Platform.isIOS) {
      return scaledScanArea.shift(scaledBounds.topLeft);
    }

    return switch (inputImageRotation) {
      InputImageRotation.rotation0deg => scaledScanArea.shift(
        scaledBounds.topLeft,
      ),
      InputImageRotation.rotation90deg =>
        scaledScanArea
            .shift(scaledBounds.bottomLeft)
            .rotateBy(
              angle: -inputImageRotation.rawValue,
              anchor: scaledBounds.bottomLeft,
            ),
      InputImageRotation.rotation180deg =>
        scaledScanArea
            .shift(scaledBounds.bottomRight)
            .rotateBy(
              angle: inputImageRotation.rawValue,
              anchor: scaledBounds.bottomRight,
            ),
      InputImageRotation.rotation270deg =>
        scaledScanArea
            .shift(scaledBounds.topRight)
            .rotateBy(
              angle: inputImageRotation.rawValue,
              anchor: scaledBounds.topRight,
            ),
    };
  }

  void processCameraImage({
    required CameraImage cameraImage,
    required Rect scanArea,
    required InputImageRotation inputImageRotation,
    required CameraLensDirection cameraLensDirection,
    required Size widgetSize,
    required DeviceOrientation deviceOrientation,
  }) {
    if (!_canProcess) return;
    if (_isBusy) return;

    final future = Future.sync(() async {
      final calculatedScanArea = calculateScanArea(
        imageSize: cameraImage.size,
        widgetSize: widgetSize,
        inputImageRotation: inputImageRotation,
        scanArea: scanArea,
      );

      final inputImage = await cameraImage.inputImageFromBytes(
        cropRect: calculatedScanArea,
        rotation: inputImageRotation,
      );

      if (inputImage == null) {
        await cancelProcessing();
        return null;
      }

      final event = await process(
        widgetSize: widgetSize,
        inputImage: inputImage,
        lensDirection: cameraLensDirection,
        detectionMode: detectionMode,
        imageSize: cameraImage.size,
        scanArea: calculatedScanArea,
      );

      _eventController.add(event);
    });

    _processingOperation = CancelableOperation.fromFuture(future);
  }

  // TODO: scanWindow support
  Future<TEvent?> processXFile({
    required XFile xFile,
    required Rect scanArea,
    required Size widgetSize,
    required double scale,
  }) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;

    final image = await decodeImageFromList(await xFile.readAsBytes());

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImage = InputImage.fromFilePath(xFile.path);
    final event = await process(
      inputImage: inputImage,
      lensDirection: CameraLensDirection.back,
      detectionMode: detectionMode,
      widgetSize: widgetSize,
      imageSize: imageSize,
      scanArea: scanArea,
    );

    return event;
  }

  Future<void> cancelProcessing() async {
    await _processingOperation?.cancel();
    _processingOperation = null;
  }

  Future<void> dispose() async {
    _canProcess = false;
    await cancelProcessing();
    await _eventController.close();
  }
}
