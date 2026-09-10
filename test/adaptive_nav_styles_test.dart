import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
  AdaptiveNavDestination(icon: Icon(Icons.home), label: 'Home'),
  AdaptiveNavDestination(icon: Icon(Icons.search), label: 'Search'),
];

void main() {
  for (final AdaptiveBottomNavStyle style in AdaptiveBottomNavStyle.values) {
    testWidgets('bottom style ${style.name} renders and is interactive', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(500, 800));
      int selected = 0;

      await tester.pumpWidget(
        _testApp(
          builder: (StateSetter setState) => AdaptiveNavScaffold(
            selectedIndex: selected,
            destinations: _destinations,
            compact: AdaptiveNavPresentation.bottom(bottomStyle: style),
            onDestinationSelected: (int index) {
              setState(() => selected = index);
            },
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  }

  for (final AdaptiveRailStyle style in AdaptiveRailStyle.values) {
    testWidgets('rail style ${style.name} renders and is interactive', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(700, 800));
      int selected = 0;

      await tester.pumpWidget(
        _testApp(
          builder: (StateSetter setState) => AdaptiveNavScaffold(
            selectedIndex: selected,
            destinations: _destinations,
            medium: AdaptiveNavPresentation.rail(railStyle: style),
            onDestinationSelected: (int index) {
              setState(() => selected = index);
            },
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  }

  for (final AdaptiveSidebarStyle style in AdaptiveSidebarStyle.values) {
    testWidgets('sidebar style ${style.name} renders and is interactive', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(1200, 800));
      int selected = 0;

      await tester.pumpWidget(
        _testApp(
          builder: (StateSetter setState) => AdaptiveNavScaffold(
            selectedIndex: selected,
            destinations: _destinations,
            expanded: AdaptiveNavPresentation.sidebar(
              sidebarStyle: style,
              extended: true,
            ),
            onDestinationSelected: (int index) {
              setState(() => selected = index);
            },
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  }
}

Widget _testApp({required Widget Function(StateSetter setState) builder}) {
  return MaterialApp(
    home: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return builder(setState);
      },
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
