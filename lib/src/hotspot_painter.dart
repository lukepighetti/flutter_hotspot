import 'package:flutter/widgets.dart';

class HotspotPainter extends CustomPainter {
  /// Paints a skrim with an empty hotspot
  HotspotPainter({
    @required this.hotspotBounds,
    @required this.skrimColor,
    @required this.shapeBorder,
  });

  /// The target to highlight with a hotspot.
  final Rect hotspotBounds;

  /// The color of the skrim which acts as the background
  /// between the hotspot callout and the view. Provides
  /// hotspot cutouts that surround the appropriate [HotspotTarget].
  final Color skrimColor;

  /// Override the convenience [radius] with a custom [ShapeBorder]
  ///
  /// Particularly useful for defining squircle borders.
  final ShapeBorder shapeBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final skrimPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = skrimColor;

    final skrimPath = Path()
      ..addRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final hotspotPath = shapeBorder.getOuterPath(hotspotBounds);

    final path = Path.combine(PathOperation.difference, skrimPath, hotspotPath);

    canvas.drawPath(path, skrimPaint);
  }

  @override
  bool shouldRepaint(HotspotPainter old) =>
      hotspotBounds != old.hotspotBounds ||
      skrimColor != old.skrimColor ||
      shapeBorder != old.shapeBorder;
}
