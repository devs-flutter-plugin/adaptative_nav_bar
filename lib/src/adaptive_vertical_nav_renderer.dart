import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_motion.dart';
import 'adaptive_nav_presentation.dart';

abstract final class _VerticalNavMetrics {
  static const double railExtendedMinWidth = 256;
  static const double headerHeight = 56;
  static const double itemExtent = 48;
  static const double itemSpacing = 2;
  static const double railVerticalPadding = 8;
  static const double sidebarVerticalPadding = 4;
  static const double sidebarExpandedHorizontalPadding = 8;
  static const double sidebarCollapsedHorizontalPadding = 6;
  static const double expandedIconLabelGap = 12;
  static const double expandedHorizontalPadding = 12;
  static const double expandedRadius = 14;
  static const double collapsedRadius = 13;
}

/// Internal renderer for built-in rail presentations.
class AdaptiveRailRenderer extends StatelessWidget {
  /// Creates a rail renderer.
  const AdaptiveRailRenderer({
    required this.config,
    required this.presentation,
    required this.motion,
    super.key,
  });

  /// Resolved navigation state.
  final AdaptiveNavBarConfig config;

  /// Rail presentation.
  final AdaptiveNavPresentation presentation;

  /// Effective motion configuration, already reduced when animations are off.
  final AdaptiveNavMotion motion;

  @override
  Widget build(BuildContext context) {
    final bool railExtended =
        config.expanded &&
        presentation.width >= _VerticalNavMetrics.railExtendedMinWidth;
    return switch (presentation.railStyle) {
      AdaptiveRailStyle.compact => _DenseRail(
        config: config,
        motion: motion,
        showIndicator: false,
      ),
      AdaptiveRailStyle.indicator when !railExtended => _DenseRail(
        config: config,
        motion: motion,
      ),
      _ => NavigationRail(
        selectedIndex: config.selectedIndex,
        onDestinationSelected: config.onDestinationSelected,
        extended: railExtended,
        useIndicator: true,
        indicatorColor: config.theme.indicatorColor,
        destinations: <NavigationRailDestination>[
          for (final AdaptiveNavDestination destination in config.destinations)
            NavigationRailDestination(
              icon: destination.buildIcon(selected: false),
              selectedIcon: destination.buildIcon(selected: true),
              label: Text(destination.label),
              disabled: !destination.enabled,
            ),
        ],
      ),
    };
  }
}

class _DenseRail extends StatelessWidget {
  const _DenseRail({
    required this.config,
    required this.motion,
    this.showIndicator = true,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor,
      elevation: config.theme.elevation ?? 0,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: _VerticalNavMetrics.railVerticalPadding,
          ),
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _VerticalNavMetrics.itemSpacing,
                ),
                child: _VerticalDestination(
                  destination: destination,
                  selected: index == config.selectedIndex,
                  expanded: false,
                  showIndicator: showIndicator,
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

/// Internal renderer for persistent sidebars.
class AdaptiveSidebarRenderer extends StatelessWidget {
  /// Creates a sidebar renderer.
  const AdaptiveSidebarRenderer({
    required this.config,
    required this.presentation,
    required this.motion,
    required this.onToggleExpanded,
    super.key,
  });

  /// Resolved navigation state.
  final AdaptiveNavBarConfig config;

  /// Sidebar presentation.
  final AdaptiveNavPresentation presentation;

  /// Effective motion configuration, already reduced when animations are off.
  final AdaptiveNavMotion motion;

  /// Toggles expanded/collapsed state.
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final bool minimal =
        presentation.sidebarStyle == AdaptiveSidebarStyle.minimal;
    final bool material =
        presentation.sidebarStyle == AdaptiveSidebarStyle.material3;
    final Color? background = config.theme.backgroundColor;
    final BorderRadius radius = material
        ? BorderRadius.zero
        : config.theme.borderRadius ?? BorderRadius.zero;

    return Material(
      color: background,
      elevation: material ? 0 : config.theme.elevation ?? 0,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _VerticalNavMetrics.headerHeight,
              child: Align(
                alignment: config.expanded
                    ? AlignmentDirectional.centerEnd
                    : Alignment.center,
                child: IconButton(
                  tooltip: config.expanded
                      ? 'Collapse navigation'
                      : 'Expand navigation',
                  onPressed: onToggleExpanded,
                  icon: AnimatedRotation(
                    duration: motion.duration,
                    curve: motion.curve,
                    turns: config.expanded ? 0 : 0.5,
                    child: const Icon(Icons.keyboard_double_arrow_left),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: config.expanded
                      ? _VerticalNavMetrics.sidebarExpandedHorizontalPadding
                      : _VerticalNavMetrics.sidebarCollapsedHorizontalPadding,
                  vertical: _VerticalNavMetrics.sidebarVerticalPadding,
                ),
                children: <Widget>[
                  for (final (int index, AdaptiveNavDestination destination)
                      in config.destinations.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _VerticalNavMetrics.itemSpacing,
                      ),
                      child: _VerticalDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        expanded: config.expanded,
                        showIndicator: !minimal,
                        config: config,
                        motion: motion,
                        onTap: () => config.onDestinationSelected(index),
                      ),
                    ),
                ],
              ),
            ),
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
    required this.showIndicator,
    required this.config,
    required this.motion,
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final bool expanded;
  final bool showIndicator;
  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? config.theme.selectedColor
        : config.theme.foregroundColor;
    final double radiusValue = expanded
        ? _VerticalNavMetrics.expandedRadius
        : _VerticalNavMetrics.collapsedRadius;
    final BorderRadius radius = BorderRadius.circular(radiusValue);
    final double opacity = destination.enabled
        ? 1
        : config.theme.disabledOpacity ?? 0.38;
    final double iconSize = selected
        ? config.theme.selectedIconSize ?? 24
        : config.theme.iconSize ?? 24;

    final Widget item = AnimatedContainer(
      duration: motion.duration,
      curve: motion.curve,
      width: expanded ? double.infinity : _VerticalNavMetrics.itemExtent,
      height: _VerticalNavMetrics.itemExtent,
      padding: expanded
          ? const EdgeInsets.symmetric(
              horizontal: _VerticalNavMetrics.expandedHorizontalPadding,
            )
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: selected && showIndicator ? config.theme.indicatorColor : null,
        borderRadius: radius,
      ),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(color: foreground, size: iconSize),
            child: destination.buildIcon(selected: selected),
          ),
          if (expanded) ...<Widget>[
            const SizedBox(width: _VerticalNavMetrics.expandedIconLabelGap),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: motion.duration,
                curve: motion.curve,
                style:
                    config.theme.labelTextStyle?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ) ??
                    TextStyle(color: foreground),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
        child: Opacity(
          opacity: opacity,
          child: InkWell(
            onTap: destination.enabled ? onTap : null,
            borderRadius: radius,
            child: Center(child: item),
          ),
        ),
      ),
    );
  }
}
