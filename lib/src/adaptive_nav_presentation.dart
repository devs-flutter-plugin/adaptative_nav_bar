import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';

/// Built-in bottom navigation visual variants.
enum AdaptiveBottomNavStyle {
  /// Flutter Material 3 [NavigationBar].
  material3,

  /// Floating rounded surface.
  floating,

  /// Compact capsule/pill navigation.
  pill,

  /// Animated selected item with a raised notch treatment.
  notch,

  /// Selected destination expands into a bubble-like indicator.
  bubble,

  /// Translucent blurred floating surface.
  glass,

  /// Minimal icon/label navigation without a persistent background surface.
  minimal,
}

/// Built-in rail visual variants.
enum AdaptiveRailStyle {
  /// Flutter Material 3 [NavigationRail].
  material3,

  /// Material rail with a stronger selection indicator.
  indicator,

  /// Compact custom rail with labels shown for the selected item only.
  compact,
}

/// Built-in sidebar visual variants.
enum AdaptiveSidebarStyle {
  /// Material-like sidebar surface.
  material3,

  /// Collapsible sidebar inspired by modern desktop navigation.
  collapsible,

  /// Low-chrome sidebar with compact destination rows.
  minimal,
}

/// High-level navigation layout selected for a window-size class.
enum AdaptiveNavPresentationType {
  /// Bottom navigation.
  bottom,

  /// Navigation rail.
  rail,

  /// Persistent sidebar.
  sidebar,

  /// User-supplied navigation builder.
  custom,
}

/// Describes one adaptive navigation presentation.
@immutable
class AdaptiveNavPresentation {
  /// Creates a bottom presentation.
  const AdaptiveNavPresentation.bottom({
    this.bottomStyle = AdaptiveBottomNavStyle.material3,
    this.maxWidth,
    this.reserveBodySpace = true,
  }) : type = AdaptiveNavPresentationType.bottom,
       railStyle = AdaptiveRailStyle.material3,
       sidebarStyle = AdaptiveSidebarStyle.material3,
       extended = false,
       width = 280,
       collapsedWidth = 80,
       builder = null,
       axis = Axis.horizontal;

  /// Creates a rail presentation.
  const AdaptiveNavPresentation.rail({
    this.railStyle = AdaptiveRailStyle.material3,
    this.extended = false,
    this.width = 80,
  }) : type = AdaptiveNavPresentationType.rail,
       bottomStyle = AdaptiveBottomNavStyle.material3,
       sidebarStyle = AdaptiveSidebarStyle.material3,
       collapsedWidth = 80,
       maxWidth = null,
       reserveBodySpace = true,
       builder = null,
       axis = Axis.vertical;

  /// Creates a persistent sidebar presentation.
  const AdaptiveNavPresentation.sidebar({
    this.sidebarStyle = AdaptiveSidebarStyle.collapsible,
    this.extended = true,
    this.width = 280,
    this.collapsedWidth = 80,
  }) : type = AdaptiveNavPresentationType.sidebar,
       bottomStyle = AdaptiveBottomNavStyle.material3,
       railStyle = AdaptiveRailStyle.material3,
       maxWidth = null,
       reserveBodySpace = true,
       builder = null,
       axis = Axis.vertical;

  /// Creates a custom presentation.
  const AdaptiveNavPresentation.custom({
    required this.builder,
    this.axis = Axis.horizontal,
    this.reserveBodySpace = true,
  }) : type = AdaptiveNavPresentationType.custom,
       bottomStyle = AdaptiveBottomNavStyle.material3,
       railStyle = AdaptiveRailStyle.material3,
       sidebarStyle = AdaptiveSidebarStyle.material3,
       extended = false,
       width = 280,
       collapsedWidth = 80,
       maxWidth = null;

  /// Presentation family.
  final AdaptiveNavPresentationType type;

  /// Bottom visual style when [type] is [AdaptiveNavPresentationType.bottom].
  final AdaptiveBottomNavStyle bottomStyle;

  /// Rail visual style when [type] is [AdaptiveNavPresentationType.rail].
  final AdaptiveRailStyle railStyle;

  /// Sidebar visual style when [type] is [AdaptiveNavPresentationType.sidebar].
  final AdaptiveSidebarStyle sidebarStyle;

  /// Initial extended state for rail/sidebar presentations.
  final bool extended;

  /// Expanded width for rail/sidebar presentations.
  final double width;

  /// Collapsed sidebar width.
  final double collapsedWidth;

  /// Optional maximum width for floating bottom presentations.
  final double? maxWidth;

  /// Whether overlay bottom styles reserve enough body space to avoid overlap.
  final bool reserveBodySpace;

  /// Builder used by custom presentations.
  final AdaptiveNavBarBuilder? builder;

  /// Primary axis used to place a custom surface relative to the body.
  final Axis axis;
}
