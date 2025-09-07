import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

abstract class ConverterPlugin {
  static const _converterChannel = MethodChannel(
    'app.aventurine.scanit/converter',
  );

  static Future<Uint8List?> getBitmapData(
    int width,
    int height,
    Uint8List nv21,
  ) async {
    return await _converterChannel.invokeMethod<Uint8List>(
      'getBitmapData',
      <String, dynamic>{'width': width, 'height': height, 'nv21': nv21},
    );
  }
}
