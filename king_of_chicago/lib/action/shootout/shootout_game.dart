import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';
import 'package:king_of_chicago/action/shootout/shootout_enemy.dart';
import 'package:king_of_chicago/action/shootout/shootout_player.dart';
import 'package:king_of_chicago/ui/theme/game_theme.dart';

/// Immutable configuration derived from Veil stat levels.
///
/// Encapsulates all difficulty modifiers so the game logic
/// stays decoupled from Veil calculations.
class ShootoutConfig {
  final int dreadLevel;
  final int kinshipLevel;
  final int respectLevel;

  ShootoutConfig({
    required this.dreadLevel,
    required this.kinshipLevel,
    required this.respectLevel,
  });

  /// Base enemy count for the shootout.
  int get totalEnemies => 8;

  /// Aim duration in seconds — high dread causes panic (+0.5s).
  double get enemyAimDuration => dreadLevel >= 50 ? 2.5 : 2.0;

  /// Number of ally NPCs that auto-shoot enemies.
  int get allyCount {
    if (kinshipLevel < 40) return 0;
    // Deterministic for same kinship: 1 at 40-69, 2 at 70+.
    return kinshipLevel >= 70 ? 2 : 1;
  }

  /// Whether the first enemy surrenders automatically.
  bool get firstEnemySurrenders => respectLevel >= 60;
}

/// Converts shootout outcome into a [QteResult].
class ShootoutResult {
  ShootoutResult._();

  /// Determine the [QteResult] from shootout outcome metrics.
  ///
  /// - All enemies killed, 0 damage → cleanWin
  /// - All enemies killed, some damage → messyWin
  /// - Player dead → failure
  static QteResult fromOutcome({
    required int enemiesKilled,
    required int totalEnemies,
    required int damageTaken,
    required bool playerDead,
  }) {
    if (playerDead) return QteResult.failure();
    if (enemiesKilled >= totalEnemies && damageTaken == 0) {
      return QteResult.cleanWin();
    }
    if (enemiesKilled >= totalEnemies) return QteResult.messyWin();
    return QteResult.failure();
  }
}

/// Main Flame game for the Shootout cover-based mini-game.
///
/// The player hides behind cover at the bottom of the screen.
/// Tap above cover to pop up and shoot; tap enemies to eliminate them.
/// Enemies spawn one at a time, aim, then fire. If the player is
/// exposed when an enemy fires, the player takes damage.
class ShootoutGame extends FlameGame with TapCallbacks {
  /// Configuration derived from Veil stats.
  final ShootoutConfig config;

  /// Called when the shootout sequence is complete.
  final void Function(QteResult result) onComplete;

  late ShootoutPlayer _player;

  int _enemiesSpawned = 0;
  int _enemiesKilled = 0;
  int _enemiesResolved = 0;
  double _spawnTimer = 0;
  bool _gameOver = false;
  bool _started = false;
  bool _firstEnemySurrendered = false;

  final Random _rng = Random();

  // Spawn timing: random between 1.0 and 2.0 seconds.
  static const double _minSpawnInterval = 1.0;
  static const double _maxSpawnInterval = 2.0;

  // Player auto-duck after this many seconds exposed.
  static const double exposureDuration = 1.5;

  // Ally shoot interval in seconds.
  static const double _allyShootInterval = 3.0;
  double _allyShootTimer = 0;

  ShootoutGame({
    required this.config,
    required this.onComplete,
  });

