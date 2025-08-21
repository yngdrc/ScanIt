import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.fontWeight,
    required this.titleAlignment
  });

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Alignment titleAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      alignment: titleAlignment,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: SafeArea(
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56 + 32);
}
