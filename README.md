# hotspot

An interactivity & developer experience experiment for building easy tours.

Extensions look like callouts. Common tour flows look like callouts. So let's use them both so the code looks like the tours.

```dart
class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.play_arrow),
      onPressed: () {
        HotspotProvider.of(context).startFlow();
      },
    ).withHotspot(
      order: 1,
      title: 'Tour It!',
      text: 'This is the first callout in the tour!',
    );
  }
}
```
