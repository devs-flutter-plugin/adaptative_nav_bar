import 'dart:ui' show ImageFilter, Path;

import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';
import 'adaptive_nav_theme.dart';

/// Internal renderer for all built-in bottom navigation presentations.
///
/// The implementation is intentionally router-agnostic. It only renders the
/// controlled [AdaptiveNavBarConfig] contract supplied by AdaptiveNavScaffold.
class AdaptiveBottomNavRenderer extends StatelessWidget {
  /// Creates a built-in bottom navigation renderer.
  const AdaptiveBottomNavRenderer({
    required this.config,
    required this.presentation,
    required this.motion,
    super.key,
  });

  /// Current navigation state and resolved theme.
  final AdaptiveNavBarConfig config;

  /// Bottom presentation configuration.
  final AdaptiveNavPresentation presentation;

  /// Shared motion configuration.
  final AdaptiveNavMotion motion;

  /// Estimated layout footprint reserved by the scaffold for overlay styles.
  static double footprintFor(AdaptiveNavPresentation presentation) {
    final bool raised =
        presentation.raisedItem != null ||
        presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised;
    if (raised || presentation.bottomStyle == AdaptiveBottomNavStyle.notch) {
      return 108;
    }
    return switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.material3 => 0,
      AdaptiveBottomNavStyle.minimal => 76,
      AdaptiveBottomNavStyle.google => 82,
      AdaptiveBottomNavStyle.persistent => 84,
      AdaptiveBottomNavStyle.stylish => 84,
      _ => 92,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (presentation.bottomStyle == AdaptiveBottomNavStyle.material3 &&
        presentation.raisedItem == null) {
      return _MaterialBottomBar(config: config);
    }

    final AdaptiveRaisedNavItem? raisedItem =
        presentation.raisedItem ??
        (presentation.bottomStyle == AdaptiveBottomNavStyle.centerRaised
            ? const AdaptiveRaisedNavItem()
            : null);
    final int? raisedIndex = raisedItem == null
        ? null
        : _resolveRaisedIndex(raisedItem, config.destinations.length);

    Widget bar = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.material3 => _StandardSurfaceBar(
        config: config,
        motion: motion,
        variant: _StandardVariant.material,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.floating => _StandardSurfaceBar(
        config: config,
        motion: motion,
        variant: _StandardVariant.floating,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.pill => _StandardSurfaceBar(
        config: config,
        motion: motion,
        variant: _StandardVariant.pill,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.notch => _AnimatedNotchBottomBar(
        config: config,
        motion: motion,
      ),
      AdaptiveBottomNavStyle.bubble => _ExpandingPersistentBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        strongerIndicator: true,
      ),
      AdaptiveBottomNavStyle.glass => _GlassBottomBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.minimal => _StandardSurfaceBar(
        config: config,
        motion: motion,
        variant: _StandardVariant.minimal,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.persistent => _ExpandingPersistentBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.google => _GoogleBottomBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.stylish => _StylishBottomBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),
      AdaptiveBottomNavStyle.centerRaised => _StandardSurfaceBar(
        config: config,
        motion: motion,
        variant: _StandardVariant.centerRaised,
        hiddenIndex: raisedIndex,
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
    final double horizontalMargin = switch (presentation.bottomStyle) {
      AdaptiveBottomNavStyle.material3 ||
      AdaptiveBottomNavStyle.centerRaised ||
      AdaptiveBottomNavStyle.persistent ||
      AdaptiveBottomNavStyle.stylish => 0,
      AdaptiveBottomNavStyle.minimal => 8,
      _ => 16,
    };
    final double effectiveMaxWidth = presentation.maxWidth ?? 560;
    final double constrainedWidth = (viewportWidth - horizontalMargin * 2)
        .clamp(0.0, effectiveMaxWidth)
        .toDouble();

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: constrainedWidth, child: bar),
      ),
    );
  }

  static int _resolveRaisedIndex(AdaptiveRaisedNavItem item, int count) {
    if (count == 0) {
      return 0;
    }
    final int requested = item.index ?? count ~/ 2;
    assert(
      requested >= 0 && requested < count,
      'AdaptiveRaisedNavItem.index must reference an existing destination.',
    );
    return requested.clamp(0, count - 1);
  }
}

