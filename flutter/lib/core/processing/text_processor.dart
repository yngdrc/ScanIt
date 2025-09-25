import 'dart:ui';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanit/core/processing/scanit_processor.dart';
import 'package:scanit/core/processing/scanit_processor_event.dart';

import '../detection_mode.dart';

class TextProcessor extends ScanItProcessor<TextRecognizedEvent> {
  TextProcessor({
    TextRecognitionScript textRecognitionScript = TextRecognitionScript.latin,
  }) : _textRecognizer = TextRecognizer(script: textRecognitionScript),
        super(DetectionMode.ocr);

  final TextRecognizer _textRecognizer;

  @override
  Future<TextRecognizedEvent> process({
    required InputImage inputImage,
    required CameraLensDirection lensDirection,
    required DetectionMode detectionMode,
    required Size widgetSize,
    required Size imageSize,
    required Rect scanArea,
  }) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return TextRecognizedEvent(
      recognizedText: recognizedText,
      widgetSize: widgetSize,
      inputImage: inputImage,
      lensDirection: lensDirection,
      imageSize: imageSize,
      scanArea: scanArea,
    );
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _textRecognizer.close();
  }
}
