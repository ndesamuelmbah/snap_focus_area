import 'package:flutter/material.dart';

class CameraControlButton extends StatelessWidget {
  final Function onPressed;
  final Widget icon;
  final Color color;
  const CameraControlButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.color = Colors.white54});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      color: color,
      child: InkWell(
        onTap: () async {
          await onPressed();
        },
        child: SizedBox(height: 50, width: 50, child: icon),
      ),
    );
  }
}
