# adaptative_nav_bar

Adaptive, router-agnostic navigation for modern Flutter applications.

`adaptative_nav_bar` keeps **navigation state separate from navigation UI**. Define destinations once, keep the selected index in your app/router, and switch between Material 3 bottom navigation, floating bars, animated notches, expanding capsules, rails, sidebars, or a custom renderer without rewriting routes.

> Package name note: the repository/package keeps the established `adaptative_nav_bar` name. Public Dart APIs intentionally use the standard English `Adaptive...` naming.

## Highlights

- One controlled API: `selectedIndex` + `onDestinationSelected`.
- Router agnostic: works with Navigator, Router API, `go_router`, Bloc, Riverpod, GetX state, ValueNotifier, or custom state.
- Adaptive by available width, not by device/platform checks.
- Material 3 through Flutter's standalone official `material_ui` package.
- Compact, medium, and expanded window classes.
- Reference-inspired bottom styles with independent clean-room implementations.
- Raised middle destination support compatible with mobile primary-action patterns.
- Built-in rail styles: Material 3, dense indicator, and compact.
- Built-in sidebar styles: Material-like, SidebarX-inspired collapsible, and minimal.
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

## Bottom styles

All built-in bottom styles use the same destinations and selection callback:

```dart
AdaptiveBottomNavStyle.material3
AdaptiveBottomNavStyle.floating
AdaptiveBottomNavStyle.pill
AdaptiveBottomNavStyle.notch
AdaptiveBottomNavStyle.bubble
AdaptiveBottomNavStyle.glass
AdaptiveBottomNavStyle.minimal
AdaptiveBottomNavStyle.persistent
AdaptiveBottomNavStyle.google
AdaptiveBottomNavStyle.stylish
AdaptiveBottomNavStyle.centerRaised
```

### Reference fidelity

The package does not import or wrap the reference packages. Each renderer is an original implementation using the same interaction/design family while preserving this package's adaptive architecture.

| Style | Design family |
| --- | --- |
| `material3` | Flutter Material 3 `NavigationBar` |
| `floating` | Floating surface inspired by `flutter_floating_bottom_bar` |
| `notch` | Moving notch + raised selected destination inspired by `animated_notch_bottom_bar` |
| `persistent` | Expanding selected capsule inspired by `persistent_bottom_nav_bar` Style 1 |
| `google` | Selected tab expands horizontally to show its label, matching the Google Nav Bar pattern |
| `stylish` | Animated selected icon with a moving/visible marker inspired by `stylish_bottom_bar` dot-style behavior |
| `centerRaised` | Permanently elevated middle destination inspired by the persistent bottom bar Style 15 family |
| `collapsible` sidebar | Collapsed/extended interaction inspired by SidebarX |

The floating implementation also keeps stable body spacing while hidden, uses SafeArea-aware positioning, and stays controlled by `AdaptiveNavScrollBehavior` rather than owning the application's scroll controller.

## Switching styles

Only the presentation changes:

```dart
AdaptiveNavScaffold(
  compact: const AdaptiveNavPresentation.bottom(
    bottomStyle: AdaptiveBottomNavStyle.google,
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

Changing to another compact renderer does not affect routing:

```diff
- bottomStyle: AdaptiveBottomNavStyle.google,
+ bottomStyle: AdaptiveBottomNavStyle.notch,
```

## Raised middle navigation item

For mobile layouts such as trading, creation, scan, booking, or other primary-action flows, use the dedicated raised-center style:

```dart
AdaptiveNavScaffold(
  compact: const AdaptiveNavPresentation.bottom(
    bottomStyle: AdaptiveBottomNavStyle.centerRaised,
    raisedItem: AdaptiveRaisedNavItem(
      index: 2,
      size: 60,
      offset: 20,
      elevation: 7,
    ),
  ),
  destinations: const <AdaptiveNavDestination>[
    AdaptiveNavDestination(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.explore_outlined),
      label: 'Discover',
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.swap_horiz),
      label: 'Trade',
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.hub_outlined),
      label: 'Grow',
    ),
    AdaptiveNavDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      label: 'Assets',
    ),
  ],
  selectedIndex: selectedIndex,
  onDestinationSelected: onDestinationSelected,
  body: body,
)
```

If `index` is omitted, the middle destination is raised automatically.

The raised item is also composable with other custom bottom styles:

```dart
compact: const AdaptiveNavPresentation.bottom(
  bottomStyle: AdaptiveBottomNavStyle.google,
  raisedItem: AdaptiveRaisedNavItem(
    index: 2,
    size: 58,
    offset: 18,
  ),
),
```

This keeps the primary middle destination inside the normal navigation model. It is not a second routing mechanism and does not need a separate `FloatingActionButton` callback.

For a custom visual identity, configure the raised surface directly:

```dart
raisedItem: AdaptiveRaisedNavItem(
  index: 2,
  size: 62,
  offset: 21,
  elevation: 8,
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,
),
```

`notch` already owns its moving raised destination, so a separate `raisedItem` is not applied to that renderer.

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

A controller created without an `expanded` value does not force all adaptive surfaces into the same state. Each presentation keeps its own `extended` default until `expand()`, `collapse()`, or `toggleExpanded()` creates an override.

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

Use `onDestinationReselected` for behaviors such as resetting the current GoRouter branch, scrolling to the top, refreshing the current destination, or popping an internal branch stack.

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

The package deliberately separates navigation state, adaptive presentation, and visual renderer:

```text
App / Router navigation state
           ↓
AdaptiveNavDestination[]
           ↓
AdaptiveNavScaffold + breakpoints
           ↓
Presentation family (bottom / rail / sidebar / custom)
           ↓
Reference-inspired visual renderer
```

Bottom, rail, and sidebar renderers are maintained independently so adding a new visual model does not grow a single monolithic widget.

See [`doc/architecture.md`](doc/architecture.md) for the design rationale and extension rules.

## Quality gates

CI runs on the organization's self-hosted Flutter runner and validates:

```text
dart format
flutter analyze
flutter test
example flutter analyze
dart pub publish --dry-run
Flutter minimum supported version
Web JavaScript build
Web Wasm build
Android build
Linux build
```

Tests cover breakpoints, controller behavior, adaptive presentation selection, reselect behavior, custom builders, every built-in bottom/rail/sidebar style, narrow-rail overflow regression, and the raised middle destination.

## Pub.dev readiness

Before a stable `1.0.0`, the intended release process is:

1. CI green on supported Flutter versions.
2. `dart pub publish --dry-run` without blocking warnings.
3. Public API review and documentation coverage.
4. Example verified on mobile, tablet, desktop, and web.
5. Git tag matching the package version.
6. Publish to pub.dev.

## License

MIT License. Copyright © 2026 Devs Tecnologia.
