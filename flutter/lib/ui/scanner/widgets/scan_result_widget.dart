import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResultWidget extends StatelessWidget {
  const ScanResultWidget({
    super.key,
    required this.barcode,
    required this.onTap,
  });

  final Barcode barcode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 260,
              height: 85,
              color: Colors.black.withValues(alpha: 0.3),
              padding: EdgeInsets.all(19),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Symbols.location_on,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        barcode.rawValue!,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  Icon(Symbols.chevron_right, size: 24, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
