# Built-in styles

## Bottom

### `material3`
Uses the official `material_ui` `NavigationBar` and `NavigationDestination` widgets.

### `floating`
Rounded floating surface with elevation and persistent labels.

### `pill`
Compact capsule surface with an animated selected-item indicator.

### `notch`
Animated raised selected destination with a moving curved notch in the bar surface.

### `bubble`
The selected destination expands horizontally to combine icon and label in a selection bubble.

### `glass`
Blurred translucent floating surface using `BackdropFilter` while preserving the common destination contract.

### `minimal`
Low-chrome transparent navigation where labels emphasize the selected destination.

## Rail

### `material3`
Official Material 3 `NavigationRail`.

### `indicator`
Material rail using the package theme's stronger selected indicator treatment.

### `compact`
Custom compact vertical destination surface intended for medium layouts.

## Sidebar

### `material3`
Persistent Material-like side navigation.

### `collapsible`
Expandable/collapsible desktop sidebar. It borrows the interaction pattern common to modern sidebar packages without coupling the app to a sidebar-specific controller.

### `minimal`
Reduced-chrome desktop sidebar.

## Custom

Use `AdaptiveNavPresentation.custom` to implement a design-system-specific bar while preserving the stable navigation contract.
