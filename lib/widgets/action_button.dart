import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final FontWeight fontWeight;
  final String? fontFamily;
  final bool showBorder;
  final double borderWidth;
  final double radius;
  final double maxWidth;
  final double minWidth;
  final double height;
  final double horizontalPadding;
  final Color? fontColor;
  final void Function() onPressed;
  const ActionButton(
      {super.key,
      this.backgroundColor = Colors.transparent,
      this.fontWeight = FontWeight.normal,
      this.fontColor,
      this.fontFamily,
      this.showBorder = true,
      this.borderWidth = 1,
      this.radius = 15,
      this.maxWidth = 300,
      this.minWidth = 20,
      this.height = 38,
      this.horizontalPadding = 5.0,
      required this.text,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: 38,
          constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: kIsWeb ? maxWidth : double.infinity),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              border: showBorder
                  ? Border.all(color: color, width: borderWidth)
                  : null),
          alignment: Alignment.center,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: TextStyle(
                    color: fontColor ?? color,
                    fontWeight: fontWeight,
                    fontFamily: fontFamily),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
