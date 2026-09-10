import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const List<AdaptiveNavDestination> _destinations = <AdaptiveNavDestination>[
  AdaptiveNavDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  AdaptiveNavDestination(
    icon: Icon(Icons.search_outlined),
    selectedIcon: Icon(Icons.search),
    label: 'Search',
  ),
  AdaptiveNavDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
  ),
];

void main() {
  testWidgets('uses Material NavigationBar in compact windows', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    await tester.pumpWidget(_testApp(onSelected: (_) {}));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses NavigationRail in medium windows', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(700, 800));
    await tester.pumpWidget(_testApp(onSelected: (_) {}));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('uses collapsible sidebar in expanded windows', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(1200, 800));
    await tester.pumpWidget(_testApp(onSelected: (_) {}));

    expect(find.byTooltip('Collapse navigation'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('reports selection without owning navigation state', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    int? selected;
    await tester.pumpWidget(
      _testApp(onSelected: (int index) => selected = index),
    );

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(selected, 1);
  });

  testWidgets('reports a destination reselect separately', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    int? reselected;
    await tester.pumpWidget(
      _testApp(
        onSelected: (_) {},
        onReselected: (int index) => reselected = index,
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(reselected, 0);
  });

  testWidgets('can swap compact styles without changing destinations', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    await tester.pumpWidget(
      _testApp(
        onSelected: (_) {},
        compact: const AdaptiveNavPresentation.bottom(
          bottomStyle: AdaptiveBottomNavStyle.notch,
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('custom presentation receives the stable config contract', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(500, 800));
    AdaptiveNavBarConfig? received;
    await tester.pumpWidget(
      _testApp(
        onSelected: (_) {},
        compact: AdaptiveNavPresentation.custom(
          builder: (BuildContext context, AdaptiveNavBarConfig config) {
            received = config;
            return const SizedBox(height: 56, child: Text('Custom nav'));
          },
        ),
      ),
    );

    expect(find.text('Custom nav'), findsOneWidget);
    expect(received?.selectedIndex, 0);
    expect(received?.destinations.length, 3);
    expect(received?.windowClass, AdaptiveNavWindowClass.compact);
  });
}

Widget _testApp({
  required ValueChanged<int> onSelected,
  ValueChanged<int>? onReselected,
  AdaptiveNavPresentation compact = const AdaptiveNavPresentation.bottom(),
}) {
  return MaterialApp(
    home: Scaffold(
      body: AdaptiveNavScaffold(
        destinations: _destinations,
        selectedIndex: 0,
        onDestinationSelected: onSelected,
        onDestinationReselected: onReselected,
        compact: compact,
        body: const ColoredBox(color: Color(0xFFFFFFFF)),
      ),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
