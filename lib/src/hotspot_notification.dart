import 'package:flutter/widgets.dart';

import 'hotspot_target.dart';

class HotspotNotification extends Notification {
  /// Registers the current availability of a [HotspotTarget]
  HotspotNotification({@required this.target});

  /// The [HotspotTargetState] that is dispatching this notification.
  final HotspotTargetState target;

  @override
  String toString() => 'HotspotNotification(target: $target)';
}
