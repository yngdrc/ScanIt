import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:nil/nil.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../../../navigation/navigation_screen.dart';

class ScannerScreen extends StatelessWidget implements NavigationScreen {
  const ScannerScreen({super.key, required this.viewModel});

  final ScannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final Size layoutSize = constraints.biggest;
        final double scanWindowSize = layoutSize.shortestSide / 2;

        return MobileScanner(
          scanWindow: Rect.fromCenter(
            center: layoutSize.center(Offset.zero),
            width: scanWindowSize,
            height: scanWindowSize,
          ),
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
          overlayBuilder: (_, constraints) {
            return _ScanRectangleWidget(
              size: scanWindowSize,
              command: viewModel.saveScanCommand,
            );
          },
          onDetect: (barcodeCapture) {
            final barcode = barcodeCapture.barcodes.firstOrNull;
            if (barcode == null) return;
            viewModel.saveScanCommand.execute(barcode);
          },
        );
      },
    );
  }
}

class _ScanRectangleWidget extends StatefulWidget {
  const _ScanRectangleWidget({required this.size, required this.command});

  final double size;
  final Command<Barcode, Barcode?> command;

  @override
  State<StatefulWidget> createState() => _ScanRectangleWidgetState();
}

class _ScanRectangleWidgetState extends State<_ScanRectangleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.fastLinearToSlowEaseIn,
  ).drive(Tween(begin: 1, end: 0.8));

  @override
  void initState() {
    super.initState();
    widget.command.results.addListener(_tryStartAnimation);
  }

  @override
  void dispose() {
    widget.command.results.removeListener(_tryStartAnimation);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _tryStartAnimation() async {
    if (widget.command.value == null) {
      return;
    }

    _animationController.reset();
    await _animationController.repeat(reverse: true, count: 2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          border: DashedBorder.all(
            color: Colors.white,
            dashLength: widget.size / 8,
            width: 2,
            isOnlyCorner: true,
            strokeCap: StrokeCap.round,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: CommandBuilder(
          command: widget.command,
          onData: (_, data, _) {
            final barcodeData = data?.rawValue;
            final barcodeType = data?.barcodeWidgetType;
            if (barcodeData == null || barcodeType == null) {
              return Nil();
            }

            return barcode_widget.BarcodeWidget(
              data: barcodeData,
              barcode: barcode_widget.Barcode.fromType(barcodeType),
              padding: EdgeInsets.all(10),
              backgroundColor: Colors.white,
              color: Colors.black,
              style: TextStyle(color: Colors.black),
            );
          },
        ),
      ),
    );
  }
}
