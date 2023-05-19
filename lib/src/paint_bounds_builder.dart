import 'package:flutter/widgets.dart';

class PaintBoundsBuilder extends StatefulWidget {
  /// Safely builds the widget when paintBounds of the ancestor are available.
  ///
  /// Downside to this method is it skips one frame while the widget is being laid out
  const PaintBoundsBuilder({Key? key, required this.builder}) : super(key: key);

  /// Builder method to build the widget based on paintBounds
  final Widget Function(BuildContext context, Rect paintBounds) builder;

  @override
  _PaintBoundsBuilderState createState() => _PaintBoundsBuilderState();
}

class _PaintBoundsBuilderState extends State<PaintBoundsBuilder> {
  Rect? _paintBounds;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _paintBounds ??= (context.findRenderObject() as RenderBox).paintBounds;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_paintBounds == null) return Container();
    return widget.builder(context, _paintBounds!);
  }
}
