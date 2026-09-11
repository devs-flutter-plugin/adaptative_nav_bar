import 'package:material_ui/material_ui.dart';

/// Base type for visual configuration that belongs to a specific bottom
/// navigation family.
///
/// Keeping style-only values outside `AdaptiveNavPresentation` prevents the
/// presentation API from becoming a bag of unrelated properties.
@immutable
abstract class AdaptiveBottomNavStyleConfig {
  /// Creates a bottom navigation style configuration.
  const AdaptiveBottomNavStyleConfig();
}

/// Geometry and surface defaults for the floating navigation family.
@immutable
class AdaptiveFloatingNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates floating bottom navigation configuration.
  const AdaptiveFloatingNavStyleConfig({
    this.height = 64,
    this.horizontalMargin = 16,
    this.bottomMargin = 10,
    this.borderRadius = 24,
    this.elevation = 6,
    this.itemHorizontalPadding = 8,
  }) : assert(height >= 56),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0),
       assert(borderRadius >= 0),
       assert(elevation >= 0),
       assert(itemHorizontalPadding >= 0);

  /// Navigation surface height before the device safe area.
  final double height;

  /// Space kept between the surface and the horizontal viewport edges.
  final double horizontalMargin;

  /// Minimum visual offset above the bottom safe area.
  final double bottomMargin;

  /// Floating surface corner radius.
  final double borderRadius;

  /// Floating surface elevation.
  final double elevation;

  /// Horizontal padding inside each destination slot.
  final double itemHorizontalPadding;
}

/// Geometry for the rounded pill navigation family.
@immutable
class AdaptivePillNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates pill navigation configuration.
  const AdaptivePillNavStyleConfig({
    this.barHeight = 68,
    this.horizontalMargin = 10,
    this.bottomMargin = 8,
    this.borderRadius = 30,
    this.elevation = 1,
    this.edgeInset = 6,
    this.itemHorizontalPadding = 2,
  }) : assert(barHeight >= 56),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0),
       assert(borderRadius >= 0),
       assert(elevation >= 0),
       assert(edgeInset >= 0),
       assert(itemHorizontalPadding >= 0);

  /// Total bar height.
  final double barHeight;

  /// Horizontal viewport inset.
  final double horizontalMargin;

  /// Bottom safe-area offset.
  final double bottomMargin;

  /// Surface corner radius.
  final double borderRadius;

  /// Surface elevation.
  final double elevation;

  /// Inner edge inset before destination slots.
  final double edgeInset;

  /// Horizontal spacing inside each equal destination slot.
  final double itemHorizontalPadding;
}

/// Geometry for the expanding bubble navigation family.
@immutable
class AdaptiveBubbleNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates bubble navigation configuration.
  const AdaptiveBubbleNavStyleConfig({
    this.barHeight = 70,
    this.activeFlex = 1.45,
    this.inactiveFlex = 1,
    this.activeHeight = 44,
    this.activePadding = 10,
    this.gap = 6,
    this.borderRadius = 24,
    this.indicatorOpacity = 0.72,
    this.elevation = 1,
  }) : assert(barHeight >= 56),
       assert(activeFlex > 0),
       assert(inactiveFlex > 0),
       assert(activeHeight >= 40),
       assert(activePadding >= 0),
       assert(gap >= 0),
       assert(borderRadius >= 0),
       assert(indicatorOpacity >= 0 && indicatorOpacity <= 1),
       assert(elevation >= 0);

  /// Total bar height.
  final double barHeight;

  /// Relative width allocated to the selected destination.
  final double activeFlex;

  /// Relative width allocated to inactive destinations.
  final double inactiveFlex;

  /// Height of the selected bubble.
  final double activeHeight;

  /// Horizontal padding inside the selected bubble.
  final double activePadding;

  /// Gap between selected icon and label.
  final double gap;

  /// Selected bubble radius.
  final double borderRadius;

  /// Opacity applied to the selected indicator color.
  final double indicatorOpacity;

  /// Surface elevation.
  final double elevation;
}

/// Geometry for the translucent glass navigation family.
@immutable
class AdaptiveGlassNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates glass navigation configuration.
  const AdaptiveGlassNavStyleConfig({
    this.barHeight = 66,
    this.horizontalMargin = 12,
    this.bottomMargin = 8,
    this.borderRadius = 28,
    this.blurSigma = 16,
    this.surfaceOpacity = 0.76,
    this.edgeInset = 4,
  }) : assert(barHeight >= 56),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0),
       assert(borderRadius >= 0),
       assert(blurSigma >= 0),
       assert(surfaceOpacity >= 0 && surfaceOpacity <= 1),
       assert(edgeInset >= 0);

  /// Total glass surface height.
  final double barHeight;

  /// Horizontal viewport inset.
  final double horizontalMargin;

  /// Bottom safe-area offset.
  final double bottomMargin;

  /// Surface corner radius.
  final double borderRadius;

  /// Backdrop blur sigma.
  final double blurSigma;

  /// Surface opacity applied over the blurred backdrop.
  final double surfaceOpacity;

  /// Inner edge inset before equal destination slots.
  final double edgeInset;
}

