import 'package:flutter/material.dart';

class MobileScannerMask extends StatelessWidget {
  const MobileScannerMask({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _MobileScannerMaskClipper(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }
}

class _MobileScannerMaskClipper extends CustomClipper<Path> {
  const _MobileScannerMaskClipper();

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double scanWindowSize = size.shortestSide / 2.1;

    final centerRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTWH(0, 0, width, height))
        ..close(),
      Path()
        ..addRRect(RRect.fromRectAndRadius(centerRect, Radius.circular(2)))
        ..close(),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
