# adaptative_nav_bar

Adaptive, router-agnostic navigation for modern Flutter applications.

`adaptative_nav_bar` keeps **navigation state separate from navigation UI**. Define destinations once, keep the selected index in your app/router, and switch between Material 3 bottom navigation, floating bars, pills, notches, glass surfaces, rails, sidebars, or a custom renderer without rewriting routes.

> Package name note: the repository/package keeps the established `adaptative_nav_bar` name. Public Dart APIs intentionally use the standard English `Adaptive...` naming.

## Highlights

- One controlled API: `selectedIndex` + `onDestinationSelected`.
- Router agnostic: works with Navigator, Router API, `go_router`, Bloc, Riverpod, GetX state, ValueNotifier, or custom state.
- Adaptive by available width, not by device/platform checks.
- Material 3 through Flutter's standalone official `material_ui` package.
- Compact, medium, and expanded window classes.
- Built-in bottom styles: Material 3, floating, pill, notch, bubble, glass, and minimal.
- Built-in rail styles: Material 3, indicator, and compact.
- Built-in sidebar styles: Material-like, collapsible, and minimal.
- Custom navigation builder with a stable `AdaptiveNavBarConfig` contract.
- Optional controller for show/hide and sidebar expansion.
- Scroll-aware hide/show behavior.
- Destination reselect callback for scroll-to-top or branch-reset behavior.
- Badges, selected icons, tooltips, disabled destinations, semantics, SafeArea handling, and reduced-motion support.
- No dependency on `go_router` in the package core.

## Requirements

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0"
```

The package uses the official standalone Material library:

```yaml
dependencies:
  material_ui: ^1.2.0
```

It is continuously validated by this repository with Flutter `3.47.2`.

## Install

When published on pub.dev:

```yaml
dependencies:
  adaptative_nav_bar: ^0.1.0
```

From GitHub tags:

```yaml
dependencies:
  adaptative_nav_bar:
    git:
      url: https://github.com/devs-flutter-plugin/adaptative_nav_bar.git
      ref: v0.1.0
```

## Basic usage

```dart
import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

