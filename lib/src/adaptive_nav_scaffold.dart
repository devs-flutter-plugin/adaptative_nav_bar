import 'package:material_ui/material_ui.dart';

import 'adaptive_bottom_nav_renderer.dart';
import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_breakpoints.dart';
import 'adaptive_nav_controller.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';
import 'adaptive_nav_scroll_behavior.dart';
import 'adaptive_nav_theme.dart';
import 'adaptive_vertical_nav_renderer.dart';

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
            context,
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
    BuildContext context,
    Widget body,
    AdaptiveNavPresentation presentation,
    AdaptiveNavBarConfig config,
    Duration duration,
  ) {
    final AdaptiveBottomNavRenderer renderer = AdaptiveBottomNavRenderer(
      config: config,
      presentation: presentation,
      motion: widget.motion,
    );

    if (presentation.bottomStyle == AdaptiveBottomNavStyle.material3 &&
        presentation.raisedItem == null) {
      return Column(
        children: <Widget>[
          Expanded(child: body),
          _VisibilityMotion(
            visible: _visible,
            duration: duration,
            curve: widget.motion.curve,
            reverseCurve: widget.motion.reverseCurve,
            axis: Axis.vertical,
            child: renderer,
          ),
        ],
      );
    }

    final double footprint = AdaptiveBottomNavRenderer.footprintFor(presentation);
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final Widget floatingBar = _VisibilityMotion(
      visible: _visible,
      duration: duration,
      curve: widget.motion.curve,
      reverseCurve: widget.motion.reverseCurve,
      axis: Axis.vertical,
      child: renderer,
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: presentation.reserveBodySpace
              ? Padding(
                  padding: EdgeInsets.only(bottom: footprint + safeBottom),
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
    final Widget rail = AdaptiveRailRenderer(
      config: config,
      presentation: presentation,
    );

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
            child: AdaptiveSidebarRenderer(
              config: config,
              presentation: presentation,
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
    setState(() => _expandedOverride = !current);
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