/// Geometry for the low-chrome minimal navigation family.
@immutable
class AdaptiveMinimalNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates minimal navigation configuration.
  const AdaptiveMinimalNavStyleConfig({
    this.barHeight = 64,
    this.indicatorWidth = 24,
    this.indicatorHeight = 3,
    this.itemHorizontalPadding = 2,
  }) : assert(barHeight >= 56),
       assert(indicatorWidth > 0),
       assert(indicatorHeight > 0),
       assert(itemHorizontalPadding >= 0);

  /// Total minimal bar height.
  final double barHeight;

  /// Width of the selected underline indicator.
  final double indicatorWidth;

  /// Height of the selected underline indicator.
  final double indicatorHeight;

  /// Horizontal spacing inside each equal destination slot.
  final double itemHorizontalPadding;
}

/// Geometry for a persistent-bottom-nav-bar style expanding destination.
@immutable
class AdaptivePersistentNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates persistent expanding navigation configuration.
  const AdaptivePersistentNavStyleConfig({
    this.barHeight = 68,
    this.itemHeight = 44,
    this.activeFlex = 2,
    this.inactiveFlex = 1,
    this.horizontalPadding = 4,
    this.activeHorizontalPadding = 14,
    this.gap = 8,
    this.borderRadius = 50,
    this.indicatorOpacity = 0.55,
    this.elevation = 3,
  }) : assert(barHeight >= 56),
       assert(itemHeight >= 40),
       assert(activeFlex > 0),
       assert(inactiveFlex > 0),
       assert(horizontalPadding >= 0),
       assert(activeHorizontalPadding >= 0),
       assert(gap >= 0),
       assert(borderRadius >= 0),
       assert(indicatorOpacity >= 0 && indicatorOpacity <= 1),
       assert(elevation >= 0);

  /// Total navigation bar height.
  final double barHeight;

  /// Height of each destination capsule.
  final double itemHeight;

  /// Relative width allocated to the selected destination.
  final double activeFlex;

  /// Relative width allocated to every inactive destination.
  final double inactiveFlex;

  /// Space between destination slots.
  final double horizontalPadding;

  /// Horizontal content padding of the selected capsule.
  final double activeHorizontalPadding;

  /// Gap between selected icon and label.
  final double gap;

  /// Capsule radius.
  final double borderRadius;

  /// Opacity applied to the selected indicator color.
  final double indicatorOpacity;

  /// Surface elevation.
  final double elevation;
}

/// Geometry and motion defaults for the Google-style expanding navigation.
@immutable
class AdaptiveGoogleNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates Google-style navigation configuration.
  const AdaptiveGoogleNavStyleConfig({
    this.barHeight = 72,
    this.itemHeight = 48,
    this.activeFlex = 1.9,
    this.inactiveFlex = 1,
    this.horizontalPadding = 10,
    this.verticalPadding = 9,
    this.activeContentPadding = 13,
    this.inactiveContentPadding = 10,
    this.gap = 8,
    this.borderRadius = 18,
    this.maxLabelWidth = 72,
    this.elevation = 2,
  }) : assert(barHeight >= 56),
       assert(itemHeight >= 44),
       assert(activeFlex > 0),
       assert(inactiveFlex > 0),
       assert(horizontalPadding >= 0),
       assert(verticalPadding >= 0),
       assert(activeContentPadding >= 0),
       assert(inactiveContentPadding >= 0),
       assert(gap >= 0),
       assert(borderRadius >= 0),
       assert(maxLabelWidth > 0),
       assert(elevation >= 0);

  /// Total navigation bar height.
  final double barHeight;

  /// Height of the active/inactive tab hit surface.
  final double itemHeight;

  /// Relative width allocated to the active destination.
  final double activeFlex;

  /// Relative width allocated to inactive destinations.
  final double inactiveFlex;

  /// Horizontal padding around the complete navigation row.
  final double horizontalPadding;

  /// Vertical padding around the complete navigation row.
  final double verticalPadding;

  /// Horizontal padding inside the active capsule.
  final double activeContentPadding;

  /// Horizontal padding inside inactive icon targets.
  final double inactiveContentPadding;

  /// Gap between active icon and label.
  final double gap;

  /// Active capsule radius.
  final double borderRadius;

  /// Maximum selected label width before ellipsis.
  final double maxLabelWidth;

  /// Surface elevation.
  final double elevation;
}

/// Visual family exposed by the Stylish-inspired renderer.
enum AdaptiveStylishVariant {
  /// Selected icon lifts/scales while labels stay visible.
  animated,

  /// Selected destination uses a circle/tile marker.
  dot,

  /// Selected destination expands into a bubble capsule.
  bubble,

