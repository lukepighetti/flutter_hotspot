/// Getting started with the `hotspot` tour guide feature:
///
/// 1. put [HotspotProvider] at the top of your widget tree
/// 2. give it an actionBuilder for controls
/// 3. annotate widgets to highlight and explain with [HotspotTarget]
/// 4. call `HotspotProvider.of(context).startFlow()`
///
/// This feature will highlight your [HotspotTarget]s and provide
/// an animated and interactive dialog with more information.
library hotspot;

export 'src/hotspot_action_builder.dart';
export 'src/hotspot_provider.dart';
export 'src/hotspot_target.dart';
export 'src/with_hotspot_x.dart';
