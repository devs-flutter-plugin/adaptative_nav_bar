from pathlib import Path

path = Path('lib/src/adaptive_reference_bottom_nav_renderer.dart')
text = path.read_text()

def replace(old: str, new: str, label: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f'missing block: {label}')
    text = text.replace(old, new)

replace(
    '''      AdaptiveBottomNavStyle.centerRaised => 108,
      AdaptiveBottomNavStyle.pill => 76,
      AdaptiveBottomNavStyle.bubble => 72,
      AdaptiveBottomNavStyle.glass => 78,
      AdaptiveBottomNavStyle.minimal => 66,''',
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
        ).barHeight,''',
    'footprints',
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
      ),''',
    '''      AdaptiveBottomNavStyle.pill => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        ).barHeight,
        radius: _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        ).borderRadius,
        elevation: _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        ).elevation,
        surfaceColor: _surface(context),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.iconPill,
        edgeInset: _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        ).edgeInset,
        itemHorizontalPadding: _config<AdaptivePillNavStyleConfig>(
          const AdaptivePillNavStyleConfig(),
        ).itemHorizontalPadding,
      ),''',
    'pill renderer',
)

replace(
    '''      AdaptiveBottomNavStyle.bubble => _BubbleBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),''',
    '''      AdaptiveBottomNavStyle.bubble => _BubbleBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveBubbleNavStyleConfig>(
          const AdaptiveBubbleNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),''',
    'bubble renderer call',
)

replace(
    '''      AdaptiveBottomNavStyle.glass => _GlassBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
      ),''',
    '''      AdaptiveBottomNavStyle.glass => _GlassBar(
        config: config,
        motion: motion,
        style: _config<AdaptiveGlassNavStyleConfig>(
          const AdaptiveGlassNavStyleConfig(),
        ),
        hiddenIndex: raisedIndex,
      ),''',
    'glass renderer call',
)

replace(
    '''      AdaptiveBottomNavStyle.minimal => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: 64,
        radius: 0,
        elevation: 0,
        surfaceColor: const Color(0x00000000),
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.underline,
      ),''',
    '''      AdaptiveBottomNavStyle.minimal => _EqualBar(
        config: config,
        motion: motion,
        hiddenIndex: raisedIndex,
        height: _config<AdaptiveMinimalNavStyleConfig>(
          const AdaptiveMinimalNavStyleConfig(),
        ).barHeight,
        radius: 0,
        elevation: 0,
        surfaceColor: Colors.transparent,
        labelMode: _LabelMode.all,
        indicatorMode: _IndicatorMode.underline,
        itemHorizontalPadding: _config<AdaptiveMinimalNavStyleConfig>(
          const AdaptiveMinimalNavStyleConfig(),
        ).itemHorizontalPadding,
        underlineWidth: _config<AdaptiveMinimalNavStyleConfig>(
          const AdaptiveMinimalNavStyleConfig(),
        ).indicatorWidth,
        underlineHeight: _config<AdaptiveMinimalNavStyleConfig>(
          const AdaptiveMinimalNavStyleConfig(),
        ).indicatorHeight,
      ),''',
    'minimal renderer',
)

replace(
    '''      AdaptiveBottomNavStyle.pill => 10,
      AdaptiveBottomNavStyle.glass => 12,''',
    '''      AdaptiveBottomNavStyle.pill => _config<AdaptivePillNavStyleConfig>(
        const AdaptivePillNavStyleConfig(),
      ).horizontalMargin,
      AdaptiveBottomNavStyle.glass => _config<AdaptiveGlassNavStyleConfig>(
        const AdaptiveGlassNavStyleConfig(),
      ).horizontalMargin,''',
    'horizontal margins',
)

replace(
    '''      AdaptiveBottomNavStyle.pill || AdaptiveBottomNavStyle.glass => 8,''',
    '''      AdaptiveBottomNavStyle.pill => _config<AdaptivePillNavStyleConfig>(
        const AdaptivePillNavStyleConfig(),
      ).bottomMargin,
      AdaptiveBottomNavStyle.glass => _config<AdaptiveGlassNavStyleConfig>(
        const AdaptiveGlassNavStyleConfig(),
      ).bottomMargin,''',
    'bottom margins',
)

replace(
    '''      AdaptiveBottomNavStyle.floating =>
        value is AdaptiveFloatingNavStyleConfig,
      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,''',
    '''      AdaptiveBottomNavStyle.floating =>
        value is AdaptiveFloatingNavStyleConfig,
      AdaptiveBottomNavStyle.pill => value is AdaptivePillNavStyleConfig,
      AdaptiveBottomNavStyle.bubble => value is AdaptiveBubbleNavStyleConfig,
      AdaptiveBottomNavStyle.glass => value is AdaptiveGlassNavStyleConfig,
      AdaptiveBottomNavStyle.minimal => value is AdaptiveMinimalNavStyleConfig,
      AdaptiveBottomNavStyle.notch => value is AdaptiveNotchNavStyleConfig,''',
    'style config validation',
)

