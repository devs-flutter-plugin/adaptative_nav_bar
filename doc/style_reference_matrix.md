# Visual reference matrix

`adaptative_nav_bar` uses independent clean-room renderers. The repositories below are design and interaction references; they are not runtime dependencies and their routing architectures are not copied into this package.

The purpose of this matrix is to make visual intent explicit so future refactors do not accidentally turn distinct styles back into one generic bottom bar.

| Our presentation/style | Reference family | Fidelity contract |
| --- | --- | --- |
| `AdaptiveBottomNavStyle.material3` | Flutter Material 3 | Uses the real `NavigationBar` when no raised item is requested. |
| `AdaptiveBottomNavStyle.floating` | `flutter-floating-bottom-bar` | Floating rounded surface, width constraint, SafeArea positioning, body-space reservation, optional scroll hide/show. |
| `AdaptiveBottomNavStyle.notch` | `animated_notch_bottom_bar` | Notch follows the selected destination; selected destination is raised above the bar and moves with the notch. |
| `AdaptiveBottomNavStyle.persistent` | `persistent_bottom_nav_bar` Style 1 family | Selected destination grows into a horizontal capsule and reveals its label while inactive destinations remain compact. |
| `AdaptiveBottomNavStyle.centerRaised` | `persistent_bottom_nav_bar` Style 15 family | Middle destination is permanently elevated above the bar in a circular primary-action surface with its label below. |
| `AdaptiveBottomNavStyle.google` | `google_nav_bar` | Selected destination expands into a rounded horizontal capsule with icon + label; inactive destinations remain icon-only. |
| `AdaptiveBottomNavStyle.stylish` | `stylish_bottom_bar` Dot/Animated family | Animated selected treatment with a visible selection marker; remains compatible with the package's controlled destination model. |
| `AdaptiveBottomNavStyle.bubble` | `stylish_bottom_bar` Bubble family / persistent expanding family | Selected destination receives a stronger expanding capsule/bubble treatment. |
| `AdaptiveBottomNavStyle.glass` | `stylish_bottom_bar` BarBlur family | Translucent blurred surface with independent destination interaction. |
| `AdaptiveBottomNavStyle.pill` | Common capsule navigation pattern | Compact rounded bar with selected pill indicator. |
| `AdaptiveBottomNavStyle.minimal` | Minimal navigation pattern | Low-chrome bar; inactive destinations stay visually quiet. |
| `AdaptiveSidebarStyle.collapsible` | `SidebarX` | Dense collapsed/extended sidebar, icon-only collapsed state, labels in expanded state, consistent selection indicator. |
| `AdaptiveRailStyle.indicator` | Flutter NavigationRail + compact custom rail | Dense 48 px destination targets with compact indicator and no narrow-width label overflow. |

## Raised primary destination

`AdaptiveRaisedNavItem` is intentionally orthogonal to most bottom styles. This makes the mobile primary-action pattern reusable instead of creating a separate router or special destination type.

```dart
compact: const AdaptiveNavPresentation.bottom(
  bottomStyle: AdaptiveBottomNavStyle.google,
  raisedItem: AdaptiveRaisedNavItem(
    index: 2,
    size: 60,
    offset: 20,
    elevation: 7,
  ),
),
```

The destination still uses the same `selectedIndex` and `onDestinationSelected` contract as every other tab.

The dedicated `centerRaised` style applies the same concept automatically to the middle destination:

```dart
compact: const AdaptiveNavPresentation.bottom(
  bottomStyle: AdaptiveBottomNavStyle.centerRaised,
),
```

## Regression expectations

Every built-in bottom style must render with five destinations at 320, 360, and 390 logical pixels without a layout exception. Reference-specific tests additionally verify the core visual signatures of Google-style expansion, persistent selected-label expansion, animated notch elevation, Stylish selected elevation, and the raised middle destination.

Golden tests may be added later for a curated subset, but structural fidelity tests remain mandatory because they are less sensitive to platform font rasterization and still enforce the interaction/layout contract.
