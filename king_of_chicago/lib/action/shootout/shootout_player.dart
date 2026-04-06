import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/ui/theme/game_theme.dart';

/// The player component in the Shootout mini-game.
///
/// Sits behind cover at the bottom of the screen.
/// Two states: [inCover] and [exposed].
/// Health is displayed as colored dots above the barrier.
class ShootoutPlayer extends PositionComponent {
  /// Maximum health points.
  final int maxHealth;

  int _health;
  bool _isExposed = false;

  // Visual sub-components.
  late RectangleComponent _body;
  final List<CircleComponent> _healthDots = [];

  static const double _bodyWidth = 30.0;
  static const double _bodyHeight = 40.0;

  ShootoutPlayer({
    required Vector2 position,
    required this.maxHealth,
  })  : _health = maxHealth,
        super(
          position: position,
          size: Vector2(_bodyWidth, _bodyHeight),
          anchor: Anchor.center,
        );

  int get health => _health;
  bool get isExposed => _isExposed;

  double exposureTimer = 0;

  @override
  Future<void> onLoad() async {
    _body = RectangleComponent(
      size: Vector2(_bodyWidth, _bodyHeight),
      paint: Paint()..color = GameTheme.goldAccent,
    );
    add(_body);

    // Health dots above the player.
    _buildHealthDots();

    // Start in cover (hidden below barrier).
    duck();
  }

  /// Pop up from cover.
  void emerge() {
    _isExposed = true;
    exposureTimer = 0;
    _body.paint.color = GameTheme.goldHighlight;
    // Move body up to show above cover.
    position.y -= 30;
  }

  /// Duck back behind cover.
  void duck() {
    if (_isExposed) {
      position.y += 30;
    }
    _isExposed = false;
    exposureTimer = 0;
    _body.paint.color = GameTheme.goldAccent;
  }

  /// Take one point of damage.
  void takeDamage() {
    if (_health <= 0) return;
    _health--;
    _updateHealthDots();

    // Flash red briefly.
    _body.paint.color = GameTheme.bloodAccent;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isExposed) {
        _body.paint.color = GameTheme.goldHighlight;
      } else {
        _body.paint.color = GameTheme.goldAccent;
      }
    });
  }

  void _buildHealthDots() {
    for (var i = 0; i < maxHealth; i++) {
      final dot = CircleComponent(
        radius: 5,
        position: Vector2(-20 + i * 14.0, -16),
        paint: Paint()..color = GameTheme.goldAccent,
      );
      _healthDots.add(dot);
      add(dot);
    }
  }

  void _updateHealthDots() {
    for (var i = 0; i < _healthDots.length; i++) {
      _healthDots[i].paint.color =
          i < _health ? GameTheme.goldAccent : GameTheme.bloodAccent;
    }
  }
}
