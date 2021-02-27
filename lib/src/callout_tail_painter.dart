import 'package:flutter/widgets.dart';

class CalloutTailPainter extends CustomPainter {
  /// Paints the callout tail for [HotspotProvider] based on a [Rect] bounds
  CalloutTailPainter({
    @required this.tailBounds,
    @required this.color,
  });

  /// The bounding rectangle of the callout tail.
  final Rect tailBounds;

  /// The color of the tail.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    /// We draw the tail as a diamond so it makes transitioning between
    /// the top of the body to the bottom of the body easy.
    final tailPath = Path()
      ..moveTo(tailBounds.topCenter.dx, tailBounds.topCenter.dy)
      ..lineTo(tailBounds.centerRight.dx, tailBounds.centerRight.dy)
      ..lineTo(tailBounds.bottomCenter.dx, tailBounds.bottomCenter.dy)
      ..lineTo(tailBounds.centerLeft.dx, tailBounds.centerLeft.dy)
      ..lineTo(tailBounds.topCenter.dx, tailBounds.topCenter.dy);

    canvas.drawPath(tailPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(CalloutTailPainter old) =>
      tailBounds != old.tailBounds || color != old.color;
}
