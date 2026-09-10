import 'package:material_ui/material_ui.dart';

/// Controls scroll-driven visibility changes for navigation surfaces.
@immutable
class AdaptiveNavScrollBehavior {
  /// Creates scroll behavior configuration.
  const AdaptiveNavScrollBehavior({
    this.hideOnScroll = false,
    this.deltaThreshold = 8,
    this.showAtStart = true,
    this.showOnScrollEnd = false,
    this.notificationPredicate,
  }) : assert(deltaThreshold >= 0);

  /// Whether positive scroll deltas hide and negative deltas show navigation.
  final bool hideOnScroll;

  /// Minimum absolute delta that can toggle visibility.
  final double deltaThreshold;

  /// Whether reaching the leading boundary forces navigation visible.
  final bool showAtStart;

  /// Whether the navigation surface is shown when scrolling stops.
  final bool showOnScrollEnd;

  /// Optional filter for descendant [ScrollNotification] objects.
  final bool Function(ScrollNotification notification)? notificationPredicate;
}
