// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

/// Imperative visibility and expansion controller for adaptive navigation.
///
/// Destination selection intentionally stays controlled by
/// `selectedIndex`/`onDestinationSelected` so the package remains compatible
/// with Router API solutions such as `go_router`.
class AdaptiveNavController extends ChangeNotifier {
  /// Creates a controller.
  AdaptiveNavController({bool visible = true, bool expanded = true})
    : _visible = visible,
      _expanded = expanded;

  bool _visible;
  bool _expanded;

  /// Whether the current navigation surface is visible.
  bool get visible => _visible;

  /// Whether collapsible navigation surfaces should be expanded.
  bool get expanded => _expanded;

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
  void toggleExpanded() => _setExpanded(!_expanded);

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
