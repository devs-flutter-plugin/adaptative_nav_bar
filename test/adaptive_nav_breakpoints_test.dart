import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default breakpoints classify compact, medium and expanded widths', () {
    const AdaptiveNavBreakpoints breakpoints = AdaptiveNavBreakpoints();

    expect(breakpoints.classify(599), AdaptiveNavWindowClass.compact);
    expect(breakpoints.classify(600), AdaptiveNavWindowClass.medium);
    expect(breakpoints.classify(839), AdaptiveNavWindowClass.medium);
    expect(breakpoints.classify(840), AdaptiveNavWindowClass.expanded);
  });
}
