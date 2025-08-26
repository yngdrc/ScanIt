import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanit/ui/scanner/widgets/dialogs/core/scan_result_dialog_widgets.dart';

class ContactInfoDialog extends StatelessWidget {
  const ContactInfoDialog({super.key, required this.contactInfo});

  final ContactInfo contactInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.contactInfo.name]),
        DialogField(label: 'Name', values: [contactInfo.name!.formattedName!]),
        DialogField(label: 'Organization', values: [contactInfo.organization!]),
        DialogField(label: 'Title', values: [contactInfo.title!]),
        DialogField(
          label: 'Phones',
          values: contactInfo.phones.map((phone) => phone.number!).toList(),
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
        DialogField(
          label: 'Links',
          values: contactInfo.urls,
        ),
      ],
    );
  }
}
