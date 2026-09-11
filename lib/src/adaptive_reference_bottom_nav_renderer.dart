import 'dart:math' as math;
import 'dart:ui' show ImageFilter, Path;

import 'package:material_ui/material_ui.dart';

import 'adaptive_bottom_nav_style_config.dart';
import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';

/// Unified built-in bottom navigation renderer.
///
/// The renderer keeps the package router-agnostic while separating three
/// concerns that must not share geometry: destination slot, touch target and
/// selected visual shape. This prevents wide hover/ripple areas, edge clipping
/// and inconsistent spacing between visual families.
class AdaptiveReferenceBottomNavRenderer extends StatelessWidget {
  /// Creates the renderer.
  const AdaptiveReferenceBottomNavRenderer({
    required this.config,
    required this.presentation,
    required this.motion,
    super.key,
  });

  /// Controlled navigation state.
  final AdaptiveNavBarConfig config;

  /// Active bottom presentation.
  final AdaptiveNavPresentation presentation;

  /// Shared motion defaults.
  final AdaptiveNavMotion motion;

  /// Every built-in bottom style is handled here so all styles share the same
  /// spacing, edge and interaction rules.
  static bool supports(AdaptiveBottomNavStyle style) => true;

  /// Estimated body footprint used by [AdaptiveNavScaffold].
  static double footprintFor(AdaptiveNavPresentation presentation) {
    final AdaptiveRaisedNavItem? raised = presentation.raisedItem;
    if (raised != null ||
        presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised) {
      final AdaptiveRaisedNavItem effective =
          raised ?? const AdaptiveRaisedNavItem();
      return 74 + effective.offset + (effective.showLabel ? 20 : 8);
    }

    return switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.material3 => 0,
      AdaptiveBottomNavStyle.floating =>
        _configOf<AdaptiveFloatingNavStyleConfig>(
              presentation,
              const AdaptiveFloatingNavStyleConfig(),
            ).height +
            _configOf<AdaptiveFloatingNavStyleConfig>(
              presentation,
              const AdaptiveFloatingNavStyleConfig(),
            ).bottomMargin,
      AdaptiveBottomNavStyle.notch =>
        _configOf<AdaptiveNotchNavStyleConfig>(
              presentation,
              const AdaptiveNotchNavStyleConfig(),
            ).barHeight +
            _configOf<AdaptiveNotchNavStyleConfig>(
              presentation,
              const AdaptiveNotchNavStyleConfig(),
            ).bottomMargin,
      AdaptiveBottomNavStyle.google => _configOf<AdaptiveGoogleNavStyleConfig>(
        presentation,
        const AdaptiveGoogleNavStyleConfig(),
      ).barHeight,
      AdaptiveBottomNavStyle.persistent =>
        _configOf<AdaptivePersistentNavStyleConfig>(
          presentation,
          const AdaptivePersistentNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.stylish =>
        _configOf<AdaptiveStylishNavStyleConfig>(
          presentation,
          const AdaptiveStylishNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.centerRaised => 108,
      AdaptiveBottomNavStyle.pill => 76,
      AdaptiveBottomNavStyle.bubble => 72,
      AdaptiveBottomNavStyle.glass => 78,
      AdaptiveBottomNavStyle.minimal => 66,
    };
  }

  @override
  Widget build(BuildContext context) {
    _assertCompatibleStyleConfig();

    final AdaptiveRaisedNavItem? raisedItem =
        presentation.raisedItem ??
        (presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised
            ? const AdaptiveRaisedNavItem()
            : null);
    final int? raisedIndex = raisedItem == null
        ? null
        : _resolveRaisedIndex(raisedItem, config.destinations.length);

    if (presentation.bottomStyle == AdaptiveBottomNavStyle.material3 &&
        raisedItem == null) {
      return _Material3Bar(config: config);
    }

    Widget bar = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.material3 => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: 72,
        radius: 0,
        elevation: 0,
        surfaceColor: _surface(context),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.iconPill,
      ),
      AdaptiveBottomNavStyle.floating => _floating(context, raisedIndex),
      AdaptiveBottomNavStyle.pill => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: 68,
        radius: 30,
        elevation: 1,
        surfaceColor: _surface(context),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.iconPill,
        edgeInset: 6,
      ),
      AdaptiveBottomNavStyle.notch => _MovingNotchBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveNotchNavStyleConfig>(
          const AdaptiveNotchNavStyleConfig(),
        ),
      ),
      AdaptiveBottomNavStyle.bubble => _BubbleBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.glass => _GlassBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.minimal => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: 64,
        radius: 0,
        elevation: 0,
        surfaceColor: const Color(0x00000000),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.underline,
      ),
      AdaptiveBottomNavStyle.persistent => _PersistentBar(
        config: config,
        motion: motion,
        style: _config<AdaptivePersistentNavStyleConfig>(
          const AdaptivePersistentNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.google => _GoogleBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveGoogleNavStyleConfig>(
          const AdaptiveGoogleNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.stylish => _StylishBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveStylishNavStyleConfig>(
          const AdaptiveStylishNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.centerRaised => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: _config<AdaptiveCenterRaisedNavStyleConfig>(
          const AdaptiveCenterRaisedNavStyleConfig(),
        ).barHeight,
        radius: _config<AdaptiveCenterRaisedNavStyleConfig>(
          const AdaptiveCenterRaisedNavStyleConfig(),
        ).topRadius,
        elevation: _config<AdaptiveCenterRaisedNavStyleConfig>(
          const AdaptiveCenterRaisedNavStyleConfig(),
        ).surfaceElevation,
        surfaceColor: _surface(context),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.none,
        topOnlyRadius: true,
      ),
    };

    if (raisedItem != null &&
        presentation.bottomStyle != AdaptiveBottomNavStyle.notch) {
      bar = _RaisedDestinationOverlay(
        config: config,
        raisedItem: raisedItem,
        raisedIndex: raisedIndex!,
        child: bar,
      );
    }

    final double viewportWidth = MediaQuery.sizeOf(context).width;
    final double horizontalMargin = _horizontalMargin();
    final double availableWidth = math.max(
      0,
      viewportWidth - horizontalMargin * 2,
    );
    final double width = presentation.maxWidth == null
        ? availableWidth
        : math.min(availableWidth, presentation.maxWidth!);

    return SafeArea(
      minimum: EdgeInsets.only(bottom: _bottomMargin()),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          key: const ValueKey<String>('adaptive-bottom-surface'),
          width: width,
          child: bar,
        ),
      ),
    );
  }

  Widget _floating(BuildContext context, int? hiddenIndex) {
    final AdaptiveFloatingNavStyleConfig style =
        _config<AdaptiveFloatingNavStyleConfig>(
          const AdaptiveFloatingNavStyleConfig(),
        );
    return _EqualBar(
      config: config,
      motion: motion,
      hiddenIndex: hiddenIndex,
      height: style.height,
      radius: style.borderRadius,
      elevation: style.elevation,
      surfaceColor: _surface(context),
      labelMode: _LabelMode.all,
      indicatorMode: _IndicatorMode.iconPill,
      itemHorizontalPadding: style.itemHorizontalPadding,
      edgeInset: 4,
    );
  }

  Color _surface(BuildContext context) =>
      config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;

  double _horizontalMargin() {
    return switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating =>
        _config<AdaptiveFloatingNavStyleConfig>(
          const AdaptiveFloatingNavStyleConfig(),
        ).horizontalMargin,
      AdaptiveBottomNavStyle.notch => _config<AdaptiveNotchNavStyleConfig>(
        const AdaptiveNotchNavStyleConfig(),
      ).horizontalMargin,
      AdaptiveBottomNavStyle.pill => 10,
      AdaptiveBottomNavStyle.glass => 12,
      _ => 0,
    };
  }

  double _bottomMargin() {
    return switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating =>
        _config<AdaptiveFloatingNavStyleConfig>(
          const AdaptiveFloatingNavStyleConfig(),
        ).bottomMargin,
      AdaptiveBottomNavStyle.notch => _config<AdaptiveNotchNavStyleConfig>(
        const AdaptiveNotchNavStyleConfig(),
      ).bottomMargin,
      AdaptiveBottomNavStyle.centerRaised =>
        _config<AdaptiveCenterRaisedNavStyleConfig>(
          const AdaptiveCenterRaisedNavStyleConfig(),
        ).bottomMargin,
      AdaptiveBottomNavStyle.pill || AdaptiveBottomNavStyle.glass => 8,
      _ => 0,
    };
  }

  T _config<T extends AdaptiveBottomNavStyleConfig>(T fallback) {
    return _configOf<T>(presentation, fallback);
  }

  void _assertCompatibleStyleConfig() {
    final AdaptiveBottomNavStyleConfig? value = presentation.styleConfig;
    if (value == null) {
      return;
    }
    final bool valid = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating =>
        value is AdaptiveFloatingNavStyleConfig,
      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,
      AdaptiveBottomNavStyle.persistent =>
        value is AdaptivePersistentNavStyleConfig,
      AdaptiveBottomNavStyle.google => value is AdaptiveGoogleNavStyleConfig,
      AdaptiveBottomNavStyle.stylish => value is AdaptiveStylishNavStyleConfig,
      AdaptiveBottomNavStyle.centerRaised =>
        value is AdaptiveCenterRaisedNavStyleConfig,
      _ => true,
    };
    assert(valid, 'styleConfig does not match ${presentation.bottomStyle.name}.');
  }

  static int _resolveRaisedIndex(AdaptiveRaisedNavItem item, int count) {
    final int requested = item.index ?? count ~/ 2;
    assert(
      requested >= 0 && requested < count,
      'AdaptiveRaisedNavItem.index must reference an existing destination.',
    );
    return requested.clamp(0, count - 1);
  }

  static T _configOf<T extends AdaptiveBottomNavStyleConfig>(
    AdaptiveNavPresentation presentation,
    T fallback,
  ) {
    final AdaptiveBottomNavStyleConfig? value = presentation.styleConfig;
    return value is T ? value : fallback;
  }
}

