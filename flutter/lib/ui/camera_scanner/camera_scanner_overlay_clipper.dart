import 'package:flutter/material.dart';

class CameraScannerOverlayClipper extends CustomClipper<Path> {
  const CameraScannerOverlayClipper({required this.scanArea});

  final Rect scanArea;

  @override
  Path getClip(Size size) {
    final dimRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final dimPath = Path()
      ..addRect(dimRect)
      ..close();

    final scanAreaRect = RRect.fromRectAndRadius(scanArea, Radius.circular(2));
    final scanAreaPath = Path()
      ..addRRect(scanAreaRect)
      ..close();

    return Path.combine(PathOperation.difference, dimPath, scanAreaPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
