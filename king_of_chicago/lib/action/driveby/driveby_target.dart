import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/ui/theme/game_theme.dart';

/// A tappable window target in the Drive-By mini-game.
///
/// Appears in the upper portion of the screen (building windows).
/// Highlighted rectangle that scrolls left with the buildings.
/// Tapping it registers a hit and shows a visual effect.
class DriveByTarget extends RectangleComponent with TapCallbacks {
  /// Speed at which the target scrolls left (pixels/second).
  final double scrollSpeed;

  /// Called when the target is successfully tapped.
  final VoidCallback onHit;

  bool _isHit = false;
  double _lifetime = 0;

  // Auto-remove after this many seconds if not hit.
  static const double _maxLifetime = 6.0;

  // Visual dimensions.
  static const double _width = 32.0;
  static const double _height = 28.0;

  DriveByTarget({
    required Vector2 position,
    required this.scrollSpeed,
    required this.onHit,
  }) : super(
          position: position,
          size: Vector2(_width, _height),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFCCAA00),
        );

  @override
  Future<void> onLoad() async {
    // Inner highlight — the "window" glow.
    add(
      RectangleComponent(
        position: Vector2(4, 4),
        size: Vector2(_width - 8, _height - 8),
        paint: Paint()..color = const Color(0x88FFDD44),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isHit) return;

    _lifetime += dt;

    // Scroll left with buildings.
    position.x -= scrollSpeed * dt;

    // Remove if offscreen or expired.
    if (position.x < -_width || _lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isHit) return;
    _isHit = true;

    onHit();

    // Show hit effect: flash to red then remove.
    paint.color = GameTheme.bloodAccent;
    children.whereType<RectangleComponent>().forEach((child) {
      child.paint.color = const Color(0xAAFF2200);
    });

    // Remove after brief flash.
    Future.delayed(const Duration(milliseconds: 300), () {
      removeFromParent();
    });
  }
}
