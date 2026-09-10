import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller keeps presentation expansion by default', () {
    final AdaptiveNavController controller = AdaptiveNavController();

    expect(controller.expanded, isNull);
    expect(controller.hasExpansionOverride, isFalse);

    controller.dispose();
  });

  test('controller changes visibility and expansion independently', () {
    final AdaptiveNavController controller = AdaptiveNavController();
    int notifications = 0;
    controller.addListener(() => notifications++);

    controller.hide();
    expect(controller.visible, isFalse);

    controller.collapse();
    expect(controller.expanded, isFalse);

    controller.show();
    controller.expand();
    expect(controller.visible, isTrue);
    expect(controller.expanded, isTrue);
    expect(notifications, 4);

    controller.clearExpansionOverride();
    expect(controller.expanded, isNull);
    expect(notifications, 5);

    controller.dispose();
  });

  test('setting an existing explicit state does not notify listeners', () {
    final AdaptiveNavController controller = AdaptiveNavController(
      expanded: true,
    );
    int notifications = 0;
    controller.addListener(() => notifications++);

    controller.show();
    controller.expand();

    expect(notifications, 0);
    controller.dispose();
  });

  test('first toggle is relative to the active presentation', () {
    final AdaptiveNavController controller = AdaptiveNavController();

    controller.toggleExpanded(true);
    expect(controller.expanded, isFalse);

    controller.clearExpansionOverride();
    controller.toggleExpanded(false);
    expect(controller.expanded, isTrue);

    controller.dispose();
  });
}
