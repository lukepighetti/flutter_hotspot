import 'package:flutter/widgets.dart';

class CalloutLayoutDelegate {
  /// Handles all the layout for the hotspot, callout tail,
  /// and callout body positions.
  CalloutLayoutDelegate({
    required this.paintBounds,
    required this.targetBounds,
    required this.hotspotPadding,
    required this.tailSize,
    required this.tailInsets,
    required this.bodyMargin,
    required this.bodyWidth,
    required this.hotspotSize,
    required this.hotspotOffset,
  });

  /// The boundary of the viewport where targets will be found.
  final Rect paintBounds;

  /// The global boundary of the target to hotspot.
  final Rect targetBounds;

  /// The hotspot padding.
  final EdgeInsets hotspotPadding;

  /// The margin between the hotspot and the tail.
  final EdgeInsets tailInsets;

  /// The size of the callout tail.
  final Size tailSize;

  /// The margin between the callout body and the viewport.
  final EdgeInsets bodyMargin;

  /// The width of the callout body.
  final double bodyWidth;

  /// `Nullable.` A custom size for the hotspot.
  final Size? hotspotSize;

  /// A custom offset for the hotspot center.
  final Offset hotspotOffset;

  /// The bounding rectacle for the hotspot
  Rect get hotspotBounds {
    if (hotspotSize != null) {
      return hotspotPadding.inflateRect(
        Rect.fromCenter(
          center: targetBounds.center.translate(
            hotspotOffset.dx,
            hotspotOffset.dy,
          ),
          width: hotspotSize!.width,
          height: hotspotSize!.height,
        ),
      );
    } else {
      return hotspotPadding.inflateRect(targetBounds.shift(hotspotOffset));
    }
  }

  /// Determine if the target is above center or below center
  bool get targetIsAboveCenter =>
      targetBounds.center.dy < paintBounds.height / 2;

  /// The bounding rectangle for the callout tail
  Rect get tailBounds {
    // Calculate the tail point inset
    final inset = (hotspotPadding - tailInsets).inflateRect(targetBounds);

    final tailCenter = targetIsAboveCenter
        ? inset.bottomCenter.translate(0, tailSize.height)
        : inset.topCenter.translate(0, -tailSize.height);

    return Rect.fromCenter(
        center: tailCenter, width: tailSize.width, height: tailSize.height * 2);
  }

  Rect get bodyContainerBounds {
    final deflatedPaintBounds = bodyMargin.deflateRect(paintBounds);

    final unpositionedBodyRect = Rect.fromCenter(
      center: tailBounds.center,
      width: bodyWidth,
      height: bodyContainerHeight,
    ).translateToFitX(deflatedPaintBounds);

    if (targetIsAboveCenter) {
      return unpositionedBodyRect.translate(0, bodyContainerHeight / 2);
    } else {
      return unpositionedBodyRect.translate(0, -bodyContainerHeight / 2);
    }
  }

  /// We use a transparent body container with an animated alignment
  /// so that the body can be of any height.
  double get bodyContainerHeight => paintBounds.height;
}

extension on Rect {
  /// Tranlate this Rect horizontally to fit inside another Rect
  Rect translateToFitX(Rect e) {
    assert(width <= e.width,
        'The parent Rect(width: ${e.width}) must be wider than this Rect(width:$width)');

    /// Overhanging on the right
    if (e.right < right) {
      return translate(-(e.right - right).abs(), 0);
    }

    /// Overhanging on the left
    else if (e.left > left) {
      return translate((e.left - left).abs(), 0);
    }

    /// No overhang
    else {
      return this;
    }
  }
}
