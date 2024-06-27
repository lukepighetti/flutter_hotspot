import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hotspot/hotspot.dart';
import 'package:provider/provider.dart';

import 'callout_layout_delegate.dart';
import 'callout_tail_painter.dart';
import 'hotspot_notification.dart';
import 'hotspot_painter.dart';
import 'paint_bounds_builder.dart';

/// Example of a typical HotspotProvider with actionBuilder handling the
/// progress dots, dismiss button, and next button.
///
/// We recommend setting the bodyWidth to 80% of the viewport width as a default.
///
///
/// ```dart
/// HotspotProvider(
///   curve: Sprung.overDamped,
///   color: Colors.deepPurple.shade800,
///   bodyWidth: min(280.0, MediaQuery.of(context).size.width * 0.8),
///   hotspotShapeBorder: crb.ContinuousRectangleBorder(cornerRadius: 12.0),
///   skrimColor: Colors.black.withOpacity(0.7),
///   child: child,
///   actionBuilder: (_, controller) {
///     return Row(
///       children: [
///         SizedBox(width: 8),
///         FlatButton(
///           child: Text("End tour"),
///           textColor: Colors.white54,
///           onPressed: controller.onDismiss,
///         ),
///         Spacer(flex: 1),
///         Transform.translate(
///           offset: Offset(-8, 0),
///           child: Row(
///             children: [
///               for (var i = 0; i < controller.pages; i++)
///                 AnimatedContainer(
///                   margin: EdgeInsets.all(3),
///                   duration: Duration(milliseconds: 250),
///                   decoration: BoxDecoration(
///                     color: controller.index == i ? Colors.white : Colors.white30,
///                     borderRadius: BorderRadius.circular(99),
///                   ),
///                   height: 6,
///                   width: 6,
///                 ),
///             ],
///           ),
///         ),
///         Spacer(flex: 1),
///         RaisedButton(
///           child: AnimatedCrossFade(
///             crossFadeState: controller.index + 1 < controller.pages
///                 ? CrossFadeState.showFirst
///                 : CrossFadeState.showSecond,
///             duration: Duration(milliseconds: 250),
///             firstChild: Text("Next"),
///             secondChild: Text("Done"),
///           ),
///           color: Colors.deepPurpleAccent,
///           textColor: Colors.white,
///           onPressed: controller.onNext,
///           elevation: 0.0,
///         ),
///         SizedBox(width: 8),
///       ],
///     );
///   },
/// )
/// ```
class HotspotProvider extends StatefulWidget {
  /// Set this to `false` to disable logging
  static var log = true;

  /// Listens for [HotspotTarget]s and provides a scrim with highlighting hotspot
  /// and overlay callout with actions for going to the next [HotspotTarget].
  const HotspotProvider({
    Key? key,
    this.actionBuilder,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.curve = Curves.easeOutQuint,
    this.duration = const Duration(milliseconds: 750),
    this.padding = const EdgeInsets.all(16),
    this.tailInsets = const EdgeInsets.all(-2),
    this.tailSize = const Size(14, 8),
    this.bodyMargin = const EdgeInsets.all(8),
    this.bodyWidth = 322,
    this.skrimColor,
    this.hotspotShapeBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))),
    this.bodyPadding = const EdgeInsets.all(16),
    this.dismissibleSkrim = true,
    this.skrimCurve = Curves.easeOutExpo,
  }) : super(key: key);

  /// The child which contains multiple [HotspotTarget] in the tree.
  final Widget child;

  /// The transition duration for the hotspot and callout.
  final Duration duration;

  /// The transition curve to use for the hotspot and callout.
  final Curve curve;

  /// The hotspot padding.
  final EdgeInsets padding;

  /// The margin between the hotspot and the tail.
  final EdgeInsets tailInsets;

  /// The size of the callout tail.
  final Size tailSize;

  /// The margin between the callout body and the viewport.
  final EdgeInsets bodyMargin;

  /// The color of the callout body and tail.
  final Color? backgroundColor;

  /// The color of text and icons.
  final Color? foregroundColor;

  /// The width of the callout body;
  final double bodyWidth;

  /// The color of the skrim which acts as the background
  /// between the hotspot callout and the view. Provides
  /// hotspot cutouts that surround the appropriate [HotspotTarget].
  final Color? skrimColor;

  /// The shape of the hotspot border.
  final ShapeBorder hotspotShapeBorder;

  /// The padding to apply to the callout body.
  final EdgeInsets bodyPadding;

  /// The actions to build at the bottom of the callout body.
  ///
  /// Localize the default by constructing [HotspotActionBuilder] with new strings
  final CalloutActionBuilder? actionBuilder;

  /// Tapping on the skrim dismisses the flow when `true`.
  final bool dismissibleSkrim;

  /// Curve for the skrim.
  final Curve skrimCurve;

  /// Retreive the ancestor [HotspotProvider] for the purpose of performing actions.
  static HotspotProviderState of(BuildContext context) =>
      Provider.of<HotspotProviderState>(context, listen: false);

  @override
  HotspotProviderState createState() => HotspotProviderState();
}

