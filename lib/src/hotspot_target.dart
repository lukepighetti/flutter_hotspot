import 'package:flutter/widgets.dart';

import 'hotspot_notification.dart';

/// Example of a page that has multiple hotspot targets.
///
/// ```dart
/// Scaffold(
///   appBar: AppBar(
///     leading: HotspotTarget(
///       order: 200,
///       calloutBody: buildCalloutBody(
///         Icons.exit_to_app,
///         'Back button',
///         'This is a Flutter back button.',
///       ),
///       child: BackButton(),
///     ),
///     title: HotspotTarget(
///       order: 100,
///       calloutBody: buildCalloutBody(
///         Icons.title,
///         'Title',
///         'This is the name of the route for this view.',
///       ),
///       child: Text('/hotspot'),
///     ),
///     actions: [
///       HotspotTarget(
///         order: 900,
///         calloutBody: buildCalloutBody(
///           Icons.tour,
///           'Take a Tour',
///           'Take this tour again at any time!',
///         ),
///         child: IconButton(
///           icon: Icon(Icons.play_arrow),
///           onPressed: () => HotspotProvider.of(context).startFlow(),
///         ),
///       ),
///     ],
///   ),
///   body: Stack(
///     children: [
///       //// Forth
///       SafeArea(
///         child: Align(
///           alignment: Alignment.bottomCenter,
///           child: HotspotTarget(
///             order: 500,
///             calloutBody: buildCalloutBody(
///               Icons.photo,
///               'This is an icon',
///               "It's placed at the bottom of this view so you can see the callout transition!",
///             ),
///             child: Icon(
///               Icons.people,
///               size: 42,
///             ),
///           ),
///         ),
///       )
///     ],
///   ),
/// )
/// ```
class HotspotTarget extends StatefulWidget {
  /// Tags a widget to be located, highlighted and called out
  /// as part of a hotspot flow.
  const HotspotTarget({
    Key key,
    this.flow = 'main',
    @required this.calloutBody,
    @required this.order,
    @required this.child,
    this.hotspotSize,
    this.hotspotOffset = Offset.zero,
  }) : super(key: key);

  /// Combines multiple hotspot targets into a single group.
  ///
  /// This allows multiple hotspot flows to exist in an app.
  ///
  /// Eg: "home-flow", "edit-flow", "transaction-flow"
  final String flow;

  /// The Widget to display in the callout body.
  ///
  /// Typically some kind of text describing the feature,
  /// maybe with an icon.
  final Widget calloutBody;

  /// The place in the flow order.
  final num order;

  /// The widget to highlight with the hotspot.
  final Widget child;

  /// Override the hotspot dimensions with a custom size.
  final Size hotspotSize;

  /// Override the hotspot center with a custom offset.
  final Offset hotspotOffset;

  @override
  HotspotTargetState createState() => HotspotTargetState();
}

class HotspotTargetState extends State<HotspotTarget> {
  @override
  void didChangeDependencies() {
    HotspotNotification(target: this).dispatch(context);
    super.didChangeDependencies();
  }

  /// Convenience getter to find the global paint bounds of this [HotspotTarget]
  Rect get globalPaintBounds =>
      (context.findRenderObject() as RenderBox).paintBounds.shift(
          (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero));

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'HotspotTargetState(flow: ${widget.flow}, order: ${widget.order}, mounted: $mounted)';
}
