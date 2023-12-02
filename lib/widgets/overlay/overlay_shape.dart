import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snap_focus_area/widgets/overlay/card_overlay.dart';

class OverlayShape extends StatelessWidget {
  const OverlayShape(this.cardOverlay, this.overlayKey,
      {this.cameraScreenSize, this.overlayBoxDecoration, super.key});

  final GlobalKey overlayKey;
  final CardOverlay cardOverlay;
  final Size? cameraScreenSize;
  final BoxDecoration? overlayBoxDecoration;

  @override
  Widget build(BuildContext context) {
    //print('Overlay Screen size $cameraScreenSize');

    double horizontalPadding =
        ((1 - cardOverlay.widthFraction) * cameraScreenSize!.width) / 2;
    double actualWidth = cameraScreenSize!.width - (horizontalPadding * 2);
    double actualHeight =
        min(cameraScreenSize!.height, actualWidth / cardOverlay.ratio);
    //print('Overlay Size in Overlay Size($actualWidth, $actualHeight)');
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      //print('Orientation is Portrait');
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.transparent.withOpacity(0.6),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              key: overlayKey,
              width: actualWidth,
              height: actualHeight,
              decoration: overlayBoxDecoration ??
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(cardOverlay.cornerRadius),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
