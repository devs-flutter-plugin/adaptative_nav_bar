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

  testWidgets('google style gives the selected tab real extra row width', (
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
            styleConfig: AdaptiveGoogleNavStyleConfig(
              activeFlex: 2,
              inactiveFlex: 1,
            ),
          ),
          onDestinationSelected: (int index) {
            setState(() => selected = index);
          },
          body: const SizedBox.expand(),
        ),
      ),
    );

    final Finder homeSlot = find.byKey(
      const ValueKey<String>('google-slot-0'),
    );
    final Finder searchSlot = find.byKey(
      const ValueKey<String>('google-slot-1'),
    );
    expect(tester.getSize(homeSlot).width, greaterThan(tester.getSize(searchSlot).width));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsNothing);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(tester.getSize(searchSlot).width, greaterThan(tester.getSize(homeSlot).width));
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('persistent style uses the reference 2 to 1 selected slot ratio', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(390, 800));

    await tester.pumpWidget(
      _testApp(
        builder: (StateSetter setState) => AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.persistent,
            styleConfig: AdaptivePersistentNavStyleConfig(
              activeFlex: 2,
              inactiveFlex: 1,
            ),
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final double activeWidth = tester
        .getSize(find.byKey(const ValueKey<String>('persistent-slot-0')))
        .width;
    final double inactiveWidth = tester
        .getSize(find.byKey(const ValueKey<String>('persistent-slot-1')))
        .width;
    expect(activeWidth / inactiveWidth, closeTo(2, 0.02));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notch selected button is centered exactly on its destination slot', (
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
            styleConfig: AdaptiveNotchNavStyleConfig(horizontalMargin: 12),
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final Finder notchButton = find.byKey(
      const ValueKey<String>('adaptive-notch-button'),
    );
    final double centerX = tester.getCenter(notchButton).dx;
    final double homeY = tester.getCenter(find.byIcon(Icons.home_outlined)).dy;
    final double tradeY = tester.getCenter(find.byIcon(Icons.swap_horiz)).dy;

    expect(centerX, closeTo(195, 0.5));
    expect(tradeY, lessThan(homeY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('centerRaised keeps the primary destination fixed at screen center', (
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
      ),
    );

    final Finder raisedButton = find.byKey(
      const ValueKey<String>('adaptive-raised-button'),
    );
    final double homeY = tester.getCenter(find.byIcon(Icons.home_outlined)).dy;
    final double tradeY = tester.getCenter(find.byIcon(Icons.swap_horiz)).dy;

    expect(tester.getCenter(raisedButton).dx, closeTo(195, 0.5));
    expect(tradeY, lessThan(homeY));

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('raised item composes with google geometry without overflow', (
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

  testWidgets('stylish animated variant lifts the selected icon', (
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
            styleConfig: AdaptiveStylishNavStyleConfig(
              variant: AdaptiveStylishVariant.animated,
            ),
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

  testWidgets('stylish dot variant renders only the selected marker', (
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
            styleConfig: AdaptiveStylishNavStyleConfig(
              variant: AdaptiveStylishVariant.dot,
              dotStyle: AdaptiveStylishDotStyle.tile,
            ),
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    final Size selectedIndicator = tester.getSize(
      find.byKey(const ValueKey<String>('stylish-indicator-Home')),
    );
    final Size inactiveIndicator = tester.getSize(
      find.byKey(const ValueKey<String>('stylish-indicator-Search')),
    );
    expect(selectedIndicator.width, greaterThan(0));
    expect(inactiveIndicator.width, 0);
    expect(tester.takeException(), isNull);
  });

  for (final AdaptiveStylishVariant variant in AdaptiveStylishVariant.values) {
    testWidgets('stylish ${variant.name} supports five tabs at 320 px', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(320, 800));

      await tester.pumpWidget(
        _testApp(
          builder: (StateSetter setState) => AdaptiveNavScaffold(
            selectedIndex: 2,
            destinations: _fiveDestinations,
            compact: AdaptiveNavPresentation.bottom(
              bottomStyle: AdaptiveBottomNavStyle.stylish,
              styleConfig: AdaptiveStylishNavStyleConfig(variant: variant),
            ),
            onDestinationSelected: (_) {},
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
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
