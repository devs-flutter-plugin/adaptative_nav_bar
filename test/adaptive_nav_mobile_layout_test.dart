import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations =
    <AdaptiveNavDestination>[
      AdaptiveNavDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      AdaptiveNavDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
      AdaptiveNavDestination(icon: Icon(Icons.swap_horiz), label: 'Trade'),
      AdaptiveNavDestination(icon: Icon(Icons.hub_outlined), label: 'Grow'),
      AdaptiveNavDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        label: 'Assets',
        badge: Text('3'),
      ),
    ];

void main() {
  for (final double width in <double>[320, 360, 390]) {
    for (final AdaptiveBottomNavStyle style in AdaptiveBottomNavStyle.values) {
      testWidgets('${style.name} supports five destinations at ${width.toInt()} px', (
        WidgetTester tester,
      ) async {
        await _setSurface(tester, Size(width, 800));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveNavScaffold(
                selectedIndex: 2,
                destinations: _destinations,
                compact: AdaptiveNavPresentation.bottom(bottomStyle: style),
                onDestinationSelected: (_) {},
                body: const SizedBox.expand(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('raised primary item remains usable on a 320 px viewport', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(320, 800));
    int selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: AdaptiveNavScaffold(
                selectedIndex: selected,
                destinations: _destinations,
                compact: const AdaptiveNavPresentation.bottom(
                  bottomStyle: AdaptiveBottomNavStyle.centerRaised,
                  raisedItem: AdaptiveRaisedNavItem(
                    index: 2,
                    size: 60,
                    offset: 20,
                  ),
                ),
                onDestinationSelected: (int index) {
                  setState(() => selected = index);
                },
                body: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();

    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
