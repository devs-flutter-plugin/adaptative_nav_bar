import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_breakpoints.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_theme.dart';

/// Immutable configuration passed to custom navigation builders.
@immutable
class AdaptiveNavBarConfig {
  /// Creates a custom navigation builder configuration.
  const AdaptiveNavBarConfig({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.windowClass,
    required this.theme,
    required this.expanded,
    required this.visible,
  });

  /// Destinations rendered by the current navigation surface.
  final List<AdaptiveNavDestination> destinations;

  /// Selected destination index.
  final int selectedIndex;

  /// Callback custom surfaces must invoke to request selection.
  final ValueChanged<int> onDestinationSelected;

  /// Current window-size class.
  final AdaptiveNavWindowClass windowClass;

  /// Resolved package theme.
  final AdaptiveNavThemeData theme;

  /// Whether a collapsible presentation is expanded.
  final bool expanded;

  /// Whether the current navigation surface is visible.
  final bool visible;
}

/// Builder used by [AdaptiveNavPresentation.custom].
typedef AdaptiveNavBarBuilder = Widget Function(
  BuildContext context,
  AdaptiveNavBarConfig config,
);
