import 'package:material_ui/material_ui.dart';

import 'adaptive_nav_bar_config.dart';
import 'adaptive_nav_destination.dart';
import 'adaptive_nav_presentation.dart';

/// Internal renderer for built-in rail presentations.
class AdaptiveRailRenderer extends StatelessWidget {
  /// Creates a rail renderer.
  const AdaptiveRailRenderer({
    required this.config,
    required this.presentation,
    super.key,
  });

  /// Resolved navigation state.
  final AdaptiveNavBarConfig config;

  /// Rail presentation.
  final AdaptiveNavPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final bool railExtended = config.expanded && presentation.width >= 256;
    return switch (presentation.railStyle) {
      AdaptiveRailStyle.compact => _DenseRail(
        config: config,
        showIndicator: false,
      ),
      AdaptiveRailStyle.indicator when !railExtended => _DenseRail(
        config: config,
      ),
      _ => NavigationRail(
        selectedIndex: config.selectedIndex,
        onDestinationSelected: config.onDestinationSelected,
        extended: railExtended,
        useIndicator: true,
        indicatorColor: presentation.railStyle == AdaptiveRailStyle.indicator
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
      ),
    };
  }
}

class _DenseRail extends StatelessWidget {
  const _DenseRail({required this.config, this.showIndicator = true});

  final AdaptiveNavBarConfig config;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: config.theme.backgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: <Widget>[
            for (final (int index, AdaptiveNavDestination destination)
                in config.destinations.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _VerticalDestination(
                  destination: destination,
                  selected: index == config.selectedIndex,
                  expanded: false,
                  showIndicator: showIndicator,
                  config: config,
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
    required this.onToggleExpanded,
    super.key,
  });

  /// Resolved navigation state.
  final AdaptiveNavBarConfig config;

  /// Sidebar presentation.
  final AdaptiveNavPresentation presentation;

  /// Toggles expanded/collapsed state.
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final bool minimal =
        presentation.sidebarStyle == AdaptiveSidebarStyle.minimal;
    final bool material =
        presentation.sidebarStyle == AdaptiveSidebarStyle.material3;
    final Color? background = minimal
        ? Theme.of(context).colorScheme.surface
        : config.theme.backgroundColor;
    final BorderRadius radius = material
        ? BorderRadius.zero
        : config.theme.borderRadius ?? BorderRadius.zero;

    return Material(
      color: background,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 56,
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
                    duration: const Duration(milliseconds: 180),
                    turns: config.expanded ? 0 : 0.5,
                    child: const Icon(Icons.keyboard_double_arrow_left),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: config.expanded ? 8 : 6,
                  vertical: 4,
                ),
                children: <Widget>[
                  for (final (int index, AdaptiveNavDestination destination)
                      in config.destinations.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _VerticalDestination(
                        destination: destination,
                        selected: index == config.selectedIndex,
                        expanded: config.expanded,
                        showIndicator: !minimal,
                        config: config,
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
    required this.onTap,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final bool expanded;
  final bool showIndicator;
  final AdaptiveNavBarConfig config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = selected
        ? config.theme.selectedColor
        : config.theme.foregroundColor;
    final BorderRadius radius = BorderRadius.circular(expanded ? 14 : 13);

    final Widget item = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: expanded ? double.infinity : 48,
      height: 48,
      padding: expanded
          ? const EdgeInsets.symmetric(horizontal: 12)
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
            data: IconThemeData(color: foreground),
            child: destination.buildIcon(selected: selected),
          ),
          if (expanded) ...<Widget>[
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
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
        child: InkWell(
          onTap: destination.enabled ? onTap : null,
          borderRadius: radius,
          child: Center(child: item),
        ),
      ),
    );
  }
}
