from pathlib import Path
import re

path = Path('lib/src/adaptive_reference_bottom_nav_renderer.dart')
text = path.read_text()


def replace(old: str, new: str, count: int = 1) -> None:
    global text
    if old not in text:
        raise SystemExit(f'Missing expected renderer block: {old[:180]!r}')
    text = text.replace(old, new, count)


replace(
    "import 'adaptive_bottom_nav_style_config.dart';\n",
    "import 'adaptive_bottom_nav_style_config.dart';\n"
    "import 'adaptive_standard_bottom_nav_style_config.dart';\n",
)

replace(
    '''      AdaptiveBottomNavStyle.centerRaised => 108,
      AdaptiveBottomNavStyle.pill => 76,
      AdaptiveBottomNavStyle.bubble => 72,
      AdaptiveBottomNavStyle.glass => 78,
      AdaptiveBottomNavStyle.minimal => 66,
''',
    '''      AdaptiveBottomNavStyle.centerRaised => 108,
      AdaptiveBottomNavStyle.pill =>
        _configOf<AdaptivePillNavStyleConfig>(
              presentation,
              const AdaptivePillNavStyleConfig(),
            ).barHeight +
            _configOf<AdaptivePillNavStyleConfig>(
              presentation,
              const AdaptivePillNavStyleConfig(),
            ).bottomMargin,
      AdaptiveBottomNavStyle.bubble =>
        _configOf<AdaptiveBubbleNavStyleConfig>(
          presentation,
          const AdaptiveBubbleNavStyleConfig(),
        ).barHeight,
      AdaptiveBottomNavStyle.glass =>
        _configOf<AdaptiveGlassNavStyleConfig>(
              presentation,
              const AdaptiveGlassNavStyleConfig(),
            ).barHeight +
            _configOf<AdaptiveGlassNavStyleConfig>(
              presentation,
              const AdaptiveGlassNavStyleConfig(),
            ).bottomMargin,
      AdaptiveBottomNavStyle.minimal =>
        _configOf<AdaptiveMinimalNavStyleConfig>(
          presentation,
          const AdaptiveMinimalNavStyleConfig(),
        ).barHeight,
''',
)

replace(
    '''      AdaptiveBottomNavStyle.pill => _EqualBar(
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
''',
    '''      AdaptiveBottomNavStyle.pill => _pill(context, raisedIndex),
''',
)

replace(
    '''      AdaptiveBottomNavStyle.bubble => _BubbleBar(
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
''',
    '''      AdaptiveBottomNavStyle.bubble => _bubble(raisedIndex),
      AdaptiveBottomNavStyle.glass => _glass(context, raisedIndex),
      AdaptiveBottomNavStyle.minimal => _minimal(raisedIndex),
''',
)

anchor = '''  Color _surface(BuildContext context) =>
      config.theme.backgroundColor ?? Theme.of(context).colorScheme.surface;
'''
helpers = '''  Widget _pill(BuildContext context, int? hiddenIndex) {
    final AdaptivePillNavStyleConfig style =
        _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        );
    return _EqualBar(
      config: config,
      motion: motion,
      hiddenIndex: hiddenIndex,
      height: style.barHeight,
      radius: style.surfaceRadius,
      elevation: style.surfaceElevation,
      surfaceColor: _surface(context),
      labelMode: _LabelMode.all,
      indicatorMode: _IndicatorMode.iconPill,
      itemHorizontalPadding: style.itemHorizontalPadding,
      edgeInset: style.edgeInset,
      selectedIndicatorWidth: style.selectedIndicatorWidth,
      unselectedIndicatorWidth: style.unselectedIndicatorWidth,
      indicatorHeight: style.indicatorHeight,
      indicatorRadius: style.indicatorRadius,
      labelGap: style.labelGap,
    );
  }

  Widget _bubble(int? hiddenIndex) {
    return _BubbleBar(
      config: config,
      motion: motion,
      style: _config<AdaptiveBubbleNavStyleConfig>(
        const AdaptiveBubbleNavStyleConfig(),
      ),
      hiddenIndex: hiddenIndex,
    );
  }

  Widget _glass(BuildContext context, int? hiddenIndex) {
    return _GlassBar(
      config: config,
      motion: motion,
      style: _config<AdaptiveGlassNavStyleConfig>(
        const AdaptiveGlassNavStyleConfig(),
      ),
      hiddenIndex: hiddenIndex,
    );
  }

  Widget _minimal(int? hiddenIndex) {
    final AdaptiveMinimalNavStyleConfig style =
        _config<AdaptiveMinimalNavStyleConfig>(
          const AdaptiveMinimalNavStyleConfig(),
        );
    return _EqualBar(
      config: config,
      motion: motion,
      hiddenIndex: hiddenIndex,
      height: style.barHeight,
      radius: 0,
      elevation: 0,
      surfaceColor: Colors.transparent,
      labelMode: _LabelMode.all,
      indicatorMode: _IndicatorMode.underline,
      underlineWidth: style.underlineWidth,
      underlineHeight: style.underlineHeight,
      underlineRadius: style.underlineRadius,
      labelGap: style.labelGap,
      indicatorGap: style.indicatorGap,
    );
  }

'''
replace(anchor, helpers + anchor)

