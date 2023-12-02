import 'dart:io' show File;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:camera/camera.dart' show XFile;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:snap_focus_area/widgets/overlay/card_overlay.dart';

Future<Image> cropImageAndSave(
    XFile imageFile, Size imageSize, GlobalKey downloadObjectKey,
    {double pixelRatio = 1, required CardOverlay cardOverlay}) async {
  final imageContainerSize =
      Size(imageSize.width / pixelRatio, imageSize.height / pixelRatio);
  double horizontalPadding =
      ((1 - cardOverlay.widthFraction) * imageContainerSize.width) / 2;
  double actualOverlayWidth =
      imageContainerSize.width - (horizontalPadding * 2);
  double actualOverlayHeight =
      min(imageContainerSize.height, actualOverlayWidth / cardOverlay.ratio);
  Size actualOverlayOnImage =
      Size(actualOverlayWidth * pixelRatio, actualOverlayHeight * pixelRatio);

  int xStartCropImage = (imageSize.width - actualOverlayOnImage.width) ~/ 2;
  int yStartCropImage = (imageSize.height - actualOverlayOnImage.height) ~/ 2;

  final filePath = imageFile.path;
  final img.Image? image = kIsWeb
      ? img.decodeImage(await imageFile.readAsBytes())
      : filePath.toLowerCase().endsWith('png')
          ? img.decodePng(File(filePath).readAsBytesSync())
          : img.decodeJpg(File(filePath).readAsBytesSync());
  final picture = img.copyCrop(image!,
      x: xStartCropImage ~/ pixelRatio,
      y: yStartCropImage ~/ pixelRatio,
      width: actualOverlayOnImage.width ~/ pixelRatio,
      height: actualOverlayOnImage.height ~/ pixelRatio,
      radius: cardOverlay.cornerRadius);
  if (kIsWeb) {
    final encoder = img.JpegEncoder();
    final bytes = encoder.encode(picture);
    var j = Image.memory(bytes);
    return j;
  } else {
    var outputImage = filePath.toLowerCase().endsWith('png')
        ? img.encodePng(picture)
        : img.encodeJpg(picture);
    final outputFile = File(filePath);
    await outputFile.writeAsBytes(outputImage);
    return Image.file(outputFile);
  }
}

class RenderConstrainedBoxB extends RenderConstrainedBox {
  RenderConstrainedBoxB({required super.additionalConstraints});
  Future<ui.Image> toImage({double pixelRatio = 1.0}) {
    assert(!debugNeedsPaint);
    final OffsetLayer offsetLayer = layer! as OffsetLayer;
    return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
  }

  factory RenderConstrainedBoxB.fromRenderConstrainedBox(
      RenderConstrainedBox box) {
    return RenderConstrainedBoxB(
        additionalConstraints: box.additionalConstraints);
  }

  bool isExtended() => true;
}
