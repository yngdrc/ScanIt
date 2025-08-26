import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/contact_info_dialog.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/email_dialog.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/geo_dialog.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/phone_dialog.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/wifi_dialog.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../calendar_event_dialog.dart';
import '../driver_license_dialog.dart';
import '../sms_dialog.dart';
import '../url_dialog.dart';

class ScanResultDialog extends StatelessWidget {
  const ScanResultDialog._({required this.barcode});

  final Barcode barcode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDialog(),
        IconButton.filled(
          iconSize: 32,
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: Icon(Symbols.chevron_left),
        ),
      ],
    );
  }

  Widget _buildDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildDialogContent(),
                ),
                Hero(
                  tag: 'barcode_hero',
                  child: barcode_widget.BarcodeWidget(
                    data: barcode.rawValue!,
                    barcode: barcode_widget.Barcode.fromType(
                      barcode.barcodeWidgetType!,
                    ),
                    padding: EdgeInsets.all(5),
                    backgroundColor: Colors.white,
                    color: Colors.black,
                    style: TextStyle(color: Colors.black),
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    switch (barcode.type) {
      case BarcodeType.contactInfo:
        return ContactInfoDialog(contactInfo: barcode.contactInfo!);
      case BarcodeType.email:
        return EmailDialog(email: barcode.email!);
      case BarcodeType.phone:
        return PhoneDialog(phone: barcode.phone!);
      case BarcodeType.sms:
        return SmsDialog(sms: barcode.sms!);
      case BarcodeType.url:
        return UrlDialog(url: barcode.url!);
      case BarcodeType.wifi:
        return WifiDialog(wifi: barcode.wifi!);
      case BarcodeType.geo:
        return GeoDialog(geoPoint: barcode.geoPoint!);
      case BarcodeType.calendarEvent:
        return CalendarEventDialog(calendarEvent: barcode.calendarEvent!);
      case BarcodeType.driverLicense:
        return DriverLicenseDialog(driverLicense: barcode.driverLicense!);
      default:
        return Text(
          'Data: ${barcode.rawValue}',
          style: TextStyle(color: Colors.white),
        );
    }
  }

  static Future<dynamic> show({
    required BuildContext context,
    required Barcode barcode,
    required VoidCallback onDismiss,
  }) async {
    if (barcode.rawValue == null || barcode.barcodeWidgetType == null) return;

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, _, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 50 * animation.value,
              sigmaY: 50 * animation.value,
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        pageBuilder: (_, _, _) {
          return ScanResultDialog._(barcode: barcode);
        },
      ),
    );

    onDismiss();
  }
}
