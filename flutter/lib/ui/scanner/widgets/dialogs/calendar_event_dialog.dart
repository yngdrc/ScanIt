import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'core/scan_result_dialog_widgets.dart';

class CalendarEventDialog extends StatelessWidget {
  const CalendarEventDialog({super.key, required this.calendarEvent});

  final CalendarEvent calendarEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.calendarEvent.name]),
        DialogField(label: 'Organizer', values: [calendarEvent.organizer!]),
        DialogField(label: 'Summary', values: [calendarEvent.summary!]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: DialogField(
                label: 'Start',
                values: [calendarEvent.start!.toString()],
              ),
            ),
            Expanded(
              child: DialogField(
                label: 'End',
                values: [calendarEvent.end!.toString()],
              ),
            ),
          ],
        ),
        DialogField(label: 'Description', values: [calendarEvent.description!]),
        DialogField(label: 'Location', values: [calendarEvent.location!]),
      ],
    );
  }
}
