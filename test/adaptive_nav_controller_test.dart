import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    controller.dispose();
  });

  test('setting an existing state does not notify listeners', () {
    final AdaptiveNavController controller = AdaptiveNavController();
    int notifications = 0;
    controller.addListener(() => notifications++);

    controller.show();
    controller.expand();

    expect(notifications, 0);
    controller.dispose();
  });
}
