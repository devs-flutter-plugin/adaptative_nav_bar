import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Theme extension for custom adaptive navigation renderers.
@immutable
class AdaptiveNavThemeData extends ThemeExtension<AdaptiveNavThemeData> {
  /// Creates theme overrides.
  const AdaptiveNavThemeData({
    this.backgroundColor,
    this.foregroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.borderRadius,
    this.elevation,
    this.itemPadding,
    this.labelTextStyle,
  });

  /// Navigation surface color.
  final Color? backgroundColor;

  /// Unselected foreground color.
  final Color? foregroundColor;

  /// Selected foreground color.
  final Color? selectedColor;

  /// Selected-item indicator color.
  final Color? indicatorColor;

  /// Surface corner radius for custom renderers.
  final BorderRadius? borderRadius;

  /// Surface elevation for custom renderers.
  final double? elevation;

  /// Padding around custom-renderer destination items.
  final EdgeInsetsGeometry? itemPadding;

  /// Label style for custom renderers.
  final TextStyle? labelTextStyle;

  /// Returns theme data resolved from [context] and optional [overrides].
  static AdaptiveNavThemeData resolve(
    BuildContext context,
    AdaptiveNavThemeData? overrides,
  ) {
    final ThemeData materialTheme = Theme.of(context);
    final AdaptiveNavThemeData extension =
        materialTheme.extension<AdaptiveNavThemeData>() ??
        const AdaptiveNavThemeData();
    final ColorScheme scheme = materialTheme.colorScheme;

    return AdaptiveNavThemeData(
      backgroundColor:
          overrides?.backgroundColor ??
          extension.backgroundColor ??
          scheme.surfaceContainer,
      foregroundColor:
          overrides?.foregroundColor ??
          extension.foregroundColor ??
          scheme.onSurfaceVariant,
      selectedColor:
          overrides?.selectedColor ??
          extension.selectedColor ??
          scheme.onSecondaryContainer,
      indicatorColor:
          overrides?.indicatorColor ??
          extension.indicatorColor ??
          scheme.secondaryContainer,
      borderRadius:
          overrides?.borderRadius ??
          extension.borderRadius ??
          BorderRadius.circular(24),
      elevation: overrides?.elevation ?? extension.elevation ?? 3,
      itemPadding:
          overrides?.itemPadding ??
          extension.itemPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelTextStyle:
          overrides?.labelTextStyle ??
          extension.labelTextStyle ??
          materialTheme.textTheme.labelMedium,
    );
  }

  @override
  AdaptiveNavThemeData copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? selectedColor,
    Color? indicatorColor,
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? itemPadding,
    TextStyle? labelTextStyle,
  }) {
    return AdaptiveNavThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      itemPadding: itemPadding ?? this.itemPadding,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    );
  }

  @override
  AdaptiveNavThemeData lerp(
    covariant AdaptiveNavThemeData? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return AdaptiveNavThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t),
      elevation: _lerpDouble(elevation, other.elevation, t),
      itemPadding: EdgeInsetsGeometry.lerp(itemPadding, other.itemPadding, t),
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    final double start = a ?? 0;
    final double end = b ?? 0;
    return start + (end - start) * t;
  }
}
