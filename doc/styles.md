# Built-in styles

## Theme vs style configuration

The package separates application identity from renderer-specific geometry:

- `AdaptiveNavThemeData` owns shared colors, typography, icon sizing, elevation, disabled opacity, and general surface tokens.
- `AdaptiveBottomNavStyleConfig` implementations own geometry that belongs to one visual family only.
- `AdaptiveNavMotion` owns animation duration and curves across bottom, rail, and sidebar presentations. Reduced-motion preferences resolve to zero-duration animations.

This keeps theme overrides consistent without flattening every built-in renderer into the same shape.

## Bottom

### `material3`
Uses the official `material_ui` `NavigationBar` and `NavigationDestination` widgets. Package theme overrides are forwarded to the Material navigation theme so custom background, indicator, icon, label, and elevation tokens remain consistent with custom renderers.

### `floating`
Rounded floating surface with elevation and persistent labels.

Configuration: `AdaptiveFloatingNavStyleConfig`.

### `pill`
Compact capsule surface with an animated selected-item indicator.

Configuration: `AdaptivePillNavStyleConfig` controls bar height, outer inset, bottom spacing, radius, elevation, edge inset, and destination spacing.

### `notch`
Animated raised selected destination with a moving curved notch in the bar surface.

Configuration: `AdaptiveNotchNavStyleConfig`.

### `bubble`
The selected destination expands horizontally to combine icon and label in a selection bubble.

Configuration: `AdaptiveBubbleNavStyleConfig` controls active/inactive width ratio, bubble height, padding, gap, radius, opacity, and surface elevation.

### `glass`
Blurred translucent floating surface using `BackdropFilter` while preserving the common destination contract.

Configuration: `AdaptiveGlassNavStyleConfig` controls surface height, viewport insets, radius, blur sigma, opacity, and internal edge spacing.

### `minimal`
Low-chrome transparent navigation with a selected underline treatment.

Configuration: `AdaptiveMinimalNavStyleConfig` controls bar height, destination spacing, and underline dimensions.

### `persistent`
Expanding selected capsule inspired by persistent bottom navigation patterns.

Configuration: `AdaptivePersistentNavStyleConfig`.

### `google`
Selected destination expands horizontally to reveal its label while inactive destinations remain compact.

Configuration: `AdaptiveGoogleNavStyleConfig`.

### `stylish`
Animated/dot/bubble/blur family with selectable marker behavior.

Configuration: `AdaptiveStylishNavStyleConfig`.

### `centerRaised`
Classic bottom bar with a permanently elevated primary destination. The raised item defaults to the middle destination with a `60` logical-pixel diameter, `28` logical-pixel upward offset, and elevation `10`.

Configuration: `AdaptiveCenterRaisedNavStyleConfig` plus optional `AdaptiveRaisedNavItem` overrides.

## Rail

### `material3`
Official Material 3 `NavigationRail`. Shared `AdaptiveNavThemeData` tokens are forwarded to the underlying Material rail theme.

### `indicator`
Dense rail using the package theme's selected indicator treatment.

### `compact`
Custom compact vertical destination surface intended for medium layouts.

Rail metrics are centralized internally so compact/indicator variants use one spacing contract instead of unrelated magic numbers.

## Sidebar

### `material3`
Persistent Material-like side navigation.

### `collapsible`
Expandable/collapsible desktop sidebar. It borrows the interaction pattern common to modern sidebar packages without coupling the app to a sidebar-specific controller.

### `minimal`
Reduced-chrome desktop sidebar. Explicit package theme overrides still take precedence over variant defaults.

Sidebar expansion, icon/label transitions, and item animations use `AdaptiveNavMotion` rather than renderer-local durations.

## Theme tokens

`AdaptiveNavThemeData` currently resolves these shared tokens:

- `backgroundColor`
- `foregroundColor`
- `selectedColor`
- `indicatorColor`
- `borderRadius`
- `elevation`
- `itemPadding`
- `labelTextStyle`
- `iconSize`
- `selectedIconSize`
- `disabledOpacity`

Defaults are derived from the application's Material 3 `ColorScheme` and text theme. Style configs should not introduce application-brand colors; they should only describe renderer-specific geometry and visual behavior.

## Custom

Use `AdaptiveNavPresentation.custom` to implement a design-system-specific bar while preserving the stable navigation contract. Custom renderers receive the already-resolved `AdaptiveNavBarConfig.theme` and should honor the same theme/motion/accessibility contract as built-in renderers.