AdaptiveNavScaffold(
  selectedIndex: selectedIndex,
  onDestinationSelected: (int index) {
    setState(() => selectedIndex = index);
  },
  destinations: const <AdaptiveNavDestination>[
    AdaptiveNavDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Agenda',
      badge: Text('3'),
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
  body: currentPage,
)
```

The defaults automatically use:

| Width | Presentation |
| --- | --- |
| `< 600` | Material 3 bottom `NavigationBar` |
| `600..839` | Material 3 `NavigationRail` |
| `>= 840` | Collapsible sidebar |

The thresholds are configurable with `AdaptiveNavBreakpoints`.

## Switching visual models

Destinations and routing do not change. Only the presentation changes:

```dart
AdaptiveNavScaffold(
  compact: const AdaptiveNavPresentation.bottom(
    bottomStyle: AdaptiveBottomNavStyle.floating,
  ),
  medium: const AdaptiveNavPresentation.rail(
    railStyle: AdaptiveRailStyle.indicator,
  ),
  expanded: const AdaptiveNavPresentation.sidebar(
    sidebarStyle: AdaptiveSidebarStyle.collapsible,
    width: 280,
    collapsedWidth: 80,
  ),
  destinations: destinations,
  selectedIndex: selectedIndex,
  onDestinationSelected: onDestinationSelected,
  body: body,
)
```

To change a floating bar to a notch:

```diff
- bottomStyle: AdaptiveBottomNavStyle.floating,
+ bottomStyle: AdaptiveBottomNavStyle.notch,
```

No route or destination code needs to change.

## Bottom styles

```dart
AdaptiveBottomNavStyle.material3
AdaptiveBottomNavStyle.floating
AdaptiveBottomNavStyle.pill
AdaptiveBottomNavStyle.notch
AdaptiveBottomNavStyle.bubble
AdaptiveBottomNavStyle.glass
AdaptiveBottomNavStyle.minimal
```

The built-in models are original implementations inspired by common navigation patterns found across popular Flutter navigation packages. The package does not copy their navigation architecture or make them runtime dependencies.

## GoRouter + StatefulShellRoute

`adaptative_nav_bar` does not create competing nested navigators. Let `go_router` own branch stacks and give the navigation shell directly to the adaptive scaffold:

```dart
AdaptiveNavScaffold(
  selectedIndex: navigationShell.currentIndex,
  onDestinationSelected: (int index) {
    navigationShell.goBranch(index);
  },
  onDestinationReselected: (int index) {
    navigationShell.goBranch(index, initialLocation: true);
  },
  destinations: destinations,
  body: navigationShell,
)
```

This integrates cleanly with `StatefulShellRoute.indexedStack`, preserving each branch stack in the router instead of duplicating navigation state inside the UI package.

See `example/lib/main.dart` for a complete working example using `go_router`.

## Custom presentation

If none of the built-in surfaces matches your design system, keep the same navigation engine and replace only the renderer:

```dart
AdaptiveNavPresentation.custom(
  axis: Axis.horizontal,
  builder: (BuildContext context, AdaptiveNavBarConfig config) {
    return MyNavigationBar(
      destinations: config.destinations,
      selectedIndex: config.selectedIndex,
      onSelected: config.onDestinationSelected,
    );
  },
)
```

`AdaptiveNavBarConfig` also exposes the current window class, resolved theme, visibility, and expansion state.

## Controller

Selection remains controlled by the caller. The optional controller only manages navigation-surface behavior:

```dart
final controller = AdaptiveNavController();

controller.hide();
controller.show();
controller.toggleVisibility();

controller.collapse();
controller.expand();
controller.toggleExpanded();
controller.clearExpansionOverride();
```

A controller created without an `expanded` value does not force all adaptive surfaces into the same state. Each presentation keeps its own `extended` default until `expand()`, `collapse()`, or `toggleExpanded()` creates an explicit override. `clearExpansionOverride()` restores the per-presentation defaults.

This is important when the same controller is shared across breakpoints: a medium 80 px rail can remain collapsed while an expanded desktop sidebar starts open.

This separation prevents two independent sources of truth for the selected route.

## Hide on scroll

```dart
AdaptiveNavScaffold(
  scrollBehavior: const AdaptiveNavScrollBehavior(
    hideOnScroll: true,
    deltaThreshold: 8,
    showAtStart: true,
    showOnScrollEnd: true,
  ),
  // ...
)
```

For nested or complex scrolling layouts, filter notifications:

```dart
AdaptiveNavScrollBehavior(
  hideOnScroll: true,
  notificationPredicate: (ScrollNotification notification) {
    return notification.depth == 0;
  },
)
```

## Destination reselect

Use `onDestinationReselected` for behaviors such as:

- reset the current `go_router` branch to its initial location;
- scroll the current page to the top;
- refresh the selected destination;
- pop a tab's internal stack.

```dart
onDestinationReselected: (int index) {
  navigationShell.goBranch(index, initialLocation: true);
},
```

## Theme

Per-instance overrides:

```dart
AdaptiveNavScaffold(
  theme: AdaptiveNavThemeData(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    indicatorColor: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(28),
    elevation: 4,
  ),
  // ...
)
```

Or register `AdaptiveNavThemeData` as a `ThemeExtension` on your app's `ThemeData.extensions`.

## Architecture

The package deliberately separates four concerns:

```text
App / Router navigation state
           ↓
AdaptiveNavDestination[]
           ↓
AdaptiveNavScaffold + breakpoints
           ↓
Presentation family (bottom / rail / sidebar / custom)
           ↓
Visual style (Material 3 / floating / notch / glass / ...)
```

See [`doc/architecture.md`](doc/architecture.md) for the design rationale and extension rules.

## Quality gates

CI runs on the organization's self-hosted Flutter runner and validates:

```text
dart format
flutter analyze
flutter test
example flutter analyze
dart pub publish --dry-run
```

Tests cover breakpoints, controller behavior, adaptive presentation selection, reselect behavior, custom builders, and every built-in bottom style.

## Pub.dev readiness

Before a stable `1.0.0`, the intended release process is:

1. CI green on Flutter stable.
2. `dart pub publish --dry-run` without blocking warnings.
3. Public API review and documentation coverage.
4. Example verified on mobile, tablet, desktop, and web.
5. Git tag matching the package version.
6. Publish to pub.dev.

## License

MIT License. Copyright © 2026 Devs Tecnologia.
