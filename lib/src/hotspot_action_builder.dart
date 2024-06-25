import 'package:flutter/material.dart';

import 'hotspot_provider.dart';

class HotspotActionBuilder extends StatelessWidget {
  /// Used on all hotspots, builds the buttons and item indicator.
  HotspotActionBuilder(this.controller);

  final CalloutActionController controller;

  final _duration = const Duration(milliseconds: 250);
  final _curve = Curves.easeOutCirc;

  @override
  Widget build(BuildContext context) {
    final fg = controller.foregroundColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 12) +
          EdgeInsets.symmetric(
            horizontal: 12,
          ),
      child: Row(
        children: [
          /// Back / end tour button
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                child: Text(
                  controller.isFirstPage ? 'End tour' : 'Previous',
                  maxLines: 2,
                ),
                onPressed: () {
                  controller.previous();
                },
              ),
            ),
          ),

          Row(
            children: [
              for (var i = 0; i < controller.pages; i++)
                AnimatedContainer(
                  margin: EdgeInsets.all(3),
                  duration: _duration,
                  curve: _curve,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.index == i ? fg : fg?.withOpacity(0.3),
                  ),
                  height: 6,
                  width: 6,
                ),
            ],
          ),

          /// Next / done button.
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                child: Text(
                  controller.isLastPage ? 'Done' : 'Next',
                  maxLines: 2,
                ),
                onPressed: () {
                  controller.next();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
