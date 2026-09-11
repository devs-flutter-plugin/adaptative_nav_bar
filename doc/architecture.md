# Architecture

## Goals

`adaptative_nav_bar` is a presentation package, not a router. Its primary design constraint is that changing navigation visuals must not require rewriting route configuration or application state.

A second design constraint is visual extensibility: reference-inspired bottom bars, rails, and sidebars must be replaceable independently without turning `AdaptiveNavScaffold` into one monolithic widget.

## Controlled navigation contract

The selected route is always supplied by the caller:

```dart
selectedIndex: int
onDestinationSelected: ValueChanged<int>
```

This mirrors Flutter's `NavigationBar` and `NavigationRail` APIs and composes naturally with Router API and `go_router`.

The package intentionally does **not** create one Navigator per destination. Route-stack persistence belongs to the application's router, for example `StatefulShellRoute.indexedStack`.

## Separation of concerns

### Destination model

`AdaptiveNavDestination` contains only renderer-independent information:

- icon;
- selected icon;
- label;
- badge;
- tooltip;
- enabled state;
- semantic label.

It does not contain a route path. A route field would couple the UI package to a specific routing strategy.

### Window classification

`AdaptiveNavBreakpoints` chooses compact, medium, or expanded based on the actual available width from `LayoutBuilder`.

No `Platform.isAndroid`, tablet heuristics, or fixed device-type detection is used.

### Presentation family

`AdaptiveNavPresentation` selects the layout family:

- bottom;
- rail;
- sidebar;
- custom.

A bottom presentation may also carry `AdaptiveRaisedNavItem`, which changes only the visual placement of one existing destination. It does not create a second navigation action or a second source of route state.

### Visual style

A family owns its style enum. Bottom styles are not mixed with rail/sidebar styles. This prevents an ever-growing global style enum where incompatible options appear together.

Bottom renderers are implemented in `adaptive_bottom_nav_renderer.dart`. Rail and sidebar renderers are implemented in `adaptive_vertical_nav_renderer.dart`. `AdaptiveNavScaffold` is responsible only for window classification, placement, body-space reservation, and cross-cutting behavior.

This means a visual renderer can be replaced or expanded without changing routing, destination modeling, or adaptive breakpoints.

### Behavioral state

`AdaptiveNavController` controls surface visibility and optional expansion override only. It never owns the selected destination. This avoids synchronization bugs between router state and UI-controller state.

When no expansion override is set, each presentation keeps its own `extended` default. This is important when a layout moves from a compact rail to an expanded desktop sidebar.

### Cross-cutting behavior

Motion, scroll behavior, and theme are independent configuration objects. New visual models can reuse them without duplicating navigation state logic.

## Reference-inspired renderers

Reference repositories are used to study interaction and layout patterns, not as runtime dependencies and not as navigation architecture.

Examples:

- `flutter_floating_bottom_bar`: floating surface placement, stable body footprint, SafeArea behavior, and scroll visibility concepts;
- `animated_notch_bottom_bar`: moving notch and raised selected item concepts;
- `persistent_bottom_nav_bar` / `persistent_bottom_nav_bar_v2`: interchangeable visual styles and expanding selected item patterns;
- `google_nav_bar`: selected item expands horizontally to reveal its label;
- `stylish_bottom_bar`: animated icon and dot/bubble selection treatments plus raised/FAB-compatible layouts;
- `SidebarX`: dense collapsed/extended sidebar interaction.

The package uses original implementations behind its own controlled API. Direct source-code copying is intentionally avoided so the architecture remains coherent and licensing/attribution obligations stay straightforward.

## Raised destination contract

`AdaptiveRaisedNavItem` can elevate a destination above the normal bottom bar plane. Its index defaults to the middle destination and must always point at an existing `AdaptiveNavDestination`.

The raised destination still invokes the same `config.onDestinationSelected(index)` callback as every other destination. Therefore GoRouter, Navigator, Bloc, Riverpod, GetX state, or any other owner sees no difference between a normal and a raised destination.

The dedicated `centerRaised` style supplies this behavior by default. Other bottom styles can opt into it explicitly through `raisedItem`, except the animated notch renderer, which already owns its raised selected destination.

## Renderer contract

A custom renderer receives `AdaptiveNavBarConfig` and must call `config.onDestinationSelected(index)` when requesting a selection.

It should also honor:

- `destination.enabled`;
- `config.selectedIndex`;
- `config.visible`;
- `config.expanded` where relevant;
- semantics and tooltips;
- minimum accessible touch targets;
- RTL directionality;
- SafeArea constraints;
- reduced-motion settings supplied by the scaffold.

## Compatibility policy

Public APIs live under `lib/` exports. Implementation widgets remain under `lib/src/` and are not exported from the package barrel unless they are intentionally part of the stable API.

New built-in visual styles should normally be additive. A visual redesign should not require changing the destination contract or router integration.

Breaking public API changes require a major version once the package reaches `1.0.0`.
