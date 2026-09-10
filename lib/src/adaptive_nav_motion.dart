import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Animation configuration shared by adaptive navigation presentations.
@immutable
class AdaptiveNavMotion {
  /// Creates animation configuration.
  const AdaptiveNavMotion({
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
  });

  /// Transition duration.
  final Duration duration;

  /// Curve used when showing/expanding.
  final Curve curve;

  /// Curve used when hiding/collapsing.
  final Curve reverseCurve;
}
