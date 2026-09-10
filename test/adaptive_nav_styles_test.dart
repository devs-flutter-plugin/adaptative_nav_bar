import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
  AdaptiveNavDestination(icon: Icon(Icons.home), label: 'Home'),
  AdaptiveNavDestination(icon: Icon(Icons.search), label: 'Search'),
];

const List<AdaptiveNavDestination> _fiveDestinations =
    <AdaptiveNavDestination>[
      AdaptiveNavDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      AdaptiveNavDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
      AdaptiveNavDestination(icon: Icon(Icons.swap_horiz), label: 'Trade'),
      AdaptiveNavDestination(icon: Icon(Icons.hub_outlined), label: 'Grow'),
      AdaptiveNavDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        label: 'Assets',
      ),
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
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('google style reveals only the selected destination label', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));
    int selected = 0;

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: selected,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.google,
          ),
          onDestinationSelected: (int index) {
            setState(() => selected = index);
          },
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsNothing);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('persistent style expands selected label only', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));
    int selected = 0;

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: selected,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.persistent,
          ),
          onDestinationSelected: (int index) {
            setState(() => selected = index);
          },
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsNothing);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notch raises the selected destination above inactive items', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: 2,
          destinations: _fiveDestinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.notch,
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final double homeY = tester.getCenter(find.byIcon(Icons.home_outlined)).dy;
    final double tradeY = tester.getCenter(find.byIcon(Icons.swap_horiz)).dy;
    expect(tradeY, lessThan(homeY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('centerRaised keeps the middle destination above the base row', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));
    int selected = 0;

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: selected,
          destinations: _fiveDestinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.centerRaised,
          ),
          onDestinationSelected: (int index) {
            setState(() => selected = index);
          },
          body: const SizedBox.expand(),
        ),
      ),
    );

    final double homeY = tester.getCenter(find.byIcon(Icons.home_outlined)).dy;
    final double tradeY = tester.getCenter(find.byIcon(Icons.swap_horiz)).dy;
    expect(tradeY, lessThan(homeY));

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('raised item can be composed with google style', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: _fiveDestinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.google,
            raisedItem: AdaptiveRaisedNavItem(index: 2),
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final double homeY = tester.getCenter(find.byIcon(Icons.home_outlined)).dy;
    final double tradeY = tester.getCenter(find.byIcon(Icons.swap_horiz)).dy;
    expect(tradeY, lessThan(homeY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('stylish style lifts the selected icon', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.stylish,
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final double homeY = tester.getCenter(find.byIcon(Icons.home)).dy;
    final double searchY = tester.getCenter(find.byIcon(Icons.search)).dy;
    expect(homeY, lessThan(searchY));
    expect(tester.takeException(), isNull);
  });

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
