import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:scanit/utils/barcode_utils.dart';

import '../calendar_event_dialog.dart';
import '../contact_info_dialog.dart';
import '../driver_license_dialog.dart';
import '../email_dialog.dart';
import '../geo_dialog.dart';
import '../phone_dialog.dart';
import '../sms_dialog.dart';
import '../url_dialog.dart';
import '../wifi_dialog.dart';

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
    switch (barcode.value) {
      case BarcodeContactInfo _:
        return ContactInfoDialog(
          contactInfo: barcode.value! as BarcodeContactInfo,
        );
      case BarcodeEmail _:
        return EmailDialog(email: barcode.value! as BarcodeEmail);
      case BarcodePhone _:
        return PhoneDialog(phone: barcode.value! as BarcodePhone);
      case BarcodeSMS _:
        return SmsDialog(sms: barcode.value! as BarcodeSMS);
      case BarcodeUrl _:
        return UrlDialog(url: barcode.value! as BarcodeUrl);
      case BarcodeWifi _:
        return WifiDialog(wifi: barcode.value! as BarcodeWifi);
      case BarcodeGeoPoint _:
        return GeoDialog(geoPoint: barcode.value! as BarcodeGeoPoint);
      case BarcodeCalenderEvent _:
        return CalendarEventDialog(
          calendarEvent: barcode.value! as BarcodeCalenderEvent,
        );
      case BarcodeDriverLicense _:
        return DriverLicenseDialog(
          driverLicense: barcode.value! as BarcodeDriverLicense,
        );
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
