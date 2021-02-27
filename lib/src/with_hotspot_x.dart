import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'hotspot_target.dart';

extension WithHotspotX on Widget {
  /// Wrap this widget with a branded [HotspotTarget]
  Widget withHotspot({
    String flow = 'main',
    @required num order,
    @required String title,
    @required String text,
    Widget icon,
    Size hotspotSize,
    Offset hotspotOffset = Offset.zero,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return HotspotTarget(
          flow: flow,
          hotspotSize: hotspotSize,
          hotspotOffset: hotspotOffset,
          calloutBody: Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: Colors.white),
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
                        style: theme.textTheme.subtitle1
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    if (title.isNotEmpty && text.isNotEmpty)
                      SizedBox(
                        height: 12,
                      ),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: theme.textTheme.bodyText2,
                      ),
                  ],
                ),
              ),
            ],
          ),
          order: order,
          child: this,
        );
      },
    );
  }
}
