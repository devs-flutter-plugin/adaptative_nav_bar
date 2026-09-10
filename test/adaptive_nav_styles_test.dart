import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final AdaptiveBottomNavStyle style in AdaptiveBottomNavStyle.values) {
    testWidgets('bottom style ${style.name} renders and is interactive', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(500, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AdaptiveNavScaffold(
                selectedIndex: selected,
                destinations: const <AdaptiveNavDestination>[
                  AdaptiveNavDestination(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  AdaptiveNavDestination(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                ],
                compact: AdaptiveNavPresentation.bottom(bottomStyle: style),
                onDestinationSelected: (int index) {
                  setState(() => selected = index);
                },
                body: const SizedBox.expand(),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  }
}
