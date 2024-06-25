# hotspot

The simplest way to make beautiful tours, coachmarks, and tutorials.

<img alt="demo of under, critically, and over damped Flutter curves" src="https://raw.githubusercontent.com/lukepighetti/flutter_hotspot/master/doc/demo.gif" width="400">

Wrap your app, screen, or view with `HotspotProvider`

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HotspotProvider(
      child: Scaffold(
        body: // ...
      ),
    );
  }
}
```

Add hotspot callouts to your widget tree

```dart
class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.play_arrow),
      onPressed: () {
        // ...
      },
    ).withHotspot(
      order: 1,
      title: 'Tour It!',
      text: 'This is the first callout in the tour!',
    );
  }
}
```

Start a flow

```dart
HotspotProvider.of(context).startFlow()
```