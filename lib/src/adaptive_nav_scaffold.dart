import 'dart:ui' show ImageFilter, Path;

import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_breakpoints.dart';
import 'adaptive_nav_controller.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';
import 'adaptive_nav_scroll_behavior.dart';
import 'adaptive_nav_theme.dart';

/// A router-agnostic adaptive navigation layout with interchangeable visual
/// presentations.
///
/// The widget deliberately follows Flutter's controlled navigation contract:
/// [selectedIndex] is owned by the caller and destination changes are reported
/// through [onDestinationSelected]. This keeps it compatible with Navigator,
/// Router API, `go_router`, state-management packages, and custom routers.
class AdaptiveNavScaffold extends StatefulWidget {
  /// Creates an adaptive navigation scaffold.
  const AdaptiveNavScaffold({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
    this.onDestinationReselected,
    this.breakpoints = const AdaptiveNavBreakpoints(),
    this.compact = const AdaptiveNavPresentation.bottom(),
    this.medium = const AdaptiveNavPresentation.rail(),
    this.expanded = const AdaptiveNavPresentation.sidebar(),
    this.controller,
    this.motion = const AdaptiveNavMotion(),
    this.scrollBehavior = const AdaptiveNavScrollBehavior(),
    this.theme,
  }) : assert(destinations.length >= 2),
       assert(selectedIndex >= 0),
       assert(selectedIndex < destinations.length);

  /// Main application content.
  final Widget body;

  /// Router-agnostic destination definitions.
  final List<AdaptiveNavDestination> destinations;

  /// Currently selected destination.
  final int selectedIndex;

  /// Called when a different destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Called when the already-selected destination is tapped again.
  final ValueChanged<int>? onDestinationReselected;

  /// Width breakpoints used to choose [compact], [medium], or [expanded].
  final AdaptiveNavBreakpoints breakpoints;

  /// Presentation for compact windows.
  final AdaptiveNavPresentation compact;

  /// Presentation for medium windows.
  final AdaptiveNavPresentation medium;

  /// Presentation for expanded windows.
  final AdaptiveNavPresentation expanded;

  /// Optional imperative visibility/expansion controller.
  final AdaptiveNavController? controller;

  /// Shared motion configuration.
  final AdaptiveNavMotion motion;

  /// Scroll-driven hide/show configuration.
  final AdaptiveNavScrollBehavior scrollBehavior;

  /// Per-instance theme overrides.
  final AdaptiveNavThemeData? theme;

  @override
  State<AdaptiveNavScaffold> createState() => _AdaptiveNavScaffoldState();
}

class _AdaptiveNavScaffoldState extends State<AdaptiveNavScaffold> {
  bool _internalVisible = true;
  bool? _expandedOverride;

  bool get _visible => widget.controller?.visible ?? _internalVisible;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdaptiveNavThemeData theme = AdaptiveNavThemeData.resolve(
      context,
      widget.theme,
    );
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final Duration duration = disableAnimations
        ? Duration.zero
        : widget.motion.duration;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final AdaptiveNavWindowClass windowClass = widget.breakpoints.classify(
          constraints.maxWidth,
        );
        final AdaptiveNavPresentation presentation = switch (windowClass) {
          AdaptiveNavWindowClass.compact => widget.compact,
          AdaptiveNavWindowClass.medium => widget.medium,
          AdaptiveNavWindowClass.expanded => widget.expanded,
        };
        final bool effectiveExpanded =
            widget.controller?.expanded ??
            _expandedOverride ??
            presentation.extended;
        final AdaptiveNavBarConfig config = AdaptiveNavBarConfig(
          destinations: widget.destinations,
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: _selectDestination,
          windowClass: windowClass,
          theme: theme,
          expanded: effectiveExpanded,
          visible: _visible,
        );

