import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/action/qte/ambush_target.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';

/// Main Flame game for the Ambush QTE mini-game.
///
/// Spawns tappable targets one at a time. The player's dread level
/// affects difficulty:
/// - dreadLevel >= 80: fewer total targets (intimidation)
/// - dreadLevel >= 50: more time per target
class AmbushGame extends FlameGame with TapCallbacks {
  /// Current dread level (0-100), affects difficulty.
  final int dreadLevel;

  /// Called when the QTE sequence is complete.
  final void Function(QteResult result) onComplete;

  int _hits = 0;
  int _resolved = 0;
  int _totalTargets = 0;
  double _spawnTimer = 0;
  bool _gameOver = false;
  bool _started = false;

  // Spawn timing
  static const double _spawnInterval = 1.8;

  AmbushGame({
    required this.dreadLevel,
    required this.onComplete,
  });

  int _calculateTotalTargets() {
    // Base: 6 targets
    // High dread (>= 80): intimidation reduces to 4
    // Medium dread (>= 50): reduces to 5
    if (dreadLevel >= 80) return 4;
    if (dreadLevel >= 50) return 5;
    return 6;
  }

  double _calculateTargetLifetime() {
    // Base: 1.5 seconds per target
    // High dread (>= 50): bonus time -> 2.2 seconds
    if (dreadLevel >= 50) return 2.2;
    return 1.5;
  }

  @override
  Future<void> onLoad() async {
    _totalTargets = _calculateTotalTargets();

    // Dark background
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF1A1A2E),
        priority: -1,
      ),
    );

    // "AMBUSH!" title
    add(
      TextComponent(
        text: 'AMBUSH!',
        position: Vector2(size.x / 2, 30),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );

    _started = true;
    _spawnTimer = _spawnInterval; // Trigger immediate first spawn
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_started || _gameOver) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval && _resolved + _activeTargets < _totalTargets) {
      _spawnTimer = 0;
      _spawnTarget();
    }

    // Check completion: all targets resolved
    if (_resolved >= _totalTargets && !_gameOver) {
      _finishGame();
    }
  }

  int get _activeTargets =>
      children.whereType<AmbushTarget>().length;

  void _spawnTarget() {
    final lifetime = _calculateTargetLifetime();
    final target = AmbushTarget.random(
      onResolved: _onTargetResolved,
      lifetime: lifetime,
      areaSize: size,
    );
    add(target);
  }

  void _onTargetResolved({required bool wasHit}) {
    _resolved++;
    if (wasHit) _hits++;
  }

  void _finishGame() {
    _gameOver = true;
    final result = QteResult.fromHitRatio(
      hits: _hits,
      total: _totalTargets,
    );
    onComplete(result);
  }
}
