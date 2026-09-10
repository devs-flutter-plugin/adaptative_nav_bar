import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';

/// Built-in bottom navigation visual variants.
enum AdaptiveBottomNavStyle {
  /// Flutter Material 3 [NavigationBar].
  material3,

  /// Floating rounded surface inspired by scroll-aware floating bars.
  floating,

  /// Compact capsule navigation with a selected capsule.
  pill,

  /// Animated moving notch with a raised selected destination.
  notch,

  /// Bubble navigation with an expanding selected destination.
  bubble,

  /// Translucent blurred floating surface.
  glass,

  /// Minimal icon/label navigation without persistent chrome.
  minimal,

  /// Expanding selected capsule inspired by persistent_bottom_nav_bar style 1.
  persistent,

  /// Google-style navigation where only the selected tab expands to show text.
  google,

  /// Animated icon + selection marker inspired by stylish_bottom_bar.
  stylish,

  /// Classic mobile bar with a permanently raised middle destination.
  centerRaised,
}

/// Configuration for a destination rendered above the bottom bar surface.
///
/// This is useful for mobile layouts where a primary destination, normally the
/// middle one, should behave like an integrated floating action button while
/// still remaining a normal navigation destination.
@immutable
class AdaptiveRaisedNavItem {
  /// Creates a raised navigation destination configuration.
  const AdaptiveRaisedNavItem({
    this.index,
    this.size = 58,
    this.offset = 18,
    this.elevation = 6,
    this.backgroundColor,
    this.foregroundColor,
    this.showLabel = true,
  }) : assert(size >= 48),
       assert(offset >= 0),
       assert(elevation >= 0);

  /// Destination index to raise. When omitted, the middle destination is used.
  final int? index;

  /// Diameter of the raised circular destination.
  final double size;

  /// Distance the destination protrudes above the bar.
  final double offset;

  /// Material elevation of the raised destination.
  final double elevation;

  /// Optional raised destination background color.
  final Color? backgroundColor;

  /// Optional raised destination foreground color.
  final Color? foregroundColor;

  /// Whether the destination label remains visible below the raised button.
  final bool showLabel;
}

/// Built-in rail visual variants.
enum AdaptiveRailStyle {
  /// Flutter Material 3 [NavigationRail].
  material3,

  /// Dense rail with a compact selection indicator.
  indicator,

  /// Compact custom rail without a persistent selection background.
  compact,
}

/// Built-in sidebar visual variants.
enum AdaptiveSidebarStyle {
  /// Material-like sidebar surface.
  material3,

  /// Collapsible desktop sidebar inspired by SidebarX interaction patterns.
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
    this.raisedItem,
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
       raisedItem = null,
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
       raisedItem = null,
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
       maxWidth = null,
       raisedItem = null;

  /// Presentation family.
  final AdaptiveNavPresentationType type;

  /// Bottom visual style when [type] is [AdaptiveNavPresentationType.bottom].
  final AdaptiveBottomNavStyle bottomStyle;

  /// Optional raised destination layered over a bottom presentation.
  ///
  /// This can be combined with any non-Material custom style. The
  /// [AdaptiveBottomNavStyle.centerRaised] style supplies this behavior with a
  /// default middle destination even when [raisedItem] is omitted.
  final AdaptiveRaisedNavItem? raisedItem;

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
