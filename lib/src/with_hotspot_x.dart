import 'package:flutter/material.dart';
import 'package:hotspot/hotspot.dart';

extension WithHotspotX on Widget {
  /// Wrap this widget with a branded [HotspotTarget]
  Widget withHotspot({
    String flow = 'main',
    required num order,
    required String title,
    required String text,
    Widget? icon,
    Size? hotspotSize,
    Offset hotspotOffset = Offset.zero,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final fg = HotspotProvider.of(context).fg;

        return HotspotTarget(
          flow: flow,
          hotspotSize: hotspotSize,
          hotspotOffset: hotspotOffset,
          order: order,
          calloutBody: Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg),
                  child: icon,
                ),
                SizedBox(width: 16),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    if (title.isNotEmpty && text.isNotEmpty)
                      SizedBox(
                        height: 6,
                      ),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          child: this,
        );
      },
    );
  }
}
