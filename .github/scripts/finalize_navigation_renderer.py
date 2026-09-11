from pathlib import Path

path = Path('lib/src/adaptive_reference_bottom_nav_renderer.dart')
text = path.read_text()


def replace(old: str, new: str, count: int = 1) -> None:
    global text
    if old not in text:
        raise SystemExit(f'Missing expected block: {old[:160]!r}')
    text = text.replace(old, new, count)


# Centralize shared renderer metrics without exposing low-level implementation
# details as public style API.
anchor = "import 'adaptive_nav_presentation.dart';\n\n"
metrics = '''import 'adaptive_nav_presentation.dart';

abstract final class _BottomNavMetrics {
  static const double minimumTouchTarget = 48;
  static const double selectedCapsuleMaxWidth = 132;
  static const double capsuleInnerHorizontalPadding = 2;
  static const double selectedIndicatorWidth = 48;
  static const double unselectedIndicatorWidth = 40;
  static const double iconIndicatorHeight = 34;
  static const double iconIndicatorRadius = 18;
  static const double underlineRadius = 2;
  static const double labelGap = 2;
  static const double indicatorGap = 3;
  static const double dotSize = 6;
  static const double iconBoxWidth = 48;
  static const double iconBoxHeight = 30;
  static const double stylishSurfaceRadius = 22;
  static const double defaultSurfaceElevation = 1;
}

'''
replace(anchor, metrics)

# Remove an obsolete internal parameter that no longer changes rendering.
text = text.replace('                              showOnlySelectedLabel: true,\n', '')
text = text.replace('                            showOnlySelectedLabel: true,\n', '')
text = text.replace('        showOnlySelectedLabel: true,\n', '')
text = text.replace('    required this.showOnlySelectedLabel,\n', '')
text = text.replace('  final bool showOnlySelectedLabel;\n', '')

# Equal-slot icon and indicator metrics.
replace(
    '''        width: selected ? 48 : 40,
        height: 34,
''',
    '''        width: selected
            ? _BottomNavMetrics.selectedIndicatorWidth
            : _BottomNavMetrics.unselectedIndicatorWidth,
        height: _BottomNavMetrics.iconIndicatorHeight,
''',
)
text = text.replace(
    'BorderRadius.circular(18)',
    'BorderRadius.circular(_BottomNavMetrics.iconIndicatorRadius)',
    3,
)
replace(
    '      icon = SizedBox(width: 48, height: 34, child: Center(child: icon));\n',
    '''      icon = SizedBox(
        width: _BottomNavMetrics.unselectedIndicatorWidth,
        height: _BottomNavMetrics.iconIndicatorHeight,
        child: Center(child: icon),
      );
''',
)
replace(
    '          borderRadius: BorderRadius.circular(2),\n',
    '          borderRadius: BorderRadius.circular(_BottomNavMetrics.underlineRadius),\n',
)
replace(
    '''        width: selected ? 6 : 0,
        height: selected ? 6 : 0,
''',
    '''        width: selected ? _BottomNavMetrics.dotSize : 0,
        height: selected ? _BottomNavMetrics.dotSize : 0,
''',
)
text = text.replace(
    '            const SizedBox(height: 2),\n',
    '            const SizedBox(height: _BottomNavMetrics.labelGap),\n',
    1,
)
text = text.replace(
    '            const SizedBox(height: 3),\n            indicatorWidget,\n',
    '            const SizedBox(height: _BottomNavMetrics.indicatorGap),\n            indicatorWidget,\n',
    1,
)

# Capsule shared constraints and padding.
replace(
    '''            constraints: const BoxConstraints(minWidth: 48, maxWidth: 132),
''',
    '''            constraints: const BoxConstraints(
              minWidth: _BottomNavMetrics.minimumTouchTarget,
              maxWidth: _BottomNavMetrics.selectedCapsuleMaxWidth,
            ),
''',
)
replace(
    '''                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
''',
    '''                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _BottomNavMetrics.capsuleInnerHorizontalPadding,
                  ),
''',
)
replace(
    '        : SizedBox(width: 48, height: 48, child: Center(child: icon));\n',
    '''        : const SizedBox.square(
            dimension: _BottomNavMetrics.minimumTouchTarget,
          );

    final Widget inactiveVisual = selected
        ? visual
        : SizedBox.square(
            dimension: _BottomNavMetrics.minimumTouchTarget,
            child: Center(child: icon),
          );
''',
)
replace(
    '      child: Center(child: visual),\n',
    '      child: Center(child: inactiveVisual),\n',
    1,
)

