import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'core/scan_result_dialog_widgets.dart';

class DriverLicenseDialog extends StatelessWidget {
  const DriverLicenseDialog({super.key, required this.driverLicense});

  final BarcodeDriverLicense driverLicense;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.driverLicense.name]),
        DialogField(
          label: 'Name',
          values: [
            [
              driverLicense.firstName!,
              driverLicense.lastName!,
            ].join(' '),
          ],
        ),
        DialogField(label: 'Birthdate', values: [driverLicense.birthDate!]),
        DialogField(label: 'Gender', values: [driverLicense.gender!]),
        DialogField(
          label: 'Address',
          values: [
            driverLicense.addressCity!,
            driverLicense.addressStreet!,
            driverLicense.addressState!,
            driverLicense.addressZip!,
          ],
        ),
        DialogField(label: 'Issue date', values: [driverLicense.issueDate!]),
        DialogField(label: 'Expiry date', values: [driverLicense.expiryDate!]),
        DialogField(
          label: 'Issuing country',
          values: [driverLicense.country!],
        ),
        DialogField(
          label: 'License number',
          values: [driverLicense.licenseNumber!],
        ),
      ],
    );
  }
}
