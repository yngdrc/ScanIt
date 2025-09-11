import 'package:flutter/material.dart';

class DialogField extends StatelessWidget {
  const DialogField({super.key, required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade200,
            fontSize: 11,
          ),
        ),
        ...values.map(
          (value) => Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
