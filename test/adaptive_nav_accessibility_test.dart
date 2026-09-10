import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
  AdaptiveNavDestination(
    icon: Icon(Icons.home),
    label: 'Home',
    semanticLabel: 'Home destination',
  ),
  AdaptiveNavDestination(
    icon: Icon(Icons.search),
    label: 'Search',
    semanticLabel: 'Search destination',
  ),
  AdaptiveNavDestination(
    icon: Icon(Icons.person),
    label: 'Profile',
    semanticLabel: 'Profile destination',
  ),
];

void main() {
  testWidgets('custom bottom styles expose destination semantics', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    final SemanticsHandle semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: _destinations,
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.notch,
          ),
          onDestinationSelected: (_) {},
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Home destination'), findsOneWidget);
    expect(find.bySemanticsLabel('Search destination'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile destination'), findsOneWidget);
  });

  testWidgets('renders at large text scale without exceptions', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: AdaptiveNavScaffold(
            selectedIndex: 0,
            destinations: _destinations,
            compact: const AdaptiveNavPresentation.bottom(
              bottomStyle: AdaptiveBottomNavStyle.floating,
            ),
            onDestinationSelected: (_) {},
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports RTL layout without exceptions', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(1200, 800));

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: AdaptiveNavScaffold(
            selectedIndex: 0,
            destinations: _destinations,
            expanded: const AdaptiveNavPresentation.sidebar(
              sidebarStyle: AdaptiveSidebarStyle.collapsible,
              extended: true,
            ),
            onDestinationSelected: (_) {},
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