# Stylish bubble should actually use the public bubbleActiveFlex token.
old_surface = '''      child: SizedBox(
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
'''
new_surface = '''      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<double> widths =
                style.variant == AdaptiveStylishVariant.bubble &&
                    hiddenIndex == null
                ? _weightedWidths(
                    constraints.maxWidth,
                    config.destinations.length,
                    config.selectedIndex,
                    style.bubbleActiveFlex,
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
            );
          },
        ),
      ),
'''
replace(old_surface, new_surface)

# Centralize remaining Stylish renderer-only geometry.
replace(
    '        borderRadius: BorderRadius.circular(22),\n',
    '        borderRadius: BorderRadius.circular(_BottomNavMetrics.stylishSurfaceRadius),\n',
)
replace(
    '''                width: 48,
                height: 30,
''',
    '''                width: _BottomNavMetrics.iconBoxWidth,
                height: _BottomNavMetrics.iconBoxHeight,
''',
    1,
)
text = text.replace(
    '          const SizedBox(height: 2),\n',
    '          const SizedBox(height: _BottomNavMetrics.labelGap),\n',
    1,
)
text = text.replace(
    '            const SizedBox(height: 3),\n            marker,\n',
    '            const SizedBox(height: _BottomNavMetrics.indicatorGap),\n            marker,\n',
    1,
)

# Notch surface and inactive destination metrics.
replace(
    '                        elevation: 1,\n',
    '                        elevation: _BottomNavMetrics.defaultSurfaceElevation,\n',
    1,
)
replace(
    '''            width: 48,
            height: 30,
''',
    '''            width: _BottomNavMetrics.iconBoxWidth,
            height: _BottomNavMetrics.iconBoxHeight,
''',
    1,
)
replace(
    '                data: IconThemeData(color: color),\n',
    '''                data: IconThemeData(
                  color: color,
                  size: config.theme.iconSize,
                ),
''',
    1,
)
text = text.replace(
    '          const SizedBox(height: 2),\n',
    '          const SizedBox(height: _BottomNavMetrics.labelGap),\n',
    1,
)

# Keep the notch centered on first/last slots by shrinking its effective radius
# instead of clamping the notch center away from the selected destination.
replace(
    '''    final double safeCenter = center.clamp(
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
''',
    '''    final double availableHalfWidth = math.max(
      0,
      math.min(center, size.width - center),
    );
    final double effectiveRadius = math.max(
      1,
      math.min(radius, availableHalfWidth / shoulderFactor),
    );
    final Path path = Path()..moveTo(0, 0);
    path.lineTo(center - effectiveRadius * shoulderFactor, 0);
    path.cubicTo(
      center - effectiveRadius,
      0,
      center - effectiveRadius,
      effectiveRadius * depthFactor,
      center,
      effectiveRadius * depthFactor,
    );
    path.cubicTo(
      center + effectiveRadius,
      effectiveRadius * depthFactor,
      center + effectiveRadius,
      0,
      center + effectiveRadius * shoulderFactor,
      0,
    );
''',
)

# Raised destinations inherit package theme identity unless explicitly overridden.
replace(
    '''    final Color background =
        backgroundColor ?? Theme.of(context).colorScheme.inverseSurface;
    final Color foreground =
        foregroundColor ?? Theme.of(context).colorScheme.onInverseSurface;
''',
    '''    final Color background =
        backgroundColor ??
        config.theme.indicatorColor ??
        Theme.of(context).colorScheme.inverseSurface;
    final Color foreground =
        foregroundColor ??
        config.theme.selectedColor ??
        Theme.of(context).colorScheme.onInverseSurface;
''',
)
replace(
    '''            Material(
              color: background,
''',
    '''            Material(
              key: const ValueKey<String>('adaptive-raised-visual'),
              color: background,
''',
)
replace(
    '                      data: IconThemeData(color: foreground),\n',
    '''                      data: IconThemeData(
                        color: foreground,
                        size: config.theme.selectedIconSize,
                      ),
''',
    1,
)

path.write_text(text)
