# Compatibility

`adaptative_nav_bar` is a Dart/Flutter UI package with no platform-channel or native plugin implementation. The core API is therefore platform-independent, while CI verifies representative compilation targets.

## Supported Flutter range

The package declares:

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0"
```

CI validates the package core against both Flutter 3.44.0 (the minimum supported version) and Flutter 3.47.2 (the current project baseline).

## Automated validation

The self-hosted CI performs:

- formatting validation with no automatic repository mutation;
- `flutter analyze` on the package;
- widget/unit tests on the package;
- example analysis with `go_router`;
- `dart pub publish --dry-run`;
- Android debug APK compilation;
- Web JavaScript release compilation;
- Web Wasm release compilation;
- Linux desktop debug compilation.

Tests cover all built-in bottom, rail, and sidebar styles, breakpoints, controlled selection, reselect behavior, controllers, custom builders, scroll-driven visibility, semantic labels, large text scaling, and RTL layout.

## Apple and Windows targets

iOS and macOS builds require macOS runners, and Windows builds require Windows runners. The package contains no native target-specific implementation, but these targets must not be described as CI-verified until matching organization runners are available and included in the matrix.

## Compatibility policy

A stable release must keep the minimum supported Flutter version green, keep the current project Flutter baseline green, and pass the publication dry run. Any future dependency that introduces native code or narrows the supported platform set requires an explicit compatibility review.
