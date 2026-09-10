import 'package:material_ui/material_ui.dart';

/// Router-agnostic navigation destination shared by every presentation.
@immutable
class AdaptiveNavDestination {
  /// Creates a navigation destination.
  const AdaptiveNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.enabled = true,
    this.semanticLabel,
  });

  /// Icon used when the destination is not selected.
  final Widget icon;

  /// Icon used when the destination is selected.
  final Widget? selectedIcon;

  /// Visible label for the destination.
  final String label;

  /// Optional badge displayed near the icon.
  final Widget? badge;

  /// Optional tooltip. Falls back to [label].
  final String? tooltip;

  /// Whether the destination can be selected.
  final bool enabled;

  /// Optional explicit accessibility label.
  final String? semanticLabel;

  /// Returns the icon for the current selection state, including [badge].
  Widget buildIcon({required bool selected}) {
    final Widget effectiveIcon = selected ? (selectedIcon ?? icon) : icon;
    if (badge == null) {
      return effectiveIcon;
    }
    return Badge(label: badge, child: effectiveIcon);
  }
}
