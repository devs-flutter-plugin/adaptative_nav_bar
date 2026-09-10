// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

/// Imperative visibility and expansion controller for adaptive navigation.
///
/// Destination selection intentionally stays controlled by
/// `selectedIndex`/`onDestinationSelected` so the package remains compatible
/// with Router API solutions such as `go_router`.
class AdaptiveNavController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// When [expanded] is omitted, each adaptive presentation keeps its own
  /// `extended` default. Calling [expand], [collapse], or [toggleExpanded]
  /// creates an explicit expansion override.
  AdaptiveNavController({bool visible = true, bool? expanded})
    : _visible = visible,
      _expanded = expanded;

  bool _visible;
  bool? _expanded;

  /// Whether the current navigation surface is visible.
  bool get visible => _visible;

  /// Explicit expansion override, or `null` to use the presentation default.
  bool? get expanded => _expanded;

  /// Whether an explicit expansion override is currently active.
  bool get hasExpansionOverride => _expanded != null;

  /// Shows the navigation surface.
  void show() => _setVisible(true);

  /// Hides the navigation surface.
  void hide() => _setVisible(false);

  /// Toggles navigation visibility.
  void toggleVisibility() => _setVisible(!_visible);

  /// Expands supported rail/sidebar presentations.
  void expand() => _setExpanded(true);

  /// Collapses supported rail/sidebar presentations.
  void collapse() => _setExpanded(false);

  /// Toggles rail/sidebar expansion.
  ///
  /// [current] should be supplied by a presentation when no explicit override
  /// exists yet, so the first toggle is relative to that presentation state.
  void toggleExpanded([bool current = false]) =>
      _setExpanded(!(_expanded ?? current));

  /// Removes the explicit expansion override and restores presentation defaults.
  void clearExpansionOverride() {
    if (_expanded == null) {
      return;
    }
    _expanded = null;
    notifyListeners();
  }

  void _setExpanded(bool value) {
    if (_expanded == value) {
      return;
    }
    _expanded = value;
    notifyListeners();
  }

  void _setVisible(bool value) {
    if (_visible == value) {
      return;
    }
    _visible = value;
    notifyListeners();
  }
}