class _MaterialBottomBar extends StatelessWidget {
  const _MaterialBottomBar({required this.config});

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

enum _StandardVariant { material, floating, pill, minimal, centerRaised }

class _StandardSurfaceBar extends StatelessWidget {
  const _StandardSurfaceBar({
    required this.config,
    required this.motion,
    required this.variant,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final _StandardVariant variant;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final bool minimal = variant == _StandardVariant.minimal;
    final BorderRadius radius = switch (variant) {
      _StandardVariant.pill => BorderRadius.circular(40),
      _StandardVariant.floating => BorderRadius.circular(24),
      _StandardVariant.centerRaised => const BorderRadius.vertical(
        top: Radius.circular(22),
      ),
      _StandardVariant.material => BorderRadius.circular(20),
      _StandardVariant.minimal => BorderRadius.circular(24),
    };
    final double height = switch (variant) {
      _StandardVariant.centerRaised => 72,
      _StandardVariant.pill => 62,
      _ => 66,
    };

    return Material(
      color: minimal ? const Color(0x00000000) : surface,
      elevation: minimal
          ? 0
          : variant == _StandardVariant.centerRaised
          ? 2
          : config.theme.elevation ?? 4,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                child: index == hiddenIndex
                    ? const SizedBox.expand()
                    : _StandardDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        variant: variant,
                        theme: config.theme,
                        motion: motion,
                        onTap: () => config.onDestinationSelected(index),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StandardDestination extends StatelessWidget {
  const _StandardDestination({
    required this.destination,
    required this.selected,
    required this.variant,
    required this.theme,
    required this.motion,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final _StandardVariant variant;
  final AdaptiveNavThemeData theme;
  final AdaptiveNavMotion motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? theme.selectedColor
        : theme.foregroundColor;
    final bool pill = variant == _StandardVariant.pill;
    final bool minimal = variant == _StandardVariant.minimal;
    final bool showLabel = !minimal || selected;

    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: AnimatedContainer(
              duration: motion.duration,
              curve: motion.curve,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              padding: EdgeInsets.symmetric(
                horizontal: pill ? 12 : 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: selected && pill ? theme.indicatorColor : null,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedScale(
                    duration: motion.duration,
                    curve: motion.curve,
                    scale: selected ? 1.08 : 1,
                    child: IconTheme(
                      data: IconThemeData(color: foreground),
                      child: destination.buildIcon(selected: selected),
                    ),
                  ),
                  if (showLabel) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.labelTextStyle?.copyWith(
                        color: foreground,
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
      ),
    );
  }
}

class _ExpandingPersistentBar extends StatelessWidget {
  const _ExpandingPersistentBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
    this.strongerIndicator = false,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;
  final bool strongerIndicator;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: config.theme.elevation ?? 3,
      child: SizedBox(
        height: 68,
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                flex: index == config.selectedIndex ? 2 : 1,
                child: index == hiddenIndex
                    ? const SizedBox.expand()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _ExpandingDestination(
                          destination: destination,
                          selected: index == config.selectedIndex,
                          config: config,
                          motion: motion,
                          strongerIndicator: strongerIndicator,
                          onTap: () => config.onDestinationSelected(index),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandingDestination extends StatelessWidget {
  const _ExpandingDestination({
    required this.destination,
    required this.selected,
    required this.config,
    required this.motion,
    required this.strongerIndicator,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final bool strongerIndicator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? config.theme.selectedColor
        : config.theme.foregroundColor;
    final Color? indicator = config.theme.indicatorColor;

    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: motion.duration,
            curve: motion.curve,
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10),
            decoration: BoxDecoration(
              color: selected
                  ? indicator?.withValues(
                      alpha: strongerIndicator ? 0.95 : 0.55,
                    )
                  : const Color(0x00000000),
              borderRadius: BorderRadius.circular(50),
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
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _GoogleBottomBar extends StatelessWidget {
  const _GoogleBottomBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: config.theme.elevation ?? 2,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: <Widget>[
              for (final (int index, AdaptiveNavDestination destination)
                  in config.destinations.indexed)
                Expanded(
                  child: index == hiddenIndex
                      ? const SizedBox.expand()
                      : _GoogleDestination(
                          destination: destination,
                          selected: index == config.selectedIndex,
                          config: config,
                          motion: motion,
                          onTap: () => config.onDestinationSelected(index),
                        ),
                ),
            ],
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
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? config.theme.selectedColor
        : config.theme.foregroundColor;

    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: AnimatedContainer(
              duration: motion.duration,
              curve: Curves.easeOutCubic,
              height: 48,
              constraints: BoxConstraints(
                minWidth: 48,
                maxWidth: selected ? 116 : 48,
              ),
              padding: EdgeInsets.symmetric(horizontal: selected ? 13 : 10),
              decoration: BoxDecoration(
                color: selected ? config.theme.indicatorColor : null,
                borderRadius: BorderRadius.circular(18),
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
                    curve: Curves.easeOutCubic,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 64),
                              child: Text(
                                destination.label,
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
        ),
      ),
    );
  }
}

class _StylishBottomBar extends StatelessWidget {
  const _StylishBottomBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: config.theme.elevation ?? 5,
      child: SizedBox(
        height: 72,
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
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? config.theme.selectedColor
        : config.theme.foregroundColor;

    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedSlide(
                offset: selected ? const Offset(0, -0.12) : Offset.zero,
                duration: motion.duration,
                curve: Curves.fastOutSlowIn,
                child: AnimatedScale(
                  scale: selected ? 1.12 : 1,
                  duration: motion.duration,
                  curve: Curves.fastOutSlowIn,
                  child: IconTheme(
                    data: IconThemeData(color: foreground),
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
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: motion.duration,
                curve: Curves.fastOutSlowIn,
                width: selected ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: config.theme.selectedColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({
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
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color:
              (config.theme.backgroundColor ??
                      Theme.of(context).colorScheme.surface)
                  .withValues(alpha: 0.72),
          elevation: 0,
          child: SizedBox(
            height: 66,
            child: Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  Expanded(
                    child: index == hiddenIndex
                        ? const SizedBox.expand()
                        : _StandardDestination(
                            destination: destination,
                            selected: index == config.selectedIndex,
                            variant: _StandardVariant.floating,
                            theme: config.theme,
                            motion: motion,
                            onTap: () => config.onDestinationSelected(index),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
    final Color background =
        raisedItem.backgroundColor ??
        Theme.of(context).colorScheme.inverseSurface;
    final Color foreground =
        raisedItem.foregroundColor ??
        Theme.of(context).colorScheme.onInverseSurface;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth =
            constraints.maxWidth / config.destinations.length;
        final double start =
            itemWidth * raisedIndex + (itemWidth - raisedItem.size) / 2;

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
                                child: destination.buildIcon(
                                  selected: selected,
                                ),
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

class _AnimatedNotchBottomBar extends StatefulWidget {
  const _AnimatedNotchBottomBar({required this.config, required this.motion});

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;

  @override
  State<_AnimatedNotchBottomBar> createState() =>
      _AnimatedNotchBottomBarState();
}

class _AnimatedNotchBottomBarState extends State<_AnimatedNotchBottomBar>
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
    final double initial = widget.config.selectedIndex.toDouble();
    _position = AlwaysStoppedAnimation<double>(initial);
  }

  @override
  void didUpdateWidget(covariant _AnimatedNotchBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion.duration != widget.motion.duration) {
      _controller.duration = widget.motion.duration;
    }
    if (oldWidget.config.selectedIndex != widget.config.selectedIndex) {
      final double start = _position.value;
      _position =
          Tween<double>(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double position = _position.value;
        final int selectedIndex = widget.config.selectedIndex;
        final AdaptiveNavDestination selected =
            widget.config.destinations[selectedIndex];
        final double logicalAlignment = _alignmentFor(
          position,
          widget.config.destinations.length,
        );
        final double physicalAlignment =
            Directionality.of(context) == TextDirection.rtl
            ? -logicalAlignment
            : logicalAlignment;

        return SizedBox(
          height: 82,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                top: 14,
                child: ClipPath(
                  clipper: _NotchBarClipper(
                    position: position,
                    itemCount: widget.config.destinations.length,
                    rtl: Directionality.of(context) == TextDirection.rtl,
                  ),
                  child: Material(
                    color: widget.config.theme.backgroundColor,
                    elevation: widget.config.theme.elevation ?? 4,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned.fill(
                top: 18,
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
              Align(
                alignment: Alignment(physicalAlignment, -1),
                child: Semantics(
                  button: true,
                  selected: true,
                  enabled: selected.enabled,
                  label: selected.semanticLabel ?? selected.label,
                  child: GestureDetector(
                    onTap: selected.enabled
                        ? () =>
                              widget.config.onDestinationSelected(selectedIndex)
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Material(
                          color: widget.config.theme.indicatorColor,
                          elevation: 5,
                          shape: const CircleBorder(),
                          child: SizedBox.square(
                            dimension: 52,
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _alignmentFor(double position, int count) {
    if (count <= 1) {
      return 0;
    }
    return -1 + 2 * ((position + 0.5) / count);
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
    return Semantics(
      button: true,
      selected: false,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: destination.enabled
            ? () => config.onDestinationSelected(index)
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

class _NotchBarClipper extends CustomClipper<Path> {
  const _NotchBarClipper({
    required this.position,
    required this.itemCount,
    required this.rtl,
  });

  final double position;
  final int itemCount;
  final bool rtl;

  @override
  Path getClip(Size size) {
    final double itemWidth = size.width / itemCount;
    final double logicalCenter = itemWidth * position + itemWidth / 2;
    final double center = rtl ? size.width - logicalCenter : logicalCenter;
    const double radius = 31;
    final Path path = Path()..moveTo(0, 0);
    path.lineTo(center - radius * 1.45, 0);
    path.cubicTo(
      center - radius,
      0,
      center - radius,
      radius * 0.82,
      center,
      radius * 0.82,
    );
    path.cubicTo(
      center + radius,
      radius * 0.82,
      center + radius,
      0,
      center + radius * 1.45,
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
        oldClipper.rtl != rtl;
  }
}
