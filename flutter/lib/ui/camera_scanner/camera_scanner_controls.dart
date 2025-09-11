import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:file_picker/file_picker.dart';

typedef OnFilePicked = Function({required FilePickerResult result});

class CameraScannerControls extends StatelessWidget {
  const CameraScannerControls({
    super.key,
    required this.isFlashlightOn,
    required this.onFlashlightToggle,
    required this.onCameraSwitch,
    required this.onFilePicked,
  });

  final bool isFlashlightOn;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraSwitch;
  final OnFilePicked onFilePicked;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    onFilePicked(result: result);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _createControlButton(
          icon: isFlashlightOn ? Symbols.flashlight_on : Symbols.flashlight_off,
          isSelected: isFlashlightOn,
          onPressed: onFlashlightToggle,
        ),
        _createControlButton(
          icon: Symbols.cameraswitch,
          isSelected: false,
          onPressed: onCameraSwitch,
        ),
        _createControlButton(
          icon: Symbols.file_open,
          isSelected: false,
          onPressed: _pickFile,
        ),
      ],
    );
  }

  Widget _createControlButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.1),
            child: Icon(icon, size: 24, color: Colors.white, weight: 300),
          ),
        ),
      ),
    );
  }
}
