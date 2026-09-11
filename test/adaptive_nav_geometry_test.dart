import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
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
  const List<AdaptiveBottomNavStyle> fullWidthStyles = <AdaptiveBottomNavStyle>[
    AdaptiveBottomNavStyle.bubble,
    AdaptiveBottomNavStyle.minimal,
    AdaptiveBottomNavStyle.persistent,
    AdaptiveBottomNavStyle.google,
    AdaptiveBottomNavStyle.stylish,
    AdaptiveBottomNavStyle.centerRaised,
  ];

  for (final AdaptiveBottomNavStyle style in fullWidthStyles) {
    testWidgets('${style.name} fills the compact viewport horizontally', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(390, 800));
      await tester.pumpWidget(_app(style: style, selectedIndex: 2));
      await tester.pumpAndSettle();

      final Size surface = tester.getSize(
        find.byKey(const ValueKey<String>('adaptive-bottom-surface')),
      );
      expect(surface.width, closeTo(390, 0.5));
      expect(tester.takeException(), isNull);
    });
  }

  const Map<AdaptiveBottomNavStyle, double> insetWidths =
      <AdaptiveBottomNavStyle, double>{
        AdaptiveBottomNavStyle.floating: 358,
        AdaptiveBottomNavStyle.pill: 370,
        AdaptiveBottomNavStyle.notch: 366,
        AdaptiveBottomNavStyle.glass: 366,
      };

  for (final MapEntry<AdaptiveBottomNavStyle, double> entry
      in insetWidths.entries) {
    testWidgets('${entry.key.name} keeps only its intentional outer inset', (
      WidgetTester tester,
    ) async {
      await _setSurface(tester, const Size(390, 800));
      await tester.pumpWidget(_app(style: entry.key, selectedIndex: 2));
      await tester.pumpAndSettle();

      final Size surface = tester.getSize(
        find.byKey(const ValueKey<String>('adaptive-bottom-surface')),
      );
      expect(surface.width, closeTo(entry.value, 0.5));
      expect(tester.takeException(), isNull);
    });
  }

  for (final AdaptiveBottomNavStyle style in AdaptiveBottomNavStyle.values) {
    for (final int selectedIndex in <int>[0, 2, 4]) {
      testWidgets(
        '${style.name} keeps first/middle/last selections inside 320 px',
        (WidgetTester tester) async {
          await _setSurface(tester, const Size(320, 800));
          await tester.pumpWidget(
            _app(style: style, selectedIndex: selectedIndex),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'google and persistent weighted slots remain inside the surface',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(320, 800));

      for (final AdaptiveBottomNavStyle style in <AdaptiveBottomNavStyle>[
        AdaptiveBottomNavStyle.google,
        AdaptiveBottomNavStyle.persistent,
      ]) {
        await tester.pumpWidget(_app(style: style, selectedIndex: 4));
        await tester.pumpAndSettle();

        final Rect surfaceRect = tester.getRect(
          find.byKey(const ValueKey<String>('adaptive-bottom-surface')),
        );
        final String prefix = style == AdaptiveBottomNavStyle.google
            ? 'google-slot'
            : 'persistent-slot';
        final Rect first = tester.getRect(
          find.byKey(ValueKey<String>('$prefix-0')),
        );
        final Rect last = tester.getRect(
          find.byKey(ValueKey<String>('$prefix-4')),
        );

        expect(first.left, greaterThanOrEqualTo(surfaceRect.left - 0.5));
        expect(last.right, lessThanOrEqualTo(surfaceRect.right + 0.5));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'raised middle destination stays centered and protrudes above the surface',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(390, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavScaffold(
            selectedIndex: 2,
            destinations: _destinations,
            compact: const AdaptiveNavPresentation.bottom(
              bottomStyle: AdaptiveBottomNavStyle.centerRaised,
              raisedItem: AdaptiveRaisedNavItem(
                index: 2,
                size: 60,
                offset: 28,
                elevation: 10,
              ),
            ),
            onDestinationSelected: (_) {},
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder surface = find.byKey(
        const ValueKey<String>('adaptive-bottom-surface'),
      );
      final Finder button = find.byKey(
        const ValueKey<String>('adaptive-raised-button'),
      );
      final Rect surfaceRect = tester.getRect(surface);
      final Rect buttonRect = tester.getRect(button);

      expect(tester.getCenter(button).dx, closeTo(195, 0.5));
      expect(buttonRect.top, closeTo(surfaceRect.top - 28, 0.5));
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app({
  required AdaptiveBottomNavStyle style,
  required int selectedIndex,
}) {
  return MaterialApp(
    home: AdaptiveNavScaffold(
      selectedIndex: selectedIndex,
      destinations: _destinations,
      compact: AdaptiveNavPresentation.bottom(bottomStyle: style),
      onDestinationSelected: (_) {},
      body: const SizedBox.expand(),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
