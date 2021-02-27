import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot/hotspot.dart';

void main() {
  group('hotspot', () {
    testWidgets('builds _HotspotTestScreen', (tester) async {
      /// Initial pump to load the navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HotspotTestScreen(),
          ),
        ),
      );

      /// Initial state
      await tester.pumpAndSettle();
      await expectLater(find.byType(HotspotTestScreen),
          matchesGoldenFile('goldens/HotspotTestScreen1.png'));

      /// Start main flow
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await expectLater(find.byType(HotspotTestScreen),
          matchesGoldenFile('goldens/HotspotTestScreen2.png'));

      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('End tour'), findsOneWidget);

      /// End tour dismisses
      await tester.tap(find.text('End tour'));
      await tester.pumpAndSettle();
      await expectLater(find.byType(HotspotTestScreen),
          matchesGoldenFile('goldens/HotspotTestScreen3.png'));

      /// Start main flow again, then tap Next
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await expectLater(find.byType(HotspotTestScreen),
          matchesGoldenFile('goldens/HotspotTestScreen4.png'));

      expect(find.text('Title 2'), findsOneWidget);

      /// tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await expectLater(find.byType(HotspotTestScreen),
          matchesGoldenFile('goldens/HotspotTestScreen5.png'));

      /// Start secondary flow
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      // await takeGoldenSnapshot('test1/6');

      expect(find.text('Title 3'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('End tour'), findsOneWidget);

      /// Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      // await takeGoldenSnapshot('test1/7');
      expect(find.text('Title 4'), findsOneWidget);
    });
  });
}

class HotspotTestScreen extends StatelessWidget {
  static final mainFlowKey = 'main';
  static final secondaryFlowKey = 'secondary';

  @override
  Widget build(BuildContext context) {
    return HotspotProvider(
      bodyWidth: 322,
      dismissibleSkrim: true,
      curve: Curves.easeInOut,
      color: Colors.purple,
      bodyPadding: EdgeInsets.all(24),
      skrimColor: Colors.black54,
      hotspotShapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      actionBuilder: (_, controller) {
        return HotspotActionBuilder(controller);
      },
      child: Scaffold(
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                /// Main, Top left, 1
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Text('1'),
                    onPressed: () =>
                        HotspotProvider.of(context).startFlow(mainFlowKey),
                  ).withHotspot(
                    flow: mainFlowKey,
                    order: 1,
                    title: 'Title 1',
                    text: 'Text 1',
                  ),
                ),

                /// Main, Top right, 2
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Text('2'),
                    onPressed: () =>
                        HotspotProvider.of(context).startFlow(mainFlowKey),
                  ).withHotspot(
                    flow: mainFlowKey,
                    order: 2,
                    title: 'Title 2',
                    text: 'Text 2',
                  ),
                ),

                /// Secondary, Bottom right, 3
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: IconButton(
                    icon: Text('3'),
                    onPressed: () =>
                        HotspotProvider.of(context).startFlow(secondaryFlowKey),
                  ).withHotspot(
                    flow: secondaryFlowKey,
                    order: 3,
                    title: 'Title 3',
                    text: 'Text 3',
                  ),
                ),

                /// Secondary, Bottom left, 4
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: IconButton(
                    icon: Text('4'),
                    onPressed: () =>
                        HotspotProvider.of(context).startFlow(secondaryFlowKey),
                  ).withHotspot(
                    flow: secondaryFlowKey,
                    order: 4,
                    title: 'Title 4',
                    text: 'Text 4',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
