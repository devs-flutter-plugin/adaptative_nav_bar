import 'package:flutter/foundation.dart';

/// Window-size classes used by [AdaptiveNavScaffold].
enum AdaptiveNavWindowClass {
  /// Compact layouts, normally phones and narrow windows.
  compact,

  /// Medium layouts, normally tablets and medium-width windows.
  medium,

  /// Expanded layouts, normally desktop, web, and wide windows.
  expanded,
}

/// Width breakpoints used to choose an adaptive navigation presentation.
@immutable
class AdaptiveNavBreakpoints {
  /// Creates breakpoint values.
  ///
  /// The defaults follow the common Material window-size transition points:
  /// compact below 600 logical pixels, medium from 600 to 839, and expanded
  /// from 840 logical pixels.
  const AdaptiveNavBreakpoints({
    this.compactEnd = 600,
    this.mediumEnd = 840,
  }) : assert(compactEnd > 0),
       assert(mediumEnd > compactEnd);

  /// Exclusive upper bound for compact layouts.
  final double compactEnd;

  /// Exclusive upper bound for medium layouts.
  final double mediumEnd;

  /// Returns the window class for [width].
  AdaptiveNavWindowClass classify(double width) {
    if (width < compactEnd) {
      return AdaptiveNavWindowClass.compact;
    }
    if (width < mediumEnd) {
      return AdaptiveNavWindowClass.medium;
    }
    return AdaptiveNavWindowClass.expanded;
  }
}
