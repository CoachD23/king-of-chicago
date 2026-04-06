import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/ui/theme/game_theme.dart';

/// Possible states for a shootout enemy.
enum EnemyState { idle, aiming, firing, dead }

/// A tappable enemy rectangle in the Shootout mini-game.
///
/// State machine: idle → aiming → firing → dead.
/// The enemy shows a colored indicator:
/// - Yellow during idle
/// - Red (growing) during aiming
/// - Gone after dead
///
/// Tap the enemy while it is alive to kill it.
class ShootoutEnemy extends RectangleComponent with TapCallbacks {
  /// Duration in seconds the enemy aims before firing.
  final double aimDuration;

  /// Called when the enemy fires at the player.
  final VoidCallback onFired;

  /// Called when the enemy is killed by a tap.
  final VoidCallback onKilled;

  /// Called when the enemy expires (retreats) without being killed.
  final VoidCallback onExpired;

  EnemyState _state = EnemyState.idle;
  double _stateTimer = 0;
  bool _resolved = false;

  // Idle duration before the enemy starts aiming.
  static const double _idleDuration = 0.5;

  // After firing, the enemy lingers briefly then retreats.
  static const double _postFireDuration = 0.8;

  // Visual dimensions.
  static const double _width = 36.0;
  static const double _height = 48.0;

  // Aim indicator component — added during aiming state.
  late RectangleComponent _aimIndicator;

  ShootoutEnemy({
    required Vector2 position,
    required this.aimDuration,
    required this.onFired,
    required this.onKilled,
    required this.onExpired,
  }) : super(
          position: position,
          size: Vector2(_width, _height),
          anchor: Anchor.center,
          paint: Paint()..color = GameTheme.ash,
        );

  bool get isDead => _state == EnemyState.dead;

  @override
  Future<void> onLoad() async {
    // Aim indicator — starts as thin bar, grows during aiming.
    _aimIndicator = RectangleComponent(
      position: Vector2(0, -6),
      size: Vector2(_width, 4),
      paint: Paint()..color = const Color(0xFFCCAA00),
    );
    add(_aimIndicator);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_resolved) return;

    _stateTimer += dt;

    switch (_state) {
      case EnemyState.idle:
        if (_stateTimer >= _idleDuration) {
          _state = EnemyState.aiming;
          _stateTimer = 0;
        }
      case EnemyState.aiming:
        // Grow the aim indicator to show progress.
        final progress = (_stateTimer / aimDuration).clamp(0.0, 1.0);
        _aimIndicator.paint.color = Color.lerp(
          const Color(0xFFCCAA00),
          GameTheme.bloodAccent,
          progress,
        )!;
        _aimIndicator.size = Vector2(_width, 4 + 8 * progress);

        if (_stateTimer >= aimDuration) {
          _state = EnemyState.firing;
          _stateTimer = 0;
          onFired();
          // Flash white briefly on fire.
          paint.color = Colors.white;
        }
      case EnemyState.firing:
        if (_stateTimer > 0.1) {
          paint.color = GameTheme.ash;
        }
        if (_stateTimer >= _postFireDuration) {
          _resolve(killed: false);
        }
      case EnemyState.dead:
        break;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_resolved || _state == EnemyState.dead) return;
    takeHit();
  }

  /// Apply a hit to this enemy (kills in one hit).
  void takeHit() {
    if (_resolved) return;
    _resolve(killed: true);
  }

  void _resolve({required bool killed}) {
    if (_resolved) return;
    _resolved = true;
    _state = EnemyState.dead;

    if (killed) {
      onKilled();
    } else {
      onExpired();
    }

    removeFromParent();
  }
}