replace(
    '''      AdaptiveBottomNavStyle.pill => 10,
      AdaptiveBottomNavStyle.glass => 12,
''',
    '''      AdaptiveBottomNavStyle.pill => _config<AdaptivePillNavStyleConfig>(
        const AdaptivePillNavStyleConfig(),
      ).horizontalMargin,
      AdaptiveBottomNavStyle.glass => _config<AdaptiveGlassNavStyleConfig>(
        const AdaptiveGlassNavStyleConfig(),
      ).horizontalMargin,
''',
)
replace(
    '''      AdaptiveBottomNavStyle.pill || AdaptiveBottomNavStyle.glass => 8,
''',
    '''      AdaptiveBottomNavStyle.pill => _config<AdaptivePillNavStyleConfig>(
        const AdaptivePillNavStyleConfig(),
      ).bottomMargin,
      AdaptiveBottomNavStyle.glass => _config<AdaptiveGlassNavStyleConfig>(
        const AdaptiveGlassNavStyleConfig(),
      ).bottomMargin,
''',
)

replace(
    '''      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,
      AdaptiveBottomNavStyle.persistent =>
''',
    '''      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,
      AdaptiveBottomNavStyle.pill => value is AdaptivePillNavStyleConfig,
      AdaptiveBottomNavStyle.bubble => value is AdaptiveBubbleNavStyleConfig,
      AdaptiveBottomNavStyle.glass => value is AdaptiveGlassNavStyleConfig,
      AdaptiveBottomNavStyle.minimal => value is AdaptiveMinimalNavStyleConfig,
      AdaptiveBottomNavStyle.persistent =>
''',
)

replace(
    '''    this.itemHorizontalPadding = 2,
    this.edgeInset = 0,
    this.topOnlyRadius = false,
  });
''',
    '''    this.itemHorizontalPadding = 2,
    this.edgeInset = 0,
    this.selectedIndicatorWidth = 48,
    this.unselectedIndicatorWidth = 40,
    this.indicatorHeight = 34,
    this.indicatorRadius = 18,
    this.underlineWidth = 20,
    this.underlineHeight = 3,
    this.underlineRadius = 2,
    this.labelGap = 2,
    this.indicatorGap = 3,
    this.topOnlyRadius = false,
  });
''',
)
replace(
    '''  final double itemHorizontalPadding;
  final double edgeInset;
  final bool topOnlyRadius;
''',
    '''  final double itemHorizontalPadding;
  final double edgeInset;
  final double selectedIndicatorWidth;
  final double unselectedIndicatorWidth;
  final double indicatorHeight;
  final double indicatorRadius;
  final double underlineWidth;
  final double underlineHeight;
  final double underlineRadius;
  final double labelGap;
  final double indicatorGap;
  final bool topOnlyRadius;
''',
)
replace(
    '''                            indicatorMode: indicatorMode,
                            onTap: () => config.onDestinationSelected(index),
''',
    '''                            indicatorMode: indicatorMode,
                            selectedIndicatorWidth: selectedIndicatorWidth,
                            unselectedIndicatorWidth: unselectedIndicatorWidth,
                            indicatorHeight: indicatorHeight,
                            indicatorRadius: indicatorRadius,
                            underlineWidth: underlineWidth,
                            underlineHeight: underlineHeight,
                            underlineRadius: underlineRadius,
                            labelGap: labelGap,
                            indicatorGap: indicatorGap,
                            onTap: () => config.onDestinationSelected(index),
''',
)
replace(
    '''    required this.indicatorMode,
    required this.onTap,
''',
    '''    required this.indicatorMode,
    required this.selectedIndicatorWidth,
    required this.unselectedIndicatorWidth,
    required this.indicatorHeight,
    required this.indicatorRadius,
    required this.underlineWidth,
    required this.underlineHeight,
    required this.underlineRadius,
    required this.labelGap,
    required this.indicatorGap,
    required this.onTap,
''',
)
replace(
    '''  final _IndicatorMode indicatorMode;
  final VoidCallback onTap;
''',
    '''  final _IndicatorMode indicatorMode;
  final double selectedIndicatorWidth;
  final double unselectedIndicatorWidth;
  final double indicatorHeight;
  final double indicatorRadius;
  final double underlineWidth;
  final double underlineHeight;
  final double underlineRadius;
  final double labelGap;
  final double indicatorGap;
  final VoidCallback onTap;
''',
)