        final Widget body = NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.body,
        );

        return switch (presentation.type) {
          AdaptiveNavPresentationType.bottom => _buildBottom(
            body,
            presentation,
            config,
            duration,
          ),
          AdaptiveNavPresentationType.rail => _buildRail(
            body,
            presentation,
            config,
            duration,
          ),
          AdaptiveNavPresentationType.sidebar => _buildSidebar(
            body,
            presentation,
            config,
            duration,
          ),
          AdaptiveNavPresentationType.custom => _buildCustom(
            body,
            presentation,
            config,
            duration,
          ),
        };
      },
    );
  }

  Widget _buildBottom(
    Widget body,
    AdaptiveNavPresentation presentation,
    AdaptiveNavBarConfig config,
    Duration duration,
  ) {
    if (presentation.bottomStyle == AdaptiveBottomNavStyle.material3) {
      return Column(
        children: <Widget>[
          Expanded(child: body),
          _VisibilityMotion(
            visible: _visible,
            duration: duration,
            curve: widget.motion.curve,
            reverseCurve: widget.motion.reverseCurve,
            axis: Axis.vertical,
            child: _MaterialBottomBar(config: config),
          ),
        ],
      );
    }

    final double footprint = _bottomFootprint(presentation.bottomStyle);
    final Widget floatingBar = _VisibilityMotion(
      visible: _visible,
      duration: duration,
      curve: widget.motion.curve,
      reverseCurve: widget.motion.reverseCurve,
      axis: Axis.vertical,
      child: _CustomBottomBar(
        config: config,
        style: presentation.bottomStyle,
        motion: widget.motion,
        maxWidth: presentation.maxWidth,
      ),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: presentation.reserveBodySpace
              ? Padding(
                  padding: EdgeInsets.only(bottom: footprint),
                  child: body,
                )
              : body,
        ),
        PositionedDirectional(start: 0, end: 0, bottom: 0, child: floatingBar),
      ],
    );
  }

  Widget _buildRail(
    Widget body,
    AdaptiveNavPresentation presentation,
    AdaptiveNavBarConfig config,
    Duration duration,
  ) {
    // NavigationRail's Material extended layout requires considerably more
    // width than the default compact rail. Never force extended content into
    // the standard 80 px footprint.
    final bool railExtended = config.expanded && presentation.width >= 256;

    final Widget rail = switch (presentation.railStyle) {
      AdaptiveRailStyle.compact => _CompactRail(
        config: config,
        showIndicator: false,
      ),
      AdaptiveRailStyle.indicator when !railExtended =>
        _CompactRail(config: config),
      _ => _MaterialRail(
        config: config,
        style: presentation.railStyle,
        extended: railExtended,
      ),
    };

    return Row(
      children: <Widget>[
        _VisibilityMotion(
          visible: _visible,
          duration: duration,
          curve: widget.motion.curve,
          reverseCurve: widget.motion.reverseCurve,
          axis: Axis.horizontal,
          child: SizedBox(width: presentation.width, child: rail),
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildSidebar(
    Widget body,
    AdaptiveNavPresentation presentation,
    AdaptiveNavBarConfig config,
    Duration duration,
  ) {
    final double width = config.expanded
        ? presentation.width
        : presentation.collapsedWidth;
    return Row(
      children: <Widget>[
        _VisibilityMotion(
          visible: _visible,
          duration: duration,
          curve: widget.motion.curve,
          reverseCurve: widget.motion.reverseCurve,
          axis: Axis.horizontal,
          child: AnimatedContainer(
            duration: duration,
            curve: widget.motion.curve,
            width: width,
            child: _Sidebar(
              config: config,
              style: presentation.sidebarStyle,
              onToggleExpanded: () => _toggleExpanded(config.expanded),
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildCustom(
    Widget body,
    AdaptiveNavPresentation presentation,
    AdaptiveNavBarConfig config,
    Duration duration,
  ) {
    final Widget custom = _VisibilityMotion(
      visible: _visible,
      duration: duration,
      curve: widget.motion.curve,
      reverseCurve: widget.motion.reverseCurve,
      axis: presentation.axis,
      child: presentation.builder!(context, config),
    );

    if (presentation.axis == Axis.vertical) {
      return Row(
        children: <Widget>[
          custom,
          Expanded(child: body),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Expanded(child: body),
        custom,
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final AdaptiveNavScrollBehavior behavior = widget.scrollBehavior;
    if (!behavior.hideOnScroll) {
      return false;
    }
    if (behavior.notificationPredicate?.call(notification) == false) {
      return false;
    }

    if (behavior.showAtStart &&
        notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      _setVisible(true);
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final double delta = notification.scrollDelta ?? 0;
      if (delta.abs() >= behavior.deltaThreshold) {
        _setVisible(delta < 0);
      }
    } else if (notification is ScrollEndNotification &&
        behavior.showOnScrollEnd) {
      _setVisible(true);
    }
    return false;
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _selectDestination(int index) {
    if (index < 0 || index >= widget.destinations.length) {
      return;
    }
    if (!widget.destinations[index].enabled) {
      return;
    }
    if (index == widget.selectedIndex) {
      widget.onDestinationReselected?.call(index);
      return;
    }
    widget.onDestinationSelected(index);
  }

  void _setVisible(bool value) {
    if (widget.controller != null) {
      if (value) {
        widget.controller!.show();
      } else {
        widget.controller!.hide();
      }
      return;
    }
    if (_internalVisible == value) {
      return;
    }
    setState(() => _internalVisible = value);
  }

  void _toggleExpanded(bool current) {
    if (widget.controller != null) {
      widget.controller!.toggleExpanded(current);
      return;
    }
    setState(() {
      _expandedOverride = !current;
    });
  }

  static double _bottomFootprint(AdaptiveBottomNavStyle style) {
    return switch (style) {
      AdaptiveBottomNavStyle.notch => 108,
      AdaptiveBottomNavStyle.floating ||
      AdaptiveBottomNavStyle.pill ||
      AdaptiveBottomNavStyle.bubble ||
      AdaptiveBottomNavStyle.glass => 92,
      AdaptiveBottomNavStyle.minimal => 80,
      AdaptiveBottomNavStyle.material3 => 0,
    };
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

class _MaterialRail extends StatelessWidget {
  const _MaterialRail({
    required this.config,
    required this.style,
    required this.extended,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveRailStyle style;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: config.selectedIndex,
      onDestinationSelected: config.onDestinationSelected,
      extended: extended,
      useIndicator: true,
      indicatorColor: style == AdaptiveRailStyle.indicator
          ? config.theme.indicatorColor
          : null,
      destinations: <NavigationRailDestination>[
        for (final AdaptiveNavDestination destination in config.destinations)
          NavigationRailDestination(
            icon: destination.buildIcon(selected: false),
            selectedIcon: destination.buildIcon(selected: true),
            label: Text(destination.label),
            disabled: !destination.enabled,
          ),
      ],
    );
  }
}

class _CompactRail extends StatelessWidget {
  const _CompactRail({
    required this.config,
    this.showIndicator = true,
  });

  final AdaptiveNavBarConfig config;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              _VerticalDestination(
                destination: destination,
                selected: index == config.selectedIndex,
                expanded: false,
                theme: config.theme,
                minimal: !showIndicator,
                onTap: () => config.onDestinationSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.config,
    required this.style,
    required this.onToggleExpanded,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveSidebarStyle style;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = style == AdaptiveSidebarStyle.material3
        ? BorderRadius.zero
        : config.theme.borderRadius ?? BorderRadius.zero;
    final Color? color = style == AdaptiveSidebarStyle.minimal
        ? Theme.of(context).colorScheme.surface
        : config.theme.backgroundColor;

    return Material(
      color: color,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                tooltip: config.expanded
                    ? 'Collapse navigation'
                    : 'Expand navigation',
                onPressed: onToggleExpanded,
                icon: Icon(
                  config.expanded
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              _VerticalDestination(
                destination: destination,
                selected: index == config.selectedIndex,
                expanded: config.expanded,
                theme: config.theme,
                minimal: style == AdaptiveSidebarStyle.minimal,
                onTap: () => config.onDestinationSelected(index),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _VerticalDestination extends StatelessWidget {
  const _VerticalDestination({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.theme,
    required this.onTap,
    this.minimal = false,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final bool expanded;
  final AdaptiveNavThemeData theme;
  final VoidCallback onTap;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? theme.selectedColor
        : theme.foregroundColor;
    final Widget icon = destination.buildIcon(selected: selected);
    final BorderRadius borderRadius = BorderRadius.circular(expanded ? 18 : 14);

    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: expanded ? null : 48,
      height: expanded ? null : 48,
      margin: expanded
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(vertical: 2),
      padding: expanded ? theme.itemPadding : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: selected && !minimal ? theme.indicatorColor : null,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(color: foreground),
            child: icon,
          ),
          if (expanded) ...<Widget>[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.labelTextStyle?.copyWith(color: foreground),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: destination.enabled,
      label: destination.semanticLabel ?? destination.label,
      child: Tooltip(
        message: destination.tooltip ?? destination.label,
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          borderRadius: borderRadius,
          child: content,
        ),
      ),
    );
  }
}

class _CustomBottomBar extends StatelessWidget {
  const _CustomBottomBar({
    required this.config,
    required this.style,
    required this.motion,
    required this.maxWidth,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveBottomNavStyle style;
  final AdaptiveNavMotion motion;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double effectiveMaxWidth = maxWidth ?? 560;
    final double horizontalMargin = style == AdaptiveBottomNavStyle.minimal
        ? 8
        : 16;
    final double constrainedWidth = (width - horizontalMargin * 2)
        .clamp(0.0, effectiveMaxWidth)
        .toDouble();

    Widget bar = switch (style) {
      AdaptiveBottomNavStyle.notch => _NotchBottomBar(
        config: config,
        motion: motion,
      ),
      _ => _FlatCustomBottomBar(config: config, style: style, motion: motion),
    };

    if (style == AdaptiveBottomNavStyle.glass) {
      bar = ClipRRect(
        borderRadius: config.theme.borderRadius ?? BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: bar,
        ),
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: constrainedWidth, child: bar),
      ),
    );
  }
}

class _FlatCustomBottomBar extends StatelessWidget {
  const _FlatCustomBottomBar({
    required this.config,
    required this.style,
    required this.motion,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveBottomNavStyle style;
  final AdaptiveNavMotion motion;

  @override
  Widget build(BuildContext context) {
    final bool minimal = style == AdaptiveBottomNavStyle.minimal;
    final bool glass = style == AdaptiveBottomNavStyle.glass;
    final BorderRadius radius = switch (style) {
      AdaptiveBottomNavStyle.pill => BorderRadius.circular(40),
      AdaptiveBottomNavStyle.floating ||
      AdaptiveBottomNavStyle.glass => BorderRadius.circular(28),
      AdaptiveBottomNavStyle.bubble => BorderRadius.circular(24),
      _ => config.theme.borderRadius ?? BorderRadius.circular(24),
    };
    final Color background = glass
        ? (config.theme.backgroundColor ??
                  Theme.of(context).colorScheme.surface)
              .withValues(alpha: 0.72)
        : config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Material(
      color: minimal ? const Color(0x00000000) : background,
      elevation: minimal || glass ? 0 : config.theme.elevation ?? 3,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: style == AdaptiveBottomNavStyle.pill
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 5)
            : const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Row(
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Expanded(
                child: _BottomDestination(
                  destination: destination,
                  selected: index == config.selectedIndex,
                  style: style,
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

class _BottomDestination extends StatelessWidget {
  const _BottomDestination({
    required this.destination,
    required this.selected,
    required this.style,
    required this.theme,
    required this.motion,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final AdaptiveBottomNavStyle style;
  final AdaptiveNavThemeData theme;
  final AdaptiveNavMotion motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool pill = style == AdaptiveBottomNavStyle.pill;
    final bool bubble = style == AdaptiveBottomNavStyle.bubble;
    final bool minimal = style == AdaptiveBottomNavStyle.minimal;
    final Color? foreground = selected
        ? theme.selectedColor
        : theme.foregroundColor;
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
          child: AnimatedContainer(
            duration: motion.duration,
            curve: motion.curve,
            constraints: const BoxConstraints(minHeight: 52),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: EdgeInsets.symmetric(
              horizontal: bubble && selected ? 12 : 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: selected && (pill || bubble) ? theme.indicatorColor : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: bubble && selected
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconTheme(
                        data: IconThemeData(color: foreground),
                        child: destination.buildIcon(selected: true),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          destination.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.labelTextStyle?.copyWith(
                            color: foreground,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
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
    );
  }
}

class _NotchBottomBar extends StatelessWidget {
  const _NotchBottomBar({required this.config, required this.motion});

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            top: 12,
            child: ClipPath(
              clipper: _NotchBarClipper(
                selectedIndex: config.selectedIndex,
                itemCount: config.destinations.length,
              ),
              child: Material(
                color: config.theme.backgroundColor,
                elevation: config.theme.elevation ?? 3,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: <Widget>[
                for (final (int index, AdaptiveNavDestination destination)
                    in config.destinations.indexed)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: index == config.selectedIndex,
                      enabled: destination.enabled,
                      label: destination.semanticLabel ?? destination.label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: destination.enabled
                            ? () => config.onDestinationSelected(index)
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: motion.duration,
                              curve: motion.curve,
                              transform: Matrix4.translationValues(
                                0,
                                index == config.selectedIndex ? -12 : 0,
                                0,
                              ),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: index == config.selectedIndex
                                    ? config.theme.indicatorColor
                                    : const Color(0x00000000),
                                shape: BoxShape.circle,
                              ),
                              child: IconTheme(
                                data: IconThemeData(
                                  color: index == config.selectedIndex
                                      ? config.theme.selectedColor
                                      : config.theme.foregroundColor,
                                ),
                                child: Center(
                                  child: destination.buildIcon(
                                    selected: index == config.selectedIndex,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 22,
                              child: Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: config.theme.labelTextStyle?.copyWith(
                                  color: index == config.selectedIndex
                                      ? config.theme.selectedColor
                                      : config.theme.foregroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotchBarClipper extends CustomClipper<Path> {
  const _NotchBarClipper({
    required this.selectedIndex,
    required this.itemCount,
  });

  final int selectedIndex;
  final int itemCount;

  @override
  Path getClip(Size size) {
    final double itemWidth = size.width / itemCount;
    final double center = itemWidth * selectedIndex + itemWidth / 2;
    const double notchRadius = 30;
    final Path path = Path()..moveTo(0, 0);
    path.lineTo(center - notchRadius * 1.5, 0);
    path.cubicTo(
      center - notchRadius,
      0,
      center - notchRadius,
      notchRadius * 0.82,
      center,
      notchRadius * 0.82,
    );
    path.cubicTo(
      center + notchRadius,
      notchRadius * 0.82,
      center + notchRadius,
      0,
      center + notchRadius * 1.5,
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
    return oldClipper.selectedIndex != selectedIndex ||
        oldClipper.itemCount != itemCount;
  }
}

class _VisibilityMotion extends StatelessWidget {
  const _VisibilityMotion({
    required this.visible,
    required this.duration,
    required this.curve,
    required this.reverseCurve,
    required this.axis,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final Axis axis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Offset hiddenOffset = axis == Axis.vertical
        ? const Offset(0, 1.25)
        : const Offset(-1.05, 0);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : hiddenOffset,
          duration: duration,
          curve: visible ? curve : reverseCurve,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            curve: visible ? curve : reverseCurve,
            child: child,
          ),
        ),
      ),
    );
  }
}
