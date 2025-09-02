import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

abstract class ConverterPlugin {
  static const _converterChannel = MethodChannel(
    'app.aventurine.scanit/converter',
  );

  static Future<Uint8List?> yuv420888ToNv21(CameraImage data) async {
    return await _converterChannel
        .invokeMethod<Uint8List>('yuv420888ToNv21', <String, dynamic>{
      'width': data.width,
      'height': data.height,
      'planes': data.planes.map((e) => e.bytes).toList(),
    });
  }
}