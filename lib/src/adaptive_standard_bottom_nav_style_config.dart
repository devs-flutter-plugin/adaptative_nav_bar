import 'package:material_ui/material_ui.dart';

import 'adaptive_bottom_nav_style_config.dart';

/// Geometry for the pill bottom navigation family.
@immutable
class AdaptivePillNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates pill navigation configuration.
  const AdaptivePillNavStyleConfig({
    this.barHeight = 68,
    this.horizontalMargin = 10,
    this.bottomMargin = 8,
    this.surfaceRadius = 30,
    this.surfaceElevation = 1,
    this.edgeInset = 6,
    this.itemHorizontalPadding = 2,
    this.selectedIndicatorWidth = 48,
    this.unselectedIndicatorWidth = 40,
    this.indicatorHeight = 34,
    this.indicatorRadius = 18,
    this.labelGap = 2,
  }) : assert(barHeight >= 56),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0),
       assert(surfaceRadius >= 0),
       assert(surfaceElevation >= 0),
       assert(edgeInset >= 0),
       assert(itemHorizontalPadding >= 0),
       assert(selectedIndicatorWidth > 0),
       assert(unselectedIndicatorWidth > 0),
       assert(indicatorHeight > 0),
       assert(indicatorRadius >= 0),
       assert(labelGap >= 0);

  /// Navigation surface height before the device safe area.
  final double barHeight;

  /// Horizontal viewport inset around the surface.
  final double horizontalMargin;

  /// Minimum visual offset above the bottom safe area.
  final double bottomMargin;

  /// Surface corner radius.
  final double surfaceRadius;

  /// Surface elevation.
  final double surfaceElevation;

  /// Inner horizontal inset applied before destination slots.
  final double edgeInset;

  /// Horizontal spacing inside each equal destination slot.
  final double itemHorizontalPadding;

  /// Width of the selected icon indicator.
  final double selectedIndicatorWidth;

  /// Width reserved for an unselected icon.
  final double unselectedIndicatorWidth;

  /// Height of the icon indicator.
  final double indicatorHeight;

  /// Selected icon indicator radius.
  final double indicatorRadius;

  /// Vertical gap between icon treatment and label.
  final double labelGap;
}

/// Geometry for the bubble bottom navigation family.
@immutable
class AdaptiveBubbleNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates bubble navigation configuration.
  const AdaptiveBubbleNavStyleConfig({
    this.barHeight = 70,
    this.activeFlex = 1.45,
    this.inactiveFlex = 1,
    this.itemHeight = 44,
    this.activeHorizontalPadding = 10,
    this.gap = 6,
    this.borderRadius = 24,
    this.indicatorOpacity = 0.72,
    this.elevation = 1,
  }) : assert(barHeight >= 56),
       assert(activeFlex > 0),
       assert(inactiveFlex > 0),
       assert(itemHeight >= 40),
       assert(activeHorizontalPadding >= 0),
       assert(gap >= 0),
       assert(borderRadius >= 0),
       assert(indicatorOpacity >= 0 && indicatorOpacity <= 1),
       assert(elevation >= 0);

  /// Total navigation surface height.
  final double barHeight;

  /// Relative width allocated to the selected destination.
  final double activeFlex;

  /// Relative width allocated to every unselected destination.
  final double inactiveFlex;

  /// Height of the selected capsule.
  final double itemHeight;

  /// Horizontal padding inside the selected capsule.
  final double activeHorizontalPadding;

  /// Gap between active icon and label.
  final double gap;

  /// Selected capsule radius.
  final double borderRadius;

  /// Opacity applied to the selected indicator color.
  final double indicatorOpacity;

  /// Surface elevation.
  final double elevation;
}

/// Geometry and blur tokens for the glass bottom navigation family.
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
    this.selectedIndicatorWidth = 48,
    this.unselectedIndicatorWidth = 40,
    this.indicatorHeight = 34,
    this.indicatorRadius = 18,
    this.labelGap = 2,
  }) : assert(barHeight >= 56),
       assert(horizontalMargin >= 0),
       assert(bottomMargin >= 0),
       assert(borderRadius >= 0),
       assert(blurSigma >= 0),
       assert(surfaceOpacity >= 0 && surfaceOpacity <= 1),
       assert(edgeInset >= 0),
       assert(selectedIndicatorWidth > 0),
       assert(unselectedIndicatorWidth > 0),
       assert(indicatorHeight > 0),
       assert(indicatorRadius >= 0),
       assert(labelGap >= 0);

  /// Total navigation surface height.
  final double barHeight;

  /// Horizontal viewport inset around the glass surface.
  final double horizontalMargin;

  /// Minimum visual offset above the bottom safe area.
  final double bottomMargin;

  /// Surface and clip radius.
  final double borderRadius;

  /// Backdrop blur sigma.
  final double blurSigma;

  /// Alpha applied to the resolved navigation surface color.
  final double surfaceOpacity;

  /// Inner horizontal inset applied before destination slots.
  final double edgeInset;

  /// Width of the selected icon indicator.
  final double selectedIndicatorWidth;

  /// Width reserved for an unselected icon.
  final double unselectedIndicatorWidth;

  /// Height of the icon indicator.
  final double indicatorHeight;

  /// Icon indicator radius.
  final double indicatorRadius;

  /// Vertical gap between icon treatment and label.
  final double labelGap;
}

/// Geometry for the minimal bottom navigation family.
@immutable
class AdaptiveMinimalNavStyleConfig extends AdaptiveBottomNavStyleConfig {
  /// Creates minimal navigation configuration.
  const AdaptiveMinimalNavStyleConfig({
    this.barHeight = 64,
    this.underlineWidth = 20,
    this.underlineHeight = 3,
    this.underlineRadius = 2,
    this.labelGap = 2,
    this.indicatorGap = 3,
  }) : assert(barHeight >= 56),
       assert(underlineWidth >= 0),
       assert(underlineHeight >= 0),
       assert(underlineRadius >= 0),
       assert(labelGap >= 0),
       assert(indicatorGap >= 0);

  /// Total navigation layout height.
  final double barHeight;

  /// Width of the selected underline.
  final double underlineWidth;

  /// Height of the selected underline.
  final double underlineHeight;

  /// Radius of the selected underline.
  final double underlineRadius;

  /// Vertical gap between icon and label.
  final double labelGap;

  /// Vertical gap between label and underline.
  final double indicatorGap;
}
