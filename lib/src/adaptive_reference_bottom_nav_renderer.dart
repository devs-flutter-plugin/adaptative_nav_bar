import 'dart:ui' show ImageFilter, Path;

import 'package:material_ui/material_ui.dart';

import 'adaptive_bottom_nav_style_config.dart';
import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';

/// High-fidelity renderers for the visual families that require geometry or
/// motion beyond the generic bottom renderer.
///
/// Navigation state remains fully controlled by [AdaptiveNavBarConfig].
class AdaptiveReferenceBottomNavRenderer extends StatelessWidget {
  /// Creates a reference-inspired bottom renderer.
  const AdaptiveReferenceBottomNavRenderer({
    required this.config,
    required this.presentation,
    required this.motion,
    super.key,
  });

  /// Current controlled navigation state.
  final AdaptiveNavBarConfig config;

  /// Current bottom presentation.
  final AdaptiveNavPresentation presentation;

  /// Shared motion defaults.
  final AdaptiveNavMotion motion;

  /// Whether [style] is implemented by this renderer.
  static bool supports(AdaptiveBottomNavStyle style) {
    return switch (style) {
      AdaptiveBottomNavStyle.floating ||
      AdaptiveBottomNavStyle.notch ||
      AdaptiveBottomNavStyle.persistent ||
      AdaptiveBottomNavStyle.google ||
      AdaptiveBottomNavStyle.stylish ||
      AdaptiveBottomNavStyle.centerRaised => true,
      _ => false,
    };
  }

