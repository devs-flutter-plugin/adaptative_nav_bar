import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
  AdaptiveNavDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
  AdaptiveNavDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
  AdaptiveNavDestination(icon: Icon(Icons.swap_horiz), label: 'Trade'),
  AdaptiveNavDestination(icon: Icon(Icons.hub_outlined), label: 'Grow'),
  AdaptiveNavDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
];

void main() {
  testWidgets('Material 3 bottom navigation receives package theme tokens', (
    WidgetTester tester,
  ) async {
    const Color background = Color(0xFF101010);
    const Color indicator = Color(0xFFFFE000);
    NavigationBarThemeData? capturedTheme;

    final List<AdaptiveNavDestination> destinations =
        <AdaptiveNavDestination>[
          AdaptiveNavDestination(
            icon: Builder(
              builder: (BuildContext context) {
                capturedTheme = NavigationBarTheme.of(context);
                return const Icon(Icons.home_outlined);
              },
            ),
            label: 'Home',
          ),
          ..._destinations.skip(1),
        ];

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: destinations,
          compact: const AdaptiveNavPresentation.bottom(),
          theme: const AdaptiveNavThemeData(
            backgroundColor: background,
            indicatorColor: indicator,
            elevation: 7,
            iconSize: 22,
            selectedIconSize: 26,
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(capturedTheme, isNotNull);
    expect(capturedTheme!.backgroundColor, background);
    expect(capturedTheme!.indicatorColor, indicator);
    expect(capturedTheme!.elevation, 7);
    expect(tester.takeException(), isNull);
  });

  testWidgets('raised destination inherits package theme tokens', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    const Color indicator = Color(0xFFFFE000);
    const Color selected = Color(0xFF111111);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScaffold(
          selectedIndex: 2,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.centerRaised,
          ),
          theme: const AdaptiveNavThemeData(
            indicatorColor: indicator,
            selectedColor: selected,
            selectedIconSize: 30,
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder raisedVisual = find.byKey(
      const ValueKey<String>('adaptive-raised-visual'),
    );
    final Material material = tester.widget<Material>(raisedVisual);
    expect(material.color, indicator);
    expect(material.elevation, 10);

    final Finder iconTheme = find.descendant(
      of: raisedVisual,
      matching: find.byType(IconTheme),
    );
    final IconThemeData iconData = tester.widget<IconTheme>(iconTheme.first).data;
    expect(iconData.color, selected);
    expect(iconData.size, 30);
    expect(tester.takeException(), isNull);
  });

  testWidgets('standard style configs control their own geometry', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _app(
        const AdaptiveNavPresentation.bottom(
          bottomStyle: AdaptiveBottomNavStyle.pill,
          styleConfig: AdaptivePillNavStyleConfig(
            barHeight: 70,
            horizontalMargin: 20,
            bottomMargin: 6,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder surface = find.byKey(
      const ValueKey<String>('adaptive-bottom-surface'),
    );
    expect(tester.getSize(surface).width, closeTo(350, 0.5));

    await tester.pumpWidget(
      _app(
        const AdaptiveNavPresentation.bottom(
          bottomStyle: AdaptiveBottomNavStyle.glass,
          styleConfig: AdaptiveGlassNavStyleConfig(
            barHeight: 74,
            horizontalMargin: 14,
            bottomMargin: 10,
            borderRadius: 24,
            blurSigma: 12,
            surfaceOpacity: 0.8,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(surface).width, closeTo(362, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stylish bubble uses its active flex token', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    const List<AdaptiveNavDestination> destinations = <AdaptiveNavDestination>[
      AdaptiveNavDestination(icon: Icon(Icons.home), label: 'Home'),
      AdaptiveNavDestination(icon: Icon(Icons.search), label: 'Search'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.stylish,
            styleConfig: AdaptiveStylishNavStyleConfig(
              variant: AdaptiveStylishVariant.bubble,
              bubbleActiveFlex: 2,
            ),
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.byIcon(Icons.search)).dx, greaterThan(310));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion reaches sidebar internal animations', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: AdaptiveNavScaffold(
            selectedIndex: 0,
            destinations: _destinations,
            expanded: const AdaptiveNavPresentation.sidebar(),
            onDestinationSelected: (_) {},
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();

    final Iterable<AnimatedRotation> rotations =
        tester.widgetList<AnimatedRotation>(find.byType(AnimatedRotation));
    expect(rotations, isNotEmpty);
    expect(
      rotations.every(
        (AnimatedRotation item) => item.duration == Duration.zero,
      ),
      isTrue,
    );

    final Iterable<AnimatedContainer> containers =
        tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(containers, isNotEmpty);
    expect(
      containers.every(
        (AnimatedContainer item) => item.duration == Duration.zero,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _app(AdaptiveNavPresentation compact) {
  return MaterialApp(
    home: AdaptiveNavScaffold(
      selectedIndex: 2,
      destinations: _destinations,
      compact: compact,
      onDestinationSelected: (_) {},
      body: const SizedBox.expand(),
    ),
  );
}
