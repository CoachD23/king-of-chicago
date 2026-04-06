import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Return fire projectile in the Drive-By mini-game.
///
/// Moves from right to left across the screen.
/// Collision with the player car causes damage.
class DriveByProjectile extends CircleComponent {
  /// Horizontal speed in pixels per second.
  final double speed;

  bool _consumed = false;

  /// Diameter for collision detection.
  static const double bulletSize = 12.0;

  DriveByProjectile({
    required Vector2 position,
    required this.speed,
  }) : super(
          position: position,
          radius: bulletSize / 2,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFF4400),
        );

  bool get isConsumed => _consumed;

  /// Mark as consumed (hit the player).
  void consume() {
    _consumed = true;
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_consumed) return;

    // Move left.
    position.x -= speed * dt;

    // Remove if offscreen.
    if (position.x < -bulletSize) {
      removeFromParent();
    }
  }
}
