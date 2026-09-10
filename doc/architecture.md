# Architecture

## Goals

`adaptative_nav_bar` is a presentation package, not a router. Its primary design constraint is that changing navigation visuals must not require rewriting route configuration or application state.

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

### Visual style

A family owns its style enum. Bottom styles are not mixed with rail/sidebar styles. This prevents an ever-growing global style enum where incompatible options appear together.

### Behavioral state

`AdaptiveNavController` controls surface visibility and expansion only. It never owns the selected destination. This avoids synchronization bugs between router state and UI-controller state.

### Cross-cutting behavior

Motion, scroll behavior, and theme are independent configuration objects. New visual models can reuse them without duplicating navigation state logic.

## Renderer contract

A custom renderer receives `AdaptiveNavBarConfig` and must call `config.onDestinationSelected(index)` when requesting a selection.

It should also honor:

- `destination.enabled`;
- `config.selectedIndex`;
- `config.visible`;
- `config.expanded` where relevant;
- semantics and tooltips;
- minimum accessible touch targets.

## Compatibility policy

Public APIs live under `lib/` exports. Implementation widgets remain private under `lib/src/`.

New built-in visual styles should normally be additive. A visual redesign should not require changing the destination contract or router integration.

Breaking public API changes require a major version once the package reaches `1.0.0`.
