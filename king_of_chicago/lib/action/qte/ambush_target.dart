import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// A tappable red circle target that appears during the ambush QTE.
///
/// The target pulses (scale oscillation), fades near end of lifetime,
/// and disappears if not tapped within [lifetime] seconds.
class AmbushTarget extends CircleComponent with TapCallbacks {
  /// Called when this target is tapped or expires.
  final void Function({required bool wasHit}) onResolved;

  /// Total seconds before the target auto-expires.
  final double lifetime;

  double _elapsed = 0;
  bool _resolved = false;

  // Pulse animation state
  double _pulsePhase = 0;
  static const double _pulseSpeed = 6.0;
  static const double _pulseAmplitude = 0.15;
  static const double _baseRadius = 28.0;

  AmbushTarget({
    required this.onResolved,
    required this.lifetime,
    required Vector2 position,
  }) : super(
          radius: _baseRadius,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.red,
        );

  /// Create a target at a random position within the given bounds.
  factory AmbushTarget.random({
    required void Function({required bool wasHit}) onResolved,
    required double lifetime,
    required Vector2 areaSize,
  }) {
    final rng = Random();
    final margin = _baseRadius + 10;
    final x = margin + rng.nextDouble() * (areaSize.x - 2 * margin);
    final y = 80 + rng.nextDouble() * (areaSize.y - 80 - margin);
    return AmbushTarget(
      onResolved: onResolved,
      lifetime: lifetime,
      position: Vector2(x, y),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_resolved) return;

    _elapsed += dt;

    // Pulse animation: oscillate scale
    _pulsePhase += dt * _pulseSpeed;
    final scaleFactor = 1.0 + _pulseAmplitude * sin(_pulsePhase);
    radius = _baseRadius * scaleFactor;

    // Fade out in last 30% of lifetime
    final remaining = 1.0 - (_elapsed / lifetime);
    if (remaining < 0.3) {
      final alpha = (remaining / 0.3).clamp(0.0, 1.0);
      // ignore: deprecated_member_use
      paint.color = Colors.red.withOpacity(alpha);
    }

    // Expire if lifetime exceeded
    if (_elapsed >= lifetime) {
      _resolve(wasHit: false);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_resolved) return;
    _resolve(wasHit: true);
  }

  void _resolve({required bool wasHit}) {
    if (_resolved) return;
    _resolved = true;
    onResolved(wasHit: wasHit);
    removeFromParent();
  }
}
