import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('hideOnScroll hides forward and shows on reverse scroll', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(500, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final AdaptiveNavController controller = AdaptiveNavController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScaffold(
          selectedIndex: 0,
          destinations: const <AdaptiveNavDestination>[
            AdaptiveNavDestination(icon: Icon(Icons.home), label: 'Home'),
            AdaptiveNavDestination(icon: Icon(Icons.search), label: 'Search'),
          ],
          compact: const AdaptiveNavPresentation.bottom(
            bottomStyle: AdaptiveBottomNavStyle.floating,
          ),
          controller: controller,
          scrollBehavior: const AdaptiveNavScrollBehavior(
            hideOnScroll: true,
            deltaThreshold: 1,
          ),
          onDestinationSelected: (_) {},
          body: ListView.builder(
            itemCount: 40,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(height: 80, child: Text('Item $index'));
            },
          ),
        ),
      ),
    );

    expect(controller.visible, isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(controller.visible, isFalse);

    await tester.drag(find.byType(ListView), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(controller.visible, isTrue);
  });
}