text = text.replace(
    'data: IconThemeData(color: selected ? selectedColor : normalColor),',
    '''data: IconThemeData(
        color: selected ? selectedColor : normalColor,
        size: selected
            ? config.theme.selectedIconSize
            : config.theme.iconSize,
      ),''',
)
replace(
    '''        width: selected ? 48 : 40,
        height: 34,
''',
    '''        width: selected ? selectedIndicatorWidth : unselectedIndicatorWidth,
        height: indicatorHeight,
''',
)
replace(
    '''          color: selected ? indicator : const Color(0x00000000),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: const Color(0x00000000),
          borderRadius: BorderRadius.circular(18),
''',
    '''          color: selected ? indicator : Colors.transparent,
          borderRadius: BorderRadius.circular(indicatorRadius),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(indicatorRadius),
''',
)
replace(
    '            borderRadius: BorderRadius.circular(18),\n',
    '            borderRadius: BorderRadius.circular(indicatorRadius),\n',
)
replace(
    '      icon = SizedBox(width: 48, height: 34, child: Center(child: icon));\n',
    '''      icon = SizedBox(
        width: unselectedIndicatorWidth,
        height: indicatorHeight,
        child: Center(child: icon),
      );
''',
)
replace(
    '''        width: selected ? 20 : 0,
        height: 3,
''',
    '''        width: selected ? underlineWidth : 0,
        height: underlineHeight,
''',
)
replace(
    '          borderRadius: BorderRadius.circular(2),\n',
    '          borderRadius: BorderRadius.circular(underlineRadius),\n',
)
replace('            const SizedBox(height: 2),\n', '            SizedBox(height: labelGap),\n')
replace(
    '            const SizedBox(height: 3),\n            indicatorWidget,\n',
    '            SizedBox(height: indicatorGap),\n            indicatorWidget,\n',
)

text = re.sub(r'^\s*showOnlySelectedLabel: true,\n', '', text, flags=re.M)
text = text.replace('    required this.showOnlySelectedLabel,\n', '')
text = text.replace('  final bool showOnlySelectedLabel;\n', '')

replace(
    '''class _BubbleBar extends StatelessWidget {
  const _BubbleBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;
''',
    '''class _BubbleBar extends StatelessWidget {
  const _BubbleBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveBubbleNavStyleConfig style;
  final int? hiddenIndex;
''',
)
replace(
    '      elevation: 1,\n      child: SizedBox(\n        height: 70,\n',
    '      elevation: style.elevation,\n      child: SizedBox(\n        height: style.barHeight,\n',
)
replace(
    '                    1.45,\n                    1,\n',
    '                    style.activeFlex,\n                    style.inactiveFlex,\n',
)
replace(
    '''                            activeHeight: 44,
                            activePadding: 10,
                            gap: 6,
                            borderRadius: 24,
                            indicatorOpacity: 0.72,
''',
    '''                            activeHeight: style.itemHeight,
                            activePadding: style.activeHorizontalPadding,
                            gap: style.gap,
                            borderRadius: style.borderRadius,
                            indicatorOpacity: style.indicatorOpacity,
''',
)

replace(
    '''class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;
''',
    '''class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveGlassNavStyleConfig style;
  final int? hiddenIndex;
''',
)
replace(
    '    final BorderRadius radius = BorderRadius.circular(28);\n',
    '    final BorderRadius radius = BorderRadius.circular(style.borderRadius);\n',
)
replace(
    '        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),\n',
    '''        filter: ImageFilter.blur(
          sigmaX: style.blurSigma,
          sigmaY: style.blurSigma,
        ),
''',
)
replace(
    '''          height: 66,
          radius: 28,
          elevation: 0,
          surfaceColor: surface.withValues(alpha: 0.76),
          labelMode: _LabelMode.all,
          indicatorMode: _IndicatorMode.iconPill,
          edgeInset: 4,
''',
    '''          height: style.barHeight,
          radius: style.borderRadius,
          elevation: 0,
          surfaceColor: surface.withValues(alpha: style.surfaceOpacity),
          labelMode: _LabelMode.all,
          indicatorMode: _IndicatorMode.iconPill,
          edgeInset: style.edgeInset,
          selectedIndicatorWidth: style.selectedIndicatorWidth,
          unselectedIndicatorWidth: style.unselectedIndicatorWidth,
          indicatorHeight: style.indicatorHeight,
          indicatorRadius: style.indicatorRadius,
          labelGap: style.labelGap,
''',
)

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

text = text.replace('const Color(0x00000000)', 'Colors.transparent')
path.write_text(text)