  /// Reserved body footprint for a supported reference style.
  static double footprintFor(AdaptiveNavPresentation presentation) {
    final AdaptiveRaisedNavItem? raised = presentation.raisedItem;
    if (raised != null ||
        presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised) {
      final AdaptiveRaisedNavItem effective =
          raised ?? const AdaptiveRaisedNavItem();
      return 72 + effective.offset + (effective.showLabel ? 18 : 8);
    }

    return switch (presentation.bottomStyle) {
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
      AdaptiveBottomNavStyle.persistent =>
        _configOf<AdaptivePersistentNavStyleConfig>(
          presentation,
          const AdaptivePersistentNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.google =>
        _configOf<AdaptiveGoogleNavStyleConfig>(
          presentation,
          const AdaptiveGoogleNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.stylish =>
        _configOf<AdaptiveStylishNavStyleConfig>(
          presentation,
          const AdaptiveStylishNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.centerRaised => 108,
      _ => 92,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(supports(presentation.bottomStyle));
    _assertCompatibleStyleConfig();

    final AdaptiveRaisedNavItem? raisedItem =
        presentation.raisedItem ??
        (presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised
            ? const AdaptiveRaisedNavItem()
            : null);
    final int? raisedIndex = raisedItem == null
        ? null
        : _resolveRaisedIndex(raisedItem, config.destinations.length);

    final Widget bar = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating => _FloatingReferenceBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveFloatingNavStyleConfig>(
          const AdaptiveFloatingNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.notch => _MovingNotchBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveNotchNavStyleConfig>(
          const AdaptiveNotchNavStyleConfig(),
        ),
      ),
      AdaptiveBottomNavStyle.persistent => _PersistentReferenceBar(
        config: config,
        motion: motion,
        style: _config<AdaptivePersistentNavStyleConfig>(
          const AdaptivePersistentNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.google => _GoogleReferenceBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveGoogleNavStyleConfig>(
          const AdaptiveGoogleNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.stylish => _StylishReferenceBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveStylishNavStyleConfig>(
          const AdaptiveStylishNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.centerRaised => _CenterRaisedBaseBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveCenterRaisedNavStyleConfig>(
          const AdaptiveCenterRaisedNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex!,
      ),
      _ => const SizedBox.shrink(),
    };

    final Widget layered = raisedItem != null &&
            presentation.bottomStyle != AdaptiveBottomNavStyle.notch
        ? _RaisedDestinationOverlay(
            config: config,
            presentation: presentation,
            raisedItem: raisedItem,
            raisedIndex: raisedIndex!,
            child: bar,
          )
        : bar;

    final double viewportWidth = MediaQuery.sizeOf(context).width;
    final double horizontalMargin = _horizontalMargin();
    final double effectiveMaxWidth = presentation.maxWidth ?? 560;
    final double constrainedWidth = (viewportWidth - horizontalMargin * 2)
        .clamp(0.0, effectiveMaxWidth)
        .toDouble();

    return SafeArea(
      minimum: EdgeInsets.only(bottom: _bottomMargin()),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: constrainedWidth, child: layered),
      ),
    );
  }

  T _config<T extends AdaptiveBottomNavStyleConfig>(T fallback) {
    return _configOf<T>(presentation, fallback);
  }

  double _horizontalMargin() {
    return switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating =>
        _config<AdaptiveFloatingNavStyleConfig>(
          const AdaptiveFloatingNavStyleConfig(),
        ).horizontalMargin,
      AdaptiveBottomNavStyle.notch => _config<AdaptiveNotchNavStyleConfig>(
        const AdaptiveNotchNavStyleConfig(),
      ).horizontalMargin,
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
      _ => 8,
    };
  }

  void _assertCompatibleStyleConfig() {
    final AdaptiveBottomNavStyleConfig? value = presentation.styleConfig;
    if (value == null) {
      return;
    }
    final bool valid = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.floating => value is AdaptiveFloatingNavStyleConfig,
      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,
      AdaptiveBottomNavStyle.persistent =>
        value is AdaptivePersistentNavStyleConfig,
      AdaptiveBottomNavStyle.google => value is AdaptiveGoogleNavStyleConfig,
      AdaptiveBottomNavStyle.stylish => value is AdaptiveStylishNavStyleConfig,
      AdaptiveBottomNavStyle.centerRaised =>
        value is AdaptiveCenterRaisedNavStyleConfig,
      _ => true,
    };
    assert(
      valid,
      'styleConfig does not match ${presentation.bottomStyle.name}.',
    );
  }

  static int _resolveRaisedIndex(AdaptiveRaisedNavItem item, int count) {
    final int requested = item.index ?? count ~/ 2;
    assert(
      requested >= 0 && requested < count,
      'AdaptiveRaisedNavItem.index must reference an existing destination.',
    );
    return requested.clamp(0, count - 1) as int;
  }

  static T _configOf<T extends AdaptiveBottomNavStyleConfig>(
    AdaptiveNavPresentation presentation,
    T fallback,
  ) {
    final AdaptiveBottomNavStyleConfig? value = presentation.styleConfig;
    return value is T ? value : fallback;
  }
}

class _FloatingReferenceBar extends StatelessWidget {
  const _FloatingReferenceBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveFloatingNavStyleConfig style;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: style.elevation,
      borderRadius: BorderRadius.circular(style.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: style.height,
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                child: index == hiddenIndex
                    ? const SizedBox.expand()
                    : _IconLabelDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        config: config,
                        motion: motion,
                        horizontalPadding: style.itemHorizontalPadding,
                        selectedIndicator: true,
                        onTap: () => config.onDestinationSelected(index),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PersistentReferenceBar extends StatelessWidget {
  const _PersistentReferenceBar({
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
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<double> widths = _weightedWidths(
              totalWidth: constraints.maxWidth,
              count: config.destinations.length,
              activeIndex: config.selectedIndex,
              activeWeight: style.activeFlex,
              inactiveWeight: style.inactiveFlex,
            );
            return Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  AnimatedContainer(
                    key: ValueKey<String>('persistent-slot-$index'),
                    duration: motion.duration,
                    curve: motion.curve,
                    width: widths[index],
                    padding: EdgeInsets.symmetric(
                      horizontal: style.horizontalPadding,
                    ),
                    child: index == hiddenIndex
                        ? const SizedBox.expand()
                        : _ExpandingCapsuleDestination(
                            destination: destination,
                            selected: index == config.selectedIndex,
                            config: config,
                            motion: motion,
                            height: style.itemHeight,
                            horizontalPadding: style.activeHorizontalPadding,
                            gap: style.gap,
                            borderRadius: style.borderRadius,
                            indicatorOpacity: style.indicatorOpacity,
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

class _GoogleReferenceBar extends StatelessWidget {
  const _GoogleReferenceBar({
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
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: style.horizontalPadding,
            vertical: style.verticalPadding,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<double> widths = _weightedWidths(
                totalWidth: constraints.maxWidth,
                count: config.destinations.length,
                activeIndex: config.selectedIndex,
                activeWeight: style.activeFlex,
                inactiveWeight: style.inactiveFlex,
              );
              return Row(
                children: <Widget>[
                  for (final (int index, AdaptiveNavDestination destination)
                      in config.destinations.indexed)
                    AnimatedContainer(
                      key: ValueKey<String>('google-slot-$index'),
                      duration: motion.duration,
                      curve: motion.curve,
                      width: widths[index],
                      child: index == hiddenIndex
                          ? const SizedBox.expand()
                          : _GoogleDestination(
                              destination: destination,
                              selected: index == config.selectedIndex,
                              config: config,
                              motion: motion,
                              style: style,
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

class _GoogleDestination extends StatelessWidget {
  const _GoogleDestination({
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
  final AdaptiveGoogleNavStyleConfig style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? config.theme.selectedColor ?? Theme.of(context).colorScheme.primary
        : config.theme.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final Color indicator =
        config.theme.indicatorColor ?? Theme.of(context).colorScheme.secondaryContainer;

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      borderRadius: style.borderRadius,
      child: Center(
        child: AnimatedContainer(
          duration: motion.duration,
          curve: motion.curve,
          height: style.itemHeight,
          constraints: const BoxConstraints(minWidth: 48),
          padding: EdgeInsets.symmetric(
            horizontal: selected
                ? style.activeContentPadding
                : style.inactiveContentPadding,
          ),
          decoration: BoxDecoration(
            color: selected ? indicator : const Color(0x00000000),
            borderRadius: BorderRadius.circular(style.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: foreground),
                child: destination.buildIcon(selected: selected),
              ),
              AnimatedSize(
                duration: motion.duration,
                curve: motion.curve,
                child: selected
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(start: style.gap),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: style.maxLabelWidth),
                          child: Text(
                            destination.label,
                            key: ValueKey<String>(
                              'google-selected-label-${destination.label}',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: config.theme.labelTextStyle?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StylishReferenceBar extends StatelessWidget {
  const _StylishReferenceBar({
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
    if (style.variant == AdaptiveStylishVariant.bubble) {
      return _StylishBubbleBar(
        config: config,
        motion: motion,
        style: style,
        hiddenIndex: hiddenIndex,
      );
    }

    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    Widget content = SizedBox(
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
    );

    if (style.variant == AdaptiveStylishVariant.blur) {
      final BorderRadius radius = BorderRadius.circular(24);
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: Material(
            color: surface.withValues(alpha: style.blurOpacity),
            elevation: 0,
            child: content,
          ),
        ),
      );
    } else {
      content = Material(
        color: surface,
        elevation: style.elevation,
        child: content,
      );
    }
    return content;
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
    final Color foreground = selected
        ? config.theme.selectedColor ?? Theme.of(context).colorScheme.primary
        : config.theme.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final bool animated =
        style.variant == AdaptiveStylishVariant.animated ||
        style.variant == AdaptiveStylishVariant.blur;

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedSlide(
            offset: selected && animated
                ? Offset(0, -style.selectedLift)
                : Offset.zero,
            duration: motion.duration,
            curve: Curves.fastOutSlowIn,
            child: AnimatedScale(
              scale: selected && animated ? style.selectedScale : 1,
              duration: motion.duration,
              curve: Curves.fastOutSlowIn,
              child: IconTheme(
                data: IconThemeData(color: foreground, size: style.iconSize),
                child: destination.buildIcon(selected: selected),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: config.theme.labelTextStyle?.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (style.variant == AdaptiveStylishVariant.dot) ...<Widget>[
            const SizedBox(height: 4),
            AnimatedContainer(
              key: ValueKey<String>('stylish-indicator-${destination.label}'),
              duration: motion.duration,
              curve: Curves.fastOutSlowIn,
              width: selected
                  ? style.dotStyle == AdaptiveStylishDotStyle.circle
                      ? style.dotSize
                      : style.tileWidth
                  : 0,
              height: selected ? style.indicatorHeight : 0,
              decoration: BoxDecoration(
                color: config.theme.selectedColor,
                borderRadius: BorderRadius.circular(style.dotSize),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StylishBubbleBar extends StatelessWidget {
  const _StylishBubbleBar({
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
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: style.elevation,
      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<double> widths = _weightedWidths(
              totalWidth: constraints.maxWidth,
              count: config.destinations.length,
              activeIndex: config.selectedIndex,
              activeWeight: style.bubbleActiveFlex,
              inactiveWeight: 1,
            );
            return Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  AnimatedContainer(
                    duration: motion.duration,
                    curve: motion.curve,
                    width: widths[index],
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: index == hiddenIndex
                        ? const SizedBox.expand()
                        : _ExpandingCapsuleDestination(
                            destination: destination,
                            selected: index == config.selectedIndex,
                            config: config,
                            motion: motion,
                            height: 44,
                            horizontalPadding: 12,
                            gap: 7,
                            borderRadius: 30,
                            indicatorOpacity: 0.72,
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

class _CenterRaisedBaseBar extends StatelessWidget {
  const _CenterRaisedBaseBar({
    required this.config,
    required this.motion,
    required this.style,
    required this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveCenterRaisedNavStyleConfig style;
  final int hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: style.surfaceElevation,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(style.topRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: style.barHeight,
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                child: index == hiddenIndex
                    ? const SizedBox.expand()
                    : _IconLabelDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        config: config,
                        motion: motion,
                        horizontalPadding: 4,
                        selectedIndicator: false,
                        onTap: () => config.onDestinationSelected(index),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RaisedDestinationOverlay extends StatelessWidget {
  const _RaisedDestinationOverlay({
    required this.config,
    required this.presentation,
    required this.raisedItem,
    required this.raisedIndex,
    required this.child,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavPresentation presentation;
  final AdaptiveRaisedNavItem raisedItem;
  final int raisedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AdaptiveNavDestination destination = config.destinations[raisedIndex];
    final bool selected = config.selectedIndex == raisedIndex;
    final Color background = raisedItem.backgroundColor ??
        Theme.of(context).colorScheme.inverseSurface;
    final Color foreground = raisedItem.foregroundColor ??
        Theme.of(context).colorScheme.onInverseSurface;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double center = _slotCenter(
          width: constraints.maxWidth,
          presentation: presentation,
          config: config,
          index: raisedIndex,
        );
        final double start = center - raisedItem.size / 2;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            PositionedDirectional(
              start: start,
              top: -raisedItem.offset,
              width: raisedItem.size,
              child: Semantics(
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
                        key: const ValueKey<String>('adaptive-raised-button'),
                        color: background,
                        elevation: raisedItem.elevation,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: destination.enabled
                              ? () => config.onDestinationSelected(raisedIndex)
                              : null,
                          child: SizedBox.square(
                            dimension: raisedItem.size,
                            child: Center(
                              child: IconTheme(
                                data: IconThemeData(color: foreground),
                                child: destination.buildIcon(selected: selected),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (raisedItem.showLabel) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: config.theme.labelTextStyle?.copyWith(
                            color: selected
                                ? config.theme.selectedColor
                                : config.theme.foregroundColor,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
      final bool disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnimations) {
        _position = AlwaysStoppedAnimation<double>(
          widget.config.selectedIndex.toDouble(),
        );
        return;
      }
      final double start = _position.value;
      _position = Tween<double>(
        begin: start,
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double position = _position.value;
            final int selectedIndex = widget.config.selectedIndex;
            final AdaptiveNavDestination selected =
                widget.config.destinations[selectedIndex];
            final double logicalCenter = _equalSlotCenter(
              constraints.maxWidth,
              widget.config.destinations.length,
              position,
            );
            final double center = Directionality.of(context) == TextDirection.rtl
                ? constraints.maxWidth - logicalCenter
                : logicalCenter;
            final double buttonStart = center - widget.style.buttonSize / 2;

            return SizedBox(
              height: widget.style.barHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    top: widget.style.surfaceTop,
                    child: ClipPath(
                      clipper: _NotchBarClipper(
                        position: position,
                        itemCount: widget.config.destinations.length,
                        rtl: Directionality.of(context) == TextDirection.rtl,
                        radius: widget.style.notchRadius,
                        depthFactor: widget.style.notchDepthFactor,
                        shoulderFactor: widget.style.notchShoulderFactor,
                      ),
                      child: Material(
                        color: widget.config.theme.backgroundColor,
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
                    left: buttonStart,
                    top: 0,
                    width: widget.style.buttonSize,
                    child: Semantics(
                      button: true,
                      selected: true,
                      enabled: selected.enabled,
                      label: selected.semanticLabel ?? selected.label,
                      child: Tooltip(
                        message: selected.tooltip ?? selected.label,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Material(
                              key: const ValueKey<String>('adaptive-notch-button'),
                              color: widget.config.theme.indicatorColor,
                              elevation: widget.style.buttonElevation,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: selected.enabled
                                    ? () => widget.config
                                        .onDestinationSelected(selectedIndex)
                                    : null,
                                child: SizedBox.square(
                                  dimension: widget.style.buttonSize,
                                  child: Center(
                                    child: IconTheme(
                                      data: IconThemeData(
                                        color: widget.config.theme.selectedColor,
                                      ),
                                      child: selected.buildIcon(selected: true),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.style.showLabel) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                selected.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: widget.config.theme.labelTextStyle?.copyWith(
                                  color: widget.config.theme.selectedColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    return _DestinationSemantics(
      destination: destination,
      selected: false,
      onTap: () => config.onDestinationSelected(index),
      borderRadius: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(color: config.theme.foregroundColor),
            child: destination.buildIcon(selected: false),
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: config.theme.labelTextStyle?.copyWith(
              color: config.theme.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotchBarClipper extends CustomClipper<Path> {
  const _NotchBarClipper({
    required this.position,
    required this.itemCount,
    required this.rtl,
    required this.radius,
    required this.depthFactor,
    required this.shoulderFactor,
  });

  final double position;
  final int itemCount;
  final bool rtl;
  final double radius;
  final double depthFactor;
  final double shoulderFactor;

  @override
  Path getClip(Size size) {
    final double itemWidth = size.width / itemCount;
    final double logicalCenter = itemWidth * position + itemWidth / 2;
    final double center = rtl ? size.width - logicalCenter : logicalCenter;
    final Path path = Path()..moveTo(0, 0);
    path.lineTo(center - radius * shoulderFactor, 0);
    path.cubicTo(
      center - radius,
      0,
      center - radius,
      radius * depthFactor,
      center,
      radius * depthFactor,
    );
    path.cubicTo(
      center + radius,
      radius * depthFactor,
      center + radius,
      0,
      center + radius * shoulderFactor,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _NotchBarClipper oldClipper) {
    return oldClipper.position != position ||
        oldClipper.itemCount != itemCount ||
        oldClipper.rtl != rtl ||
        oldClipper.radius != radius ||
        oldClipper.depthFactor != depthFactor ||
        oldClipper.shoulderFactor != shoulderFactor;
  }
}

class _ExpandingCapsuleDestination extends StatelessWidget {
  const _ExpandingCapsuleDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.height,
    required this.horizontalPadding,
    required this.gap,
    required this.borderRadius,
    required this.indicatorOpacity,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final double height;
  final double horizontalPadding;
  final double gap;
  final double borderRadius;
  final double indicatorOpacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? config.theme.selectedColor ?? Theme.of(context).colorScheme.primary
        : config.theme.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final Color indicator =
        config.theme.indicatorColor ?? Theme.of(context).colorScheme.secondaryContainer;

    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      borderRadius: borderRadius,
      child: Center(
        child: AnimatedContainer(
          duration: motion.duration,
          curve: motion.curve,
          height: height,
          constraints: const BoxConstraints(minWidth: 48),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? horizontalPadding : 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? indicator.withValues(alpha: indicatorOpacity)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: foreground),
                child: destination.buildIcon(selected: selected),
              ),
              AnimatedSize(
                duration: motion.duration,
                curve: motion.curve,
                child: selected
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(start: gap),
                        child: FlexibleLabel(
                          label: destination.label,
                          style: config.theme.labelTextStyle?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlexibleLabel extends StatelessWidget {
  const FlexibleLabel({required this.label, required this.style, super.key});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 76),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

class _IconLabelDestination extends StatelessWidget {
  const _IconLabelDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.horizontalPadding,
    required this.selectedIndicator,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final double horizontalPadding;
  final bool selectedIndicator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? config.theme.selectedColor ?? Theme.of(context).colorScheme.primary
        : config.theme.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return _DestinationSemantics(
      destination: destination,
      selected: selected,
      onTap: onTap,
      borderRadius: 24,
      child: Center(
        child: AnimatedContainer(
          duration: motion.duration,
          curve: motion.curve,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
          decoration: BoxDecoration(
            color: selected && selectedIndicator
                ? config.theme.indicatorColor
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                scale: selected ? 1.06 : 1,
                duration: motion.duration,
                curve: motion.curve,
                child: IconTheme(
                  data: IconThemeData(color: foreground),
                  child: destination.buildIcon(selected: selected),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: config.theme.labelTextStyle?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
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
    required this.borderRadius,
    required this.child,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final double borderRadius;
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
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: destination.enabled ? onTap : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

List<double> _weightedWidths({
  required double totalWidth,
  required int count,
  required int activeIndex,
  required double activeWeight,
  required double inactiveWeight,
}) {
  if (count <= 0) {
    return const <double>[];
  }
  final double totalWeight =
      activeWeight + inactiveWeight * (count - 1).clamp(0, count);
  return List<double>.generate(count, (int index) {
    final double weight = index == activeIndex ? activeWeight : inactiveWeight;
    return totalWidth * weight / totalWeight;
  });
}

double _equalSlotCenter(double width, int count, double position) {
  final double itemWidth = width / count;
  return itemWidth * position + itemWidth / 2;
}

double _slotCenter({
  required double width,
  required AdaptiveNavPresentation presentation,
  required AdaptiveNavBarConfig config,
  required int index,
}) {
  if (presentation.bottomStyle == AdaptiveBottomNavStyle.google) {
    final AdaptiveGoogleNavStyleConfig style =
        presentation.styleConfig is AdaptiveGoogleNavStyleConfig
        ? presentation.styleConfig! as AdaptiveGoogleNavStyleConfig
        : const AdaptiveGoogleNavStyleConfig();
    return _weightedSlotCenter(
      width: width,
      count: config.destinations.length,
      activeIndex: config.selectedIndex,
      targetIndex: index,
      activeWeight: style.activeFlex,
      inactiveWeight: style.inactiveFlex,
    );
  }
  if (presentation.bottomStyle == AdaptiveBottomNavStyle.persistent) {
    final AdaptivePersistentNavStyleConfig style =
        presentation.styleConfig is AdaptivePersistentNavStyleConfig
        ? presentation.styleConfig! as AdaptivePersistentNavStyleConfig
        : const AdaptivePersistentNavStyleConfig();
    return _weightedSlotCenter(
      width: width,
      count: config.destinations.length,
      activeIndex: config.selectedIndex,
      targetIndex: index,
      activeWeight: style.activeFlex,
      inactiveWeight: style.inactiveFlex,
    );
  }
  if (presentation.bottomStyle == AdaptiveBottomNavStyle.stylish) {
    final AdaptiveStylishNavStyleConfig style =
        presentation.styleConfig is AdaptiveStylishNavStyleConfig
        ? presentation.styleConfig! as AdaptiveStylishNavStyleConfig
        : const AdaptiveStylishNavStyleConfig();
    if (style.variant == AdaptiveStylishVariant.bubble) {
      return _weightedSlotCenter(
        width: width,
        count: config.destinations.length,
        activeIndex: config.selectedIndex,
        targetIndex: index,
        activeWeight: style.bubbleActiveFlex,
        inactiveWeight: 1,
      );
    }
  }
  return _equalSlotCenter(width, config.destinations.length, index.toDouble());
}

double _weightedSlotCenter({
  required double width,
  required int count,
  required int activeIndex,
  required int targetIndex,
  required double activeWeight,
  required double inactiveWeight,
}) {
  final List<double> widths = _weightedWidths(
    totalWidth: width,
    count: count,
    activeIndex: activeIndex,
    activeWeight: activeWeight,
    inactiveWeight: inactiveWeight,
  );
  double start = 0;
  for (int i = 0; i < targetIndex; i++) {
    start += widths[i];
  }
  return start + widths[targetIndex] / 2;
}