  @override
  Future<void> onLoad() async {
    // Dark alley background.
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = GameTheme.backgroundColor,
        priority: -2,
      ),
    );

    // Warehouse wall — upper area.
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y * 0.65),
        paint: Paint()..color = const Color(0xFF151210),
        priority: -1,
      ),
    );

    // Alley floor — lower area.
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.65),
        size: Vector2(size.x, size.y * 0.35),
        paint: Paint()..color = GameTheme.surface,
        priority: -1,
      ),
    );

    // Cover barrier.
    final barrierWidth = size.x * 0.4;
    const barrierHeight = 40.0;
    add(
      RectangleComponent(
        position: Vector2(
          (size.x - barrierWidth) / 2,
          size.y * 0.75,
        ),
        size: Vector2(barrierWidth, barrierHeight),
        paint: Paint()..color = GameTheme.smoke,
        priority: 1,
      ),
    );

    // Title text.
    add(
      TextComponent(
        text: 'SHOOTOUT!',
        position: Vector2(size.x / 2, 20),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF8B1A1A),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        priority: 10,
      ),
    );

    // Player component.
    _player = ShootoutPlayer(
      position: Vector2(size.x / 2, size.y * 0.78),
      maxHealth: 3,
    );
    add(_player);

    _started = true;
    // Trigger immediate first spawn.
    _spawnTimer = _maxSpawnInterval;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_started || _gameOver) return;

    // Auto-duck player after exposure duration.
    if (_player.isExposed) {
      _player.exposureTimer += dt;
      if (_player.exposureTimer >= exposureDuration) {
        _player.duck();
      }
    }

    // Enemy spawning.
    _spawnTimer += dt;
    final interval = _minSpawnInterval +
        _rng.nextDouble() * (_maxSpawnInterval - _minSpawnInterval);
    if (_spawnTimer >= interval && _enemiesSpawned < config.totalEnemies) {
      _spawnTimer = 0;
      _spawnEnemy();
    }

    // Ally auto-shoot logic.
    if (config.allyCount > 0) {
      _allyShootTimer += dt;
      if (_allyShootTimer >= _allyShootInterval) {
        _allyShootTimer = 0;
        _allyShoot();
      }
    }

    // Check game over conditions.
    if (_player.health <= 0 && !_gameOver) {
      _finishGame(playerDead: true);
    } else if (_enemiesResolved >= config.totalEnemies && !_gameOver) {
      _finishGame(playerDead: false);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_gameOver) return;

    final tapPos = event.localPosition;
    final coverLine = size.y * 0.75;

    // Tapping above cover pops the player up.
    if (tapPos.y < coverLine && !_player.isExposed) {
      _player.emerge();
    }
  }

  void _spawnEnemy() {
    _enemiesSpawned++;

    // Check if this enemy should surrender.
    final shouldSurrender = config.firstEnemySurrenders &&
        !_firstEnemySurrendered &&
        _enemiesSpawned == 1;

    if (shouldSurrender) {
      _firstEnemySurrendered = true;
      // Auto-kill: counts as killed with no risk.
      _enemiesKilled++;
      _enemiesResolved++;
      return;
    }

    const margin = 40.0;
    final x = margin + _rng.nextDouble() * (size.x - 2 * margin);
    final y = 60 + _rng.nextDouble() * (size.y * 0.45 - 60);

    final enemy = ShootoutEnemy(
      position: Vector2(x, y),
      aimDuration: config.enemyAimDuration,
      onFired: _onEnemyFired,
      onKilled: _onEnemyKilled,
      onExpired: _onEnemyExpired,
    );
    add(enemy);
  }

  void _onEnemyFired() {
    // If player is exposed when enemy fires, take damage.
    if (_player.isExposed) {
      _player.takeDamage();
    }
  }

  void _onEnemyKilled() {
    _enemiesKilled++;
    _enemiesResolved++;
  }

  void _onEnemyExpired() {
    // Enemy retreated without being killed — still resolved.
    _enemiesResolved++;
  }

  void _allyShoot() {
    // Find a living, non-dead enemy and kill it.
    final enemies = children
        .whereType<ShootoutEnemy>()
        .where((e) => !e.isDead)
        .toList();
    if (enemies.isEmpty) return;

    final target = enemies[_rng.nextInt(enemies.length)];
    target.takeHit();
  }

  void _finishGame({required bool playerDead}) {
    _gameOver = true;
    final result = ShootoutResult.fromOutcome(
      enemiesKilled: _enemiesKilled,
      totalEnemies: config.totalEnemies,
      damageTaken: _player.maxHealth - _player.health,
      playerDead: playerDead,
    );
    onComplete(result);
  }
}
