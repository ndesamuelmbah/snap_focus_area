enum OverlayOrientation { landscape, portrait }

class CardOverlay {
  double ratio;
  double cornerRadius;
  double widthFraction;
  OverlayOrientation? orientation;
  CardOverlay(
      {this.ratio = 1.5,
      this.cornerRadius = 5,
      this.widthFraction = 1.0,
      this.orientation = OverlayOrientation.landscape}) {
    if (widthFraction < 0.1 || widthFraction > 1.0) {
      throw Exception(
          'widthFraction == $widthFraction must be between 0.1 and 1.0');
    }
  }
  factory CardOverlay.fromValues(
      {double ratio = 1.59,
      double cornerRadius = 5,
      double widthFraction = 1}) {
    return CardOverlay(
        ratio: ratio, cornerRadius: cornerRadius, widthFraction: widthFraction);
  }
}
