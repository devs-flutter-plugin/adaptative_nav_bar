# Contributing

## Development requirements

- Flutter stable used by CI: `3.47.2`.
- Dart compatible with the root `pubspec.yaml`.
- Do not introduce `package:flutter/material.dart`; use `package:material_ui/material_ui.dart` for Material components.
- Keep the package core router-agnostic.

## Before opening a pull request

Run:

```bash
flutter pub get
dart format .
flutter analyze
flutter test

cd example
flutter pub get
flutter analyze
```

Then validate publication metadata from the repository root:

```bash
dart pub publish --dry-run
```

## Public API rules

- Prefer additive style/configuration APIs.
- Avoid route-specific fields on `AdaptiveNavDestination`.
- New renderers must consume the common destination/config contract.
- Add tests for every public behavior.
- Document public APIs and update the changelog for user-visible changes.