replace(
    '''    this.itemHorizontalPadding = 2,
    this.edgeInset = 0,
    this.topOnlyRadius = false,''',
    '''    this.itemHorizontalPadding = 2,
    this.edgeInset = 0,
    this.underlineWidth = 20,
    this.underlineHeight = 3,
    this.topOnlyRadius = false,''',
    'equal bar constructor defaults',
)
replace(
    '''  final double itemHorizontalPadding;
  final double edgeInset;
  final bool topOnlyRadius;''',
    '''  final double itemHorizontalPadding;
  final double edgeInset;
  final double underlineWidth;
  final double underlineHeight;
  final bool topOnlyRadius;''',
    'equal bar fields',
)
replace(
    '''                            labelMode: labelMode,
                            indicatorMode: indicatorMode,
                            onTap: () => config.onDestinationSelected(index),''',
    '''                            labelMode: labelMode,
                            indicatorMode: indicatorMode,
                            underlineWidth: underlineWidth,
                            underlineHeight: underlineHeight,
                            onTap: () => config.onDestinationSelected(index),''',
    'equal destination args',
)
replace(
    '''    required this.labelMode,
    required this.indicatorMode,
    required this.onTap,''',
    '''    required this.labelMode,
    required this.indicatorMode,
    required this.underlineWidth,
    required this.underlineHeight,
    required this.onTap,''',
    'equal destination constructor',
)
replace(
    '''  final _LabelMode labelMode;
  final _IndicatorMode indicatorMode;
  final VoidCallback onTap;''',
    '''  final _LabelMode labelMode;
  final _IndicatorMode indicatorMode;
  final double underlineWidth;
  final double underlineHeight;
  final VoidCallback onTap;''',
    'equal destination fields',
)
replace(
    '''        width: selected ? 20 : 0,
        height: 3,''',
    '''        width: selected ? underlineWidth : 0,
        height: underlineHeight,''',
    'minimal underline metrics',
)

replace(
    '''  const _BubbleBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;''',
    '''  const _BubbleBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveBubbleNavStyleConfig style;
  final int? hiddenIndex;''',
    'bubble class fields',
)
text = text.replace('      elevation: 1,\n      child: SizedBox(\n        height: 70,', '      elevation: style.elevation,\n      child: SizedBox(\n        height: style.barHeight,', 1)
text = text.replace('                    1.45,\n                    1,', '                    style.activeFlex,\n                    style.inactiveFlex,', 1)
text = text.replace('                            activeHeight: 44,\n                            activePadding: 10,\n                            gap: 6,\n                            borderRadius: 24,\n                            indicatorOpacity: 0.72,', '                            activeHeight: style.activeHeight,\n                            activePadding: style.activePadding,\n                            gap: style.gap,\n                            borderRadius: style.borderRadius,\n                            indicatorOpacity: style.indicatorOpacity,', 1)

replace(
    '''  const _GlassBar({
    required this.config,
    required this.motion,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final int? hiddenIndex;''',
    '''  const _GlassBar({
    required this.config,
    required this.motion,
    required this.style,
    this.hiddenIndex,
  });

  final AdaptiveNavBarConfig config;
  final AdaptiveNavMotion motion;
  final AdaptiveGlassNavStyleConfig style;
  final int? hiddenIndex;''',
    'glass class fields',
)
replace(
    '''    final BorderRadius radius = BorderRadius.circular(28);''',
    '''    final BorderRadius radius = BorderRadius.circular(style.borderRadius);''',
    'glass radius',
)
replace(
    '''        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),''',
    '''        filter: ImageFilter.blur(
          sigmaX: style.blurSigma,
          sigmaY: style.blurSigma,
        ),''',
    'glass blur',
)
replace(
    '''          height: 66,
          radius: 28,
          elevation: 0,
          surfaceColor: surface.withValues(alpha: 0.76),''',
    '''          height: style.barHeight,
          radius: style.borderRadius,
          elevation: 0,
          surfaceColor: surface.withValues(alpha: style.surfaceOpacity),''',
    'glass equal bar metrics',
)
text = text.replace('          edgeInset: 4,\n', '          edgeInset: style.edgeInset,\n', 1)

text = text.replace('const Color(0x00000000)', 'Colors.transparent')

# Honor global icon-size theme tokens in equal and capsule renderers.
text = text.replace(
    'data: IconThemeData(color: selected ? selectedColor : normalColor),',
    '''data: IconThemeData(
        color: selected ? selectedColor : normalColor,
        size: selected
            ? config.theme.selectedIconSize
            : config.theme.iconSize,
      ),''',
)

path.write_text(text)