class _Material3Bar extends StatelessWidget {
  const _Material3Bar({required this.config});

  final AdaptiveNavBarConfig config;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: config.selectedIndex,
      onDestinationSelected: config.onDestinationSelected,
      destinations: <Widget>[
        for (final AdaptiveNavDestination destination in config.destinations)
          NavigationDestination(
            icon: destination.buildIcon(selected: false),
            selectedIcon: destination.buildIcon(selected: true),
            label: destination.label,
            tooltip: destination.tooltip,
            enabled: destination.enabled,
          ),
      ],
    );
  }
}

enum _LabelMode { all, selected, none }

enum _IndicatorMode { none, iconPill, underline, dot }

class _EqualBar extends StatelessWidget {
  const _EqualBar({
    required this.config,
    required this.motion,
    required this.height,
    required this.radius,
    required this.elevation,
    required this.surfaceColor,
    required this.labelMode,
    required this.indicatorMode,
    this.hiddenIndex,
    this.itemHorizontalPadding = 2,
    this.edgeInset = 0,
    this.topOnlyRadius = false,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final double height;
  final double radius;
  final double elevation;
  final Color surfaceColor;
  final _LabelMode labelMode;
  final _IndicatorMode indicatorMode;
  final int? hiddenIndex;
  final double itemHorizontalPadding;
  final double edgeInset;
  final bool topOnlyRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = topOnlyRadius
        ? BorderRadius.vertical(top: Radius.circular(radius))
        : BorderRadius.circular(radius);
    return Material(
      color: surfaceColor,
      elevation: elevation,
      borderRadius: borderRadius,
      clipBehavior: radius > 0 ? Clip.antiAlias : Clip.none,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: edgeInset),
          child: Row(
            children: <Widget>[
              for (final (int index, AdaptiveNavDestination destination)
                  in config.destinations.indexed)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: itemHorizontalPadding,
                    ),
                    child: index == hiddenIndex
                        ? const SizedBox.expand()
                        : _EqualDestination(
                            key: ValueKey<String>('adaptive-slot-$index'),
                            destination: destination,
                            selected: index == config.selectedIndex,
                            config: config,
                            motion: motion,
                            labelMode: labelMode,
                            indicatorMode: indicatorMode,
                            onTap: () => config.onDestinationSelected(index),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EqualDestination extends StatelessWidget {
  const _EqualDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.labelMode,
    required this.indicatorMode,
    required this.onTap,
    super.key,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final _LabelMode labelMode;
  final _IndicatorMode indicatorMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor =
        config.theme.selectedColor ?? Theme.of(context).colorScheme.primary;
    final Color normalColor =
        config.theme.foregroundColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final Color indicator =
        config.theme.indicatorColor ??
        Theme.of(context).colorScheme.secondaryContainer;
    final bool showLabel = switch (labelMode) {
      _LabelMode.all => true,
      _LabelMode.selected => selected,
      _LabelMode.none => false,
    };

    Widget icon = IconTheme(
      data: IconThemeData(color: selected ? selectedColor : normalColor),
      child: destination.buildIcon(selected: selected),
    );

    if (indicatorMode == _IndicatorMode.iconPill) {
      icon = AnimatedContainer(
        key: ValueKey<String>('adaptive-indicator-${destination.label}'),
        duration: motion.duration,
        curve: motion.curve,
        width: selected ? 48 : 40,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? indicator : const Color(0x00000000),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: const Color(0x00000000),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            excludeFromSemantics: true,
            onTap: destination.enabled ? onTap : null,
            borderRadius: BorderRadius.circular(18),
            child: Center(child: icon),
          ),
        ),
      );
    } else {
      icon = SizedBox(
        width: 48,
        height: 34,
        child: Center(child: icon),
      );
    }

    final Widget indicatorWidget = switch (indicatorMode) {
      _IndicatorMode.underline => AnimatedContainer(
        key: ValueKey<String>('adaptive-indicator-${destination.label}'),
        duration: motion.duration,
        curve: motion.curve,
        width: selected ? 20 : 0,
        height: 3,
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      _IndicatorMode.dot => AnimatedContainer(
        key: ValueKey<String>('adaptive-indicator-${destination.label}'),
        duration: motion.duration,
        curve: motion.curve,
        width: selected ? 6 : 0,
        height: selected ? 6 : 0,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
        ),
      ),
      _ => const SizedBox.shrink(),
    };

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon,
          if (showLabel) ...<Widget>[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: config.theme.labelTextStyle?.copyWith(
                  color: selected ? selectedColor : normalColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
          if (indicatorMode == _IndicatorMode.underline ||
              indicatorMode == _IndicatorMode.dot) ...<Widget>[
            const SizedBox(height: 3),
            indicatorWidget,
          ],
        ],
      ),
    );
  }
}

class _GoogleBar extends StatelessWidget {
  const _GoogleBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveGoogleNavStyleConfig style;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: math.min(style.horizontalPadding, 8),
            vertical: style.verticalPadding,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<double> widths = hiddenIndex == null
                  ? _weightedWidths(
                      constraints.maxWidth,
                      config.destinations.length,
                      config.selectedIndex,
                      style.activeFlex,
                      style.inactiveFlex,
                    )
                  : _equalWidths(
                      constraints.maxWidth,
                      config.destinations.length,
                    );
              return Row(
                children: <Widget>[
                  for (final (int index, AdaptiveNavDestination destination)
                      in config.destinations.indexed)
                    SizedBox(
                      key: ValueKey<String>('google-slot-$index'),
                      width: widths[index],
                      child: index == hiddenIndex
                          ? const SizedBox.expand()
                          : _CapsuleDestination(
                              destination: destination,
                              selected: index == config.selectedIndex,
                              config: config,
                              motion: motion,
                              activeHeight: style.itemHeight,
                              activePadding: style.activeContentPadding,
                              gap: style.gap,
                              borderRadius: style.borderRadius,
                              showOnlySelectedLabel: true,
                              onTap: () => config.onDestinationSelected(index),
                            ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PersistentBar extends StatelessWidget {
  const _PersistentBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptivePersistentNavStyleConfig style;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<double> widths = hiddenIndex == null
                ? _weightedWidths(
                    constraints.maxWidth,
                    config.destinations.length,
                    config.selectedIndex,
                    style.activeFlex,
                    style.inactiveFlex,
                  )
                : _equalWidths(
                    constraints.maxWidth,
                    config.destinations.length,
                  );
            return Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  SizedBox(
                    key: ValueKey<String>('persistent-slot-$index'),
                    width: widths[index],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: math.min(style.horizontalPadding, 4),
                      ),
                      child: index == hiddenIndex
                          ? const SizedBox.expand()
                          : _CapsuleDestination(
                              destination: destination,
                              selected: index == config.selectedIndex,
                              config: config,
                              motion: motion,
                              activeHeight: style.itemHeight,
                              activePadding: style.activeHorizontalPadding,
                              gap: style.gap,
                              borderRadius: style.borderRadius,
                              indicatorOpacity: style.indicatorOpacity,
                              showOnlySelectedLabel: true,
                              onTap: () => config.onDestinationSelected(index),
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BubbleBar extends StatelessWidget {
  const _BubbleBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: SizedBox(
        height: 70,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<double> widths = hiddenIndex == null
                ? _weightedWidths(
                    constraints.maxWidth,
                    config.destinations.length,
                    config.selectedIndex,
                    1.45,
                    1,
                  )
                : _equalWidths(
                    constraints.maxWidth,
                    config.destinations.length,
                  );
            return Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  SizedBox(
                    width: widths[index],
                    child: index == hiddenIndex
                        ? const SizedBox.expand()
                        : _CapsuleDestination(
                            destination: destination,
                            selected: index == config.selectedIndex,
                            config: config,
                            motion: motion,
                            activeHeight: 44,
                            activePadding: 10,
                            gap: 6,
                            borderRadius: 24,
                            indicatorOpacity: 0.72,
                            showOnlySelectedLabel: true,
                            onTap: () => config.onDestinationSelected(index),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CapsuleDestination extends StatelessWidget {
  const _CapsuleDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.activeHeight,
    required this.activePadding,
    required this.gap,
    required this.borderRadius,
    required this.showOnlySelectedLabel,
    required this.onTap,
    this.indicatorOpacity = 1,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final double activeHeight;
  final double activePadding;
  final double gap;
  final double borderRadius;
  final double indicatorOpacity;
  final bool showOnlySelectedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor =
        config.theme.selectedColor ?? Theme.of(context).colorScheme.primary;
    final Color normalColor =
        config.theme.foregroundColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final Color indicator =
        (config.theme.indicatorColor ??
                Theme.of(context).colorScheme.secondaryContainer)
            .withValues(alpha: indicatorOpacity);

    final Widget icon = IconTheme(
      data: IconThemeData(color: selected ? selectedColor : normalColor),
      child: destination.buildIcon(selected: selected),
    );

    final Widget visual = selected
        ? AnimatedContainer(
            duration: motion.duration,
            curve: motion.curve,
            height: activeHeight,
            constraints: const BoxConstraints(minWidth: 48, maxWidth: 132),
            padding: EdgeInsets.symmetric(horizontal: activePadding),
            decoration: BoxDecoration(
              color: indicator,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Material(
              color: const Color(0x00000000),
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                excludeFromSemantics: true,
                onTap: destination.enabled ? onTap : null,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      icon,
                      Flexible(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: gap),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: config.theme.labelTextStyle?.copyWith(
                              color: selectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            width: 48,
            height: 48,
            child: Center(child: icon),
          );

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      child: Center(child: visual),
    );
  }
}

class _StylishBar extends StatelessWidget {
  const _StylishBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveStylishNavStyleConfig style;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    if (style.variant == AdaptiveStylishVariant.blur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: _StylishSurface(
            config: config,
            motion: motion,
            style: style,
            hiddenIndex: hiddenIndex,
            transparent: true,
          ),
        ),
      );
    }
    return _StylishSurface(
      config: config,
      motion: motion,
      style: style,
      hiddenIndex: hiddenIndex,
    );
  }
}

class _StylishSurface extends StatelessWidget {
  const _StylishSurface({
    required this.config,
    required this.motion,
    required this.style,
    required this.hiddenIndex,
    this.transparent = false,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveStylishNavStyleConfig style;
  final int? hiddenIndex;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: transparent
          ? surface.withValues(alpha: style.blurOpacity)
          : surface,
      elevation: transparent ? 0 : style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                child: index == hiddenIndex
                    ? const SizedBox.expand()
                    : _StylishDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        config: config,
                        motion: motion,
                        style: style,
                        onTap: () => config.onDestinationSelected(index),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StylishDestination extends StatelessWidget {
  const _StylishDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.style,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveStylishNavStyleConfig style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (style.variant == AdaptiveStylishVariant.bubble) {
      return _CapsuleDestination(
        destination: destination,
        selected: selected,
        config: config,
        motion: motion,
        activeHeight: 42,
        activePadding: 10,
        gap: 6,
        borderRadius: 22,
        indicatorOpacity: 0.72,
        showOnlySelectedLabel: true,
        onTap: onTap,
      );
    }

    final Color selectedColor =
        config.theme.selectedColor ?? Theme.of(context).colorScheme.primary;
    final Color normalColor =
        config.theme.foregroundColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final double lift =
        style.variant == AdaptiveStylishVariant.animated && selected
        ? -style.selectedLift
        : 0;

    final Widget marker = style.variant == AdaptiveStylishVariant.dot
        ? AnimatedContainer(
            key: ValueKey<String>('stylish-indicator-${destination.label}'),
            duration: motion.duration,
            curve: motion.curve,
            width: selected
                ? style.dotStyle == AdaptiveStylishDotStyle.circle
                      ? style.dotSize
                      : style.tileWidth
                : 0,
            height: selected
                ? style.dotStyle == AdaptiveStylishDotStyle.circle
                      ? style.dotSize
                      : style.indicatorHeight
                : 0,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(style.dotSize),
            ),
          )
        : const SizedBox.shrink();

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedSlide(
            duration: motion.duration,
            curve: motion.curve,
            offset: Offset(0, lift),
            child: AnimatedScale(
              duration: motion.duration,
              curve: motion.curve,
              scale: selected ? style.selectedScale : 1,
              child: SizedBox(
                width: 48,
                height: 30,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      color: selected ? selectedColor : normalColor,
                      size: style.iconSize,
                    ),
                    child: destination.buildIcon(selected: selected),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: config.theme.labelTextStyle?.copyWith(
              color: selected ? selectedColor : normalColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (style.variant == AdaptiveStylishVariant.dot) ...<Widget>[
            const SizedBox(height: 3),
            marker,
          ],
        ],
      ),
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(28);
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: _EqualBar(
          config: config,
          motion: motion,
          hiddenIndex: hiddenIndex,
          height: 66,
          radius: 28,
          elevation: 0,
          surfaceColor: surface.withValues(alpha: 0.76),
          labelMode: _LabelMode.all,
          indicatorMode: _IndicatorMode.iconPill,
          edgeInset: 4,
        ),
      ),
    );
  }
}

class _MovingNotchBar extends StatefulWidget {
  const _MovingNotchBar({
    required this.config,
    required this.motion,
    required this.style,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveNotchNavStyleConfig style;

  @override
  State<_MovingNotchBar> createState() => _MovingNotchBarState();
}

class _MovingNotchBarState extends State<_MovingNotchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.motion.duration,
    );
    _position = AlwaysStoppedAnimation<double>(
      widget.config.selectedIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant _MovingNotchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion.duration != widget.motion.duration) {
      _controller.duration = widget.motion.duration;
    }
    if (oldWidget.config.selectedIndex != widget.config.selectedIndex) {
      _position = Tween<double>(
        begin: _position.value,
        end: widget.config.selectedIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: widget.motion.curve),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color surface =
        widget.config.theme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double position = _position.value;
        final int selectedIndex = widget.config.selectedIndex;
        final AdaptiveNavDestination selected =
            widget.config.destinations[selectedIndex];
        return SizedBox(
          height: widget.style.barHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double slotWidth =
                  constraints.maxWidth / widget.config.destinations.length;
              final double logicalCenter =
                  slotWidth * position + slotWidth / 2;
              final double center = Directionality.of(context) == TextDirection.rtl
                  ? constraints.maxWidth - logicalCenter
                  : logicalCenter;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    top: widget.style.surfaceTop,
                    child: ClipPath(
                      clipper: _NotchClipper(
                        center: center,
                        radius: widget.style.notchRadius,
                        depthFactor: widget.style.notchDepthFactor,
                        shoulderFactor: widget.style.notchShoulderFactor,
                      ),
                      child: Material(
                        color: surface,
                        elevation: 1,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: widget.style.contentTop,
                    child: Row(
                      children: <Widget>[
                        for (final (int index, AdaptiveNavDestination destination)
                            in widget.config.destinations.indexed)
                          Expanded(
                            child: index == selectedIndex
                                ? const SizedBox.expand()
                                : _NotchInactiveDestination(
                                    destination: destination,
                                    config: widget.config,
                                    index: index,
                                  ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    key: const ValueKey<String>('adaptive-notch-button'),
                    left: center - widget.style.buttonSize / 2,
                    top: 0,
                    width: widget.style.buttonSize,
                    child: _RaisedVisual(
                      destination: selected,
                      selected: true,
                      config: widget.config,
                      size: widget.style.buttonSize,
                      elevation: widget.style.buttonElevation,
                      backgroundColor: widget.config.theme.indicatorColor,
                      foregroundColor: widget.config.theme.selectedColor,
                      showLabel: widget.style.showLabel,
                      onTap: () =>
                          widget.config.onDestinationSelected(selectedIndex),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _NotchInactiveDestination extends StatelessWidget {
  const _NotchInactiveDestination({
    required this.destination,
    required this.config,
    required this.index,
  });

  final AdaptiveNavDestination destination;
  final AdaptiveNavBarConfig config;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color color =
        config.theme.foregroundColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    return _DestinationSemantics(
      destination: destination,
      selected: false,
      onTap: () => config.onDestinationSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 30,
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: color),
                child: destination.buildIcon(selected: false),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: config.theme.labelTextStyle?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _NotchClipper extends CustomClipper<Path> {
  const _NotchClipper({
    required this.center,
    required this.radius,
    required this.depthFactor,
    required this.shoulderFactor,
  });

  final double center;
  final double radius;
  final double depthFactor;
  final double shoulderFactor;

  @override
  Path getClip(Size size) {
    final double safeCenter = center.clamp(
      radius * shoulderFactor,
      size.width - radius * shoulderFactor,
    );
    final Path path = Path()..moveTo(0, 0);
    path.lineTo(safeCenter - radius * shoulderFactor, 0);
    path.cubicTo(
      safeCenter - radius,
      0,
      safeCenter - radius,
      radius * depthFactor,
      safeCenter,
      radius * depthFactor,
    );
    path.cubicTo(
      safeCenter + radius,
      radius * depthFactor,
      safeCenter + radius,
      0,
      safeCenter + radius * shoulderFactor,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _NotchClipper oldClipper) {
    return oldClipper.center != center ||
        oldClipper.radius != radius ||
        oldClipper.depthFactor != depthFactor ||
        oldClipper.shoulderFactor != shoulderFactor;
  }
}

class _RaisedDestinationOverlay extends StatelessWidget {
  const _RaisedDestinationOverlay({
    required this.config,
    required this.raisedItem,
    required this.raisedIndex,
    required this.child,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveRaisedNavItem raisedItem;
  final int raisedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AdaptiveNavDestination destination = config.destinations[raisedIndex];
    final bool selected = config.selectedIndex == raisedIndex;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double slotWidth = constraints.maxWidth / config.destinations.length;
        final double start =
            slotWidth * raisedIndex + (slotWidth - raisedItem.size) / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            PositionedDirectional(
              key: const ValueKey<String>('adaptive-raised-button'),
              start: start,
              top: -raisedItem.offset,
              width: raisedItem.size,
              child: _RaisedVisual(
                destination: destination,
                selected: selected,
                config: config,
                size: raisedItem.size,
                elevation: raisedItem.elevation,
                backgroundColor: raisedItem.backgroundColor,
                foregroundColor: raisedItem.foregroundColor,
                showLabel: raisedItem.showLabel,
                onTap: () => config.onDestinationSelected(raisedIndex),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RaisedVisual extends StatelessWidget {
  const _RaisedVisual({
    required this.destination,
    required this.selected,
    required this.config,
    required this.size,
    required this.elevation,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.showLabel,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final double size;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background =
        backgroundColor ?? Theme.of(context).colorScheme.inverseSurface;
    final Color foreground =
        foregroundColor ?? Theme.of(context).colorScheme.onInverseSurface;
    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              color: background,
              elevation: elevation,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                excludeFromSemantics: true,
                onTap: destination.enabled ? onTap : null,
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: size,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(color: foreground),
                      child: destination.buildIcon(selected: selected),
                    ),
                  ),
                ),
              ),
            ),
            if (showLabel) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: config.theme.labelTextStyle?.copyWith(
                  color: selected
                      ? config.theme.selectedColor
                      : config.theme.foregroundColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DestinationSemantics extends StatelessWidget {
  const _DestinationSemantics({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onTap: destination.enabled ? onTap : null,
          child: SizedBox.expand(child: Center(child: child)),
        ),
      ),
    );
  }
}

List<double> _equalWidths(double totalWidth, int count) {
  if (count <= 0) {
    return const <double>[];
  }
  final double value = totalWidth / count;
  return List<double>.filled(count, value);
}

List<double> _weightedWidths(
  double totalWidth,
  int count,
  int activeIndex,
  double activeWeight,
  double inactiveWeight,
) {
  if (count <= 0) {
    return const <double>[];
  }
  final double totalWeight =
      activeWeight + inactiveWeight * math.max(0, count - 1);
  final double unit = totalWidth / totalWeight;
  return <double>[
    for (int index = 0; index < count; index++)
      unit * (index == activeIndex ? activeWeight : inactiveWeight),
  ];
}