  /// Frosted translucent surface with animated destinations.
  blur,
}

/// Shape of the selected indicator in [AdaptiveStylishVariant.dot].
enum AdaptiveStylishDotStyle {
  /// Circular marker.
  circle,

  /// Short rounded tile marker.
  tile,
}

/// Configuration for the Stylish-inspired renderer family.
@immutable
class AdaptiveStylishNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates Stylish-inspired navigation configuration.
  const AdaptiveStylishNavStyleConfig({
    this.variant = AdaptiveStylishVariant.dot,
    this.dotStyle = AdaptiveStylishDotStyle.tile,
    this.barHeight = 72,
    this.iconSize = 26,
    this.selectedScale = 1.12,
    this.selectedLift = 0.12,
    this.dotSize = 8,
    this.tileWidth = 18,
    this.indicatorHeight = 3,
    this.bubbleActiveFlex = 1.75,
    this.blurSigma = 16,
    this.blurOpacity = 0.72,
    this.elevation = 5,
  }) : assert(barHeight >= 56),
       assert(iconSize > 0),
       assert(selectedScale > 0),
       assert(selectedLift >= 0),
       assert(dotSize > 0),
       assert(tileWidth > 0),
       assert(indicatorHeight > 0),
       assert(bubbleActiveFlex > 0),
       assert(blurSigma >= 0),
       assert(blurOpacity >= 0 && blurOpacity <= 1),
       assert(elevation >= 0);

  /// Stylish sub-family to render.
  final AdaptiveStylishVariant variant;

  /// Indicator geometry used by the dot variant.
  final AdaptiveStylishDotStyle dotStyle;

  /// Total navigation bar height.
  final double barHeight;

  /// Icon theme size used by this family.
  final double iconSize;

  /// Scale applied to the selected icon.
  final double selectedScale;

  /// Fractional upward slide applied to the selected icon.
  final double selectedLift;

  /// Width/height of a circular selected marker.
  final double dotSize;

  /// Width of a tile selected marker.
  final double tileWidth;

  /// Height of the selected dot/tile marker.
  final double indicatorHeight;

  /// Relative width used by the selected bubble destination.
  final double bubbleActiveFlex;

  /// Backdrop blur sigma for the blur variant.
  final double blurSigma;

  /// Surface opacity for the blur variant.
  final double blurOpacity;

  /// Surface elevation for opaque variants.
  final double elevation;
}

/// Geometry for the moving notch family.
@immutable
class AdaptiveNotchNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates animated notch navigation configuration.
  const AdaptiveNotchNavStyleConfig({
    this.barHeight = 82,
    this.surfaceTop = 14,
    this.contentTop = 18,
    this.buttonSize = 52,
    this.notchRadius = 31,
    this.notchDepthFactor = 0.82,
    this.notchShoulderFactor = 1.45,
    this.buttonElevation = 5,
    this.showLabel = true,
    this.horizontalMargin = 12,
    this.bottomMargin = 8,
  }) : assert(barHeight >= 64),
       assert(surfaceTop >= 0),
       assert(contentTop >= surfaceTop),
       assert(buttonSize >= 48),
       assert(notchRadius > 0),
       assert(notchDepthFactor > 0),
       assert(notchShoulderFactor > 1),
       assert(buttonElevation >= 0),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0);

  /// Total renderer height.
  final double barHeight;

  /// Y position where the clipped bar surface begins.
  final double surfaceTop;

  /// Y position where inactive destinations begin.
  final double contentTop;

  /// Diameter of the moving selected destination.
  final double buttonSize;

  /// Radius used to construct the moving notch.
  final double notchRadius;

  /// Controls notch depth relative to [notchRadius].
  final double notchDepthFactor;

  /// Controls the horizontal notch shoulders relative to [notchRadius].
  final double notchShoulderFactor;

  /// Elevation of the selected circular destination.
  final double buttonElevation;

  /// Whether the selected destination label is rendered below its circle.
  final bool showLabel;

  /// Horizontal margin around the notched surface.
  final double horizontalMargin;

  /// Minimum offset above the device safe area.
  final double bottomMargin;
}

/// Geometry for a classic bar with a permanently elevated primary destination.
@immutable
class AdaptiveCenterRaisedNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates center-raised navigation configuration.
  const AdaptiveCenterRaisedNavStyleConfig({
    this.barHeight = 72,
    this.topRadius = 22,
    this.surfaceElevation = 2,
    this.bottomMargin = 8,
  }) : assert(barHeight >= 56),
       assert(topRadius >= 0),
       assert(surfaceElevation >= 0),
       assert(bottomMargin >= 0);

  /// Height of the base navigation surface.
  final double barHeight;

  /// Radius used by the two upper corners.
  final double topRadius;

  /// Elevation of the base surface.
  final double surfaceElevation;

  /// Minimum offset above the device safe area.
  final double bottomMargin;
}
