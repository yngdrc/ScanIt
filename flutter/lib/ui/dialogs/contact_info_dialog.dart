import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'core/scan_result_dialog_widgets.dart';

class ContactInfoDialog extends StatelessWidget {
  const ContactInfoDialog({super.key, required this.contactInfo});

  final BarcodeContactInfo contactInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.contactInfo.name]),
        DialogField(label: 'Name', values: [contactInfo.formattedName!]),
        DialogField(
          label: 'Organization',
          values: [contactInfo.organizationName!],
        ),
        DialogField(label: 'Title', values: [contactInfo.jobTitle!]),
        DialogField(
          label: 'Phones',
          values: contactInfo.phoneNumbers
              .map((phone) => phone.number!)
              .toList(),
        ),
        DialogField(
          label: 'Emails',
          values: contactInfo.emails.map((email) => email.address!).toList(),
        ),
        DialogField(
          label: 'Addresses',
          values: contactInfo.addresses
              .map((address) => address.addressLines.join(', '))
              .toList(),
        ),
        DialogField(label: 'Links', values: contactInfo.urls),
      ],
    );
  }
}