class HotspotProviderState extends State<HotspotProvider>
    with TickerProviderStateMixin {
  CalloutActionBuilder get actionBuilder =>
      widget.actionBuilder ?? (_, c) => HotspotActionBuilder(c);

  final _targets = <HotspotTargetState>[];

  var _flow = '';
  var _index = 0;
  var _visible = false;

  /// When we start the flow we save the last focus node, dismiss
  /// focus to close the keyboard, and after the tour is done we
  /// put the focus back where it was.
  FocusNode? _lastFocusNode;
  
  final _flowCompleter = Completer();

  /// Convenience getter for the current flow sorted by order.
  List<HotspotTargetState> get currentFlow =>
      _targets.where((e) => e.widget.flow == _flow).toList()
        ..sort((a, b) => a.widget.order.compareTo(b.widget.order));

  /// Initiate a hotspot flow
  Future<void> startFlow([String flow = 'main']) async {
    /// Dismiss keyboard if open
    _lastFocusNode = FocusManager.instance.primaryFocus;
    _lastFocusNode?.unfocus();

    _pruneUnmountedTargets();

    setState(() {
      _flow = flow;
      _index = 0;

      if (currentFlow.isEmpty) {
        if (HotspotProvider.log) {
          debugPrint('[Hotspot] warning, flow dispatched, '
              'but no hotspots found. flow: $flow');
        }
      } else {
        _visible = true;
      }
    });
    
    await _flowCompleter.future;
  }

  /// Called when tapping the next button.
  /// Can be called externally.
  void next() {
    _pruneUnmountedTargets();

    if (_index + 1 < currentFlow.length) {
      setState(() => _index++);
    } else {
      dismiss();
    }
  }

  /// Called when tapping the previous button.
  /// Can be called externally.
  void previous() {
    _pruneUnmountedTargets();

    if (_index >= 1) {
      setState(() => _index--);
    } else {
      dismiss();
    }
  }

  /// Called when tapping the dismiss button.
  /// Can be called externally.
  void dismiss() {
    _pruneUnmountedTargets();

    setState(() => _visible = false);

    _flowCompleter.complete();
    
    /// Put the focus back where it was if we
    /// have a previously-saved focus node.
    _lastFocusNode?.requestFocus();
    _lastFocusNode = null;

    /// don't animate to first tag on subsequent flow runs
    Future.delayed(widget.duration, () {
      if(mounted) {
        setState(() => _index = 0);
      }
    });
  }

  /// Removes all targets that are not mounted
  void _pruneUnmountedTargets() =>
      _targets.removeWhere((e) => e.mounted == false);

  /// Handle new targets as they become available
  void _handleNewTarget(HotspotTargetState e) {
    _targets.add(e);
    _pruneUnmountedTargets();
  }

  Color get bg =>
      widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceBright;

  Color get fg =>
      widget.foregroundColor ?? Theme.of(context).colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    /// Update this index manually to transition between targets
    final currentTarget = currentFlow.isEmpty ? null : currentFlow[_index];

    return Provider<HotspotProviderState>(
      create: (_) => this,
      child: Material(
        child: Stack(
          children: [
            NotificationListener<HotspotNotification>(
              onNotification: (e) {
                if (e.target.mounted) _handleNewTarget(e.target);
                return true;
              },
              child: RepaintBoundary(
                child: widget.child,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _visible == false,
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  curve: widget.skrimCurve,
                  duration: widget.duration,
                  child: () {
                    if (currentTarget == null) {
                      return Container();
                    } else {
                      return PaintBoundsBuilder(
                        builder: (context, paintBounds) {
                          final delegate = CalloutLayoutDelegate(
                            tailSize: widget.tailSize,
                            tailInsets: widget.tailInsets,
                            paintBounds: paintBounds,
                            targetBounds: currentTarget.globalPaintBounds,
                            hotspotPadding: widget.padding,
                            bodyMargin: widget.bodyMargin,
                            bodyWidth: widget.bodyWidth,
                            hotspotSize: currentTarget.widget.hotspotSize,
                            hotspotOffset: currentTarget.widget.hotspotOffset,
                          );

                          return buildHotspotAndCallout(
                            context: context,
                            delegate: delegate,
                            currentTarget: currentTarget,
                          );
                        },
                      );
                    }
                  }(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the hotspot and callout
  Widget buildHotspotAndCallout({
    required BuildContext context,
    required CalloutLayoutDelegate delegate,
    required HotspotTargetState currentTarget,
  }) {
    return Stack(
      children: [
        /// Skrim with hotspot cutout
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.dismissibleSkrim
                ? () {
                    dismiss();
                  }
                : null,
            child: TweenAnimationBuilder<Rect?>(
              curve: widget.curve,
              tween: RectTween(end: delegate.hotspotBounds),
              duration: widget.duration,
              builder: (context, t, child) {
                return CustomPaint(
                  painter: HotspotPainter(
                    hotspotBounds: t!,
                    shapeBorder: widget.hotspotShapeBorder,
                    skrimColor: widget.skrimColor ??
                        Theme.of(context).colorScheme.scrim.withOpacity(0.4),
                  ),
                );
              },
            ),
          ),
        ),

        /// Callout painter
        Positioned.fill(
          child: Stack(
            children: [
              /// Callout tail
              TweenAnimationBuilder<Rect?>(
                curve: widget.curve,
                duration: widget.duration,
                tween: RectTween(
                  end: delegate.tailBounds,
                ),
                builder: (context, t, child) {
                  return CustomPaint(
                    painter: CalloutTailPainter(
                      tailBounds: t!,
                      color: bg,
                    ),
                  );
                },
              ),

              /// Callout body
              TweenAnimationBuilder<Rect?>(
                curve: widget.curve,
                duration: widget.duration,
                tween: RectTween(
                  end: delegate.bodyContainerBounds,
                ),
                builder: (context, t, child) {
                  return Positioned.fromRect(
                    rect: t!,
                    child: AnimatedContainer(
                      curve: widget.curve,
                      duration: widget.duration,
                      height: delegate.bodyContainerHeight,
                      width: delegate.bodyWidth,
                      alignment: delegate.targetIsAboveCenter
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,

                      /// Absorb tap events so we don't dismiss when tapping on the callout body.
                      /// Without this, the tap event is passed through to the skrim GestureDetector
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(color: bg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// Callout body
                              Padding(
                                padding: widget.bodyPadding,
                                child: AnimatedSize(
                                  duration: widget.duration,
                                  alignment: Alignment.topCenter,
                                  curve: widget.curve,
                                  child: currentTarget.widget.calloutBody,
                                ),
                              ),

                              /// Callout controls
                              actionBuilder(
                                context,
                                CalloutActionController(
                                  dismiss: dismiss,
                                  next: next,
                                  previous: previous,
                                  index: _index,
                                  pages: currentFlow.length,
                                  foregroundColor: fg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A function that contains all the data needed to build the
/// action section of a callout body.
typedef CalloutActionBuilder = Widget Function(
    BuildContext context, CalloutActionController controller);

class CalloutActionController {
  /// A stateless controller that passes events back to [HotspotProvider]
  /// while providing key metrics to the builder.
  CalloutActionController({
    required this.dismiss,
    required this.next,
    required this.previous,
    required this.index,
    required this.pages,
    required this.foregroundColor,
  });

  final Color? foregroundColor;

  /// Dismiss the callout.
  final VoidCallback dismiss;

  /// Go to the next [HotspotTarget]
  final VoidCallback next;

  /// Go to the previous [HotspotTarget]
  final VoidCallback previous;

  /// The current target's index.
  final int index;

  /// The total number of targets.
  final int pages;

  /// Convenience getter for if we're currently on the last page.
  bool get isLastPage => index + 1 == pages;

  /// Convenience getter for if we're currently on the first page.
  bool get isFirstPage => index == 0;
}
