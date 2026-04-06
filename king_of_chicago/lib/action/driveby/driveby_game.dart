import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:king_of_chicago/action/driveby/driveby_projectile.dart';
import 'package:king_of_chicago/action/driveby/driveby_target.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';
import 'package:king_of_chicago/ui/theme/game_theme.dart';

/// Immutable configuration derived from Veil stat levels.
///
/// Encapsulates all difficulty modifiers so the game logic
/// stays decoupled from Veil calculations.
class DriveByConfig {
  final int dreadLevel;
  final int guileLevel;
  final int empirLevel;

  DriveByConfig({
    required this.dreadLevel,
    required this.guileLevel,
    required this.empirLevel,
  });

  /// Total window targets over the run.
  int get totalTargets => 12;

  /// Player health — heavy armor if dread >= 50.
  int get playerHealth => dreadLevel >= 50 ? 4 : 3;

  /// Pre-planted bomb: skip shooting, auto cleanWin.
  bool get hasBombOption => guileLevel >= 60;

  /// Better guns — targets take 1 tap (no precision needed).
  bool get hasImprovedGuns => empirLevel >= 40;
}

/// Converts drive-by outcome into a [QteResult].
class DriveByResult {
  DriveByResult._();

  /// Determine the [QteResult] from drive-by outcome metrics.
  ///
  /// - 80%+ targets hit, 0 damage -> cleanWin (dread +2, legend +2, heat +3)
  /// - 50%+ targets hit -> messyWin (dread +1, legend +1, heat +5)
  /// - Below 50% or dead -> failure (respect -1, heat +8)
  static QteResult fromOutcome({
    required int targetsHit,
    required int totalTargets,
    required int damageTaken,
    required bool playerDead,
  }) {
    if (playerDead) return _failure();
    if (totalTargets <= 0) return _failure();

    final ratio = targetsHit / totalTargets;

    if (ratio >= 0.8 && damageTaken == 0) return _cleanWin();
    if (ratio >= 0.5) return _messyWin();
    return _failure();
  }

  /// Result for using the pre-planted bomb option.
  static QteResult bombResult() => _cleanWin();

  static QteResult _cleanWin() => const QteResult(
        outcome: QteOutcome.cleanWin,
        veilDeltas: {'dread': 2, 'legend': 2},
        heatDelta: 3,
      );

  static QteResult _messyWin() => const QteResult(
        outcome: QteOutcome.messyWin,
        veilDeltas: {'dread': 1, 'legend': 1},
        heatDelta: 5,
      );

  static QteResult _failure() => const QteResult(
        outcome: QteOutcome.failure,
        veilDeltas: {'respect': -1},
        heatDelta: 8,
      );
}

/// Main Flame game for the Drive-By side-scrolling mini-game.
///
/// The player car sits on the left side of the screen. Swipe/drag
/// vertically to move up and down. Tap targets in building windows
/// to shoot them. Dodge return fire projectiles.
class DriveByGame extends FlameGame with TapCallbacks, DragCallbacks {
  /// Configuration derived from Veil stats.
  final DriveByConfig config;

  /// Called when the drive-by sequence is complete.
  final void Function(QteResult result) onComplete;

  int _health = 3;
  int _targetsSpawned = 0;
  int _targetsHit = 0;
  int _projectilesSpawned = 0;

  double _spawnTimer = 0;
  double _projectileTimer = 0;
  double _gameTimer = 0;
  bool _gameOver = false;
  bool _started = false;
  bool _bombActivated = false;

  late RectangleComponent _playerCar;
  final List<RectangleComponent> _buildings = [];

  final Random _rng = Random();

  // Timing constants.
  static const double _gameDuration = 75.0; // seconds
  static const double _scrollSpeed = 80.0; // pixels per second
  static const double _targetSpawnInterval = 5.5;
  static const double _projectileSpawnInterval = 18.0;
  static const int _maxProjectiles = 4;

  // Player car constraints.
  static const double _carWidth = 60.0;
  static const double _carHeight = 30.0;
  static const double _carX = 50.0;

  DriveByGame({
    required this.config,
    required this.onComplete,
  });

  @override
  Color backgroundColor() => GameTheme.backgroundColor;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_started && size.x > 0 && size.y > 0) {
      _initGame();
    }
  }

  void _initGame() {
    _health = config.playerHealth;

    // Street / road surface — lower half.
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.55),
        size: Vector2(size.x, size.y * 0.45),
        paint: Paint()..color = const Color(0xFF1A1815),
        priority: -2,
      ),
    );

    // Sidewalk divider line.
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.54),
        size: Vector2(size.x, 3),
        paint: Paint()..color = GameTheme.smoke,
        priority: -1,
      ),
    );

    // Initial buildings — noir rectangles in upper portion.
    _spawnBuildings();

    // Title text.
    add(
      TextComponent(
        text: 'DRIVE-BY!',
        position: Vector2(size.x / 2, 12),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF8B1A1A),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        priority: 10,
      ),
    );

    // Player car.
    _playerCar = RectangleComponent(
      position: Vector2(_carX, size.y * 0.72),
      size: Vector2(_carWidth, _carHeight),
      anchor: Anchor.center,
      paint: Paint()..color = GameTheme.goldAccent,
      priority: 5,
    );
    add(_playerCar);

    // Health dots below the car.
    _buildHealthDots();

    // Bomb prompt if available.
    if (config.hasBombOption) {
      _addBombPrompt();
    }

    _started = true;
  }

  final List<CircleComponent> _healthDots = [];

  void _buildHealthDots() {
    for (var i = 0; i < _health; i++) {
      final dot = CircleComponent(
        radius: 5,
        position: Vector2(
          _carX - 15 + i * 14.0,
          size.y * 0.72 + _carHeight / 2 + 10,
        ),
        paint: Paint()..color = GameTheme.goldAccent,
        priority: 10,
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

  late RectangleComponent _bombButton;
  bool _bombPromptVisible = false;

  void _addBombPrompt() {
    _bombButton = RectangleComponent(
      position: Vector2(size.x / 2, size.y - 40),
      size: Vector2(160, 36),
      anchor: Anchor.center,
      paint: Paint()..color = GameTheme.bloodAccent,
      priority: 15,
    );
    add(_bombButton);

    add(
      TextComponent(
        text: 'DETONATE BOMB',
        position: Vector2(size.x / 2, size.y - 40),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFE8D5A3),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        priority: 16,
      ),
    );

    _bombPromptVisible = true;
  }

  void _spawnBuildings() {
    // Create a row of building rectangles across the top.
    final buildingCount = (size.x / 80).ceil() + 2;
    for (var i = 0; i < buildingCount; i++) {
      final buildingHeight = 100 + _rng.nextDouble() * 120;
      final building = RectangleComponent(
        position: Vector2(i * 80.0, size.y * 0.55 - buildingHeight),
        size: Vector2(76, buildingHeight),
        paint: Paint()..color = const Color(0xFF151210),
        priority: -1,
      );
      _buildings.add(building);
      add(building);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_started || _gameOver) return;

    _gameTimer += dt;

    // Scroll buildings left.
    for (final building in _buildings) {
      building.position.x -= _scrollSpeed * dt;
    }

    // Target spawning.
    _spawnTimer += dt;
    if (_spawnTimer >= _targetSpawnInterval &&
        _targetsSpawned < config.totalTargets) {
      _spawnTimer = 0;
      _spawnTarget();
    }

    // Projectile spawning (return fire).
    _projectileTimer += dt;
    if (_projectileTimer >= _projectileSpawnInterval &&
        _projectilesSpawned < _maxProjectiles) {
      _projectileTimer = 0;
      _spawnProjectile();
    }

    // Check projectile collisions with player.
    _checkProjectileCollisions();

    // Game end: timer expired and all targets spawned.
    if (_gameTimer >= _gameDuration && !_gameOver) {
      _finishGame(playerDead: false);
    }

    // Player dead check.
    if (_health <= 0 && !_gameOver) {
      _finishGame(playerDead: true);
    }
  }

  void _spawnTarget() {
    _targetsSpawned++;

    // Random position in the building area (upper portion of screen).
    final x = size.x * 0.4 + _rng.nextDouble() * (size.x * 0.55);
    final y = 50 + _rng.nextDouble() * (size.y * 0.35);

    final target = DriveByTarget(
      position: Vector2(x, y),
      scrollSpeed: _scrollSpeed,
      onHit: _onTargetHit,
    );
    add(target);
  }

  void _onTargetHit() {
    _targetsHit++;
  }

  void _spawnProjectile() {
    _projectilesSpawned++;

    final y = size.y * 0.6 + _rng.nextDouble() * (size.y * 0.25);

    final projectile = DriveByProjectile(
      position: Vector2(size.x + 20, y),
      speed: 200 + _rng.nextDouble() * 100,
    );
    add(projectile);
  }

  void _checkProjectileCollisions() {
    final carRect = Rect.fromCenter(
      center: Offset(_playerCar.position.x, _playerCar.position.y),
      width: _carWidth,
      height: _carHeight,
    );

    final projectiles =
        children.whereType<DriveByProjectile>().toList();
    for (final projectile in projectiles) {
      if (projectile.isConsumed) continue;

      final projectileRect = Rect.fromCenter(
        center:
            Offset(projectile.position.x, projectile.position.y),
        width: DriveByProjectile.bulletSize,
        height: DriveByProjectile.bulletSize,
      );

      if (carRect.overlaps(projectileRect)) {
        projectile.consume();
        _takeDamage();
      }
    }
  }

  void _takeDamage() {
    if (_health <= 0) return;
    _health--;
    _updateHealthDots();

    // Flash car red.
    _playerCar.paint.color = GameTheme.bloodAccent;
    Future.delayed(const Duration(milliseconds: 200), () {
      _playerCar.paint.color = GameTheme.goldAccent;
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_gameOver) return;

    // Check bomb button tap.
    if (_bombPromptVisible && config.hasBombOption && !_bombActivated) {
      final tapPos = event.localPosition;
      final bombRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 40),
        width: 160,
        height: 36,
      );
      if (bombRect.contains(Offset(tapPos.x, tapPos.y))) {
        _activateBomb();
        return;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_gameOver) return;

    // Move car vertically.
    final newY = _playerCar.position.y + event.localDelta.y;
    final minY = size.y * 0.58;
    final maxY = size.y * 0.92;
    _playerCar.position.y = newY.clamp(minY, maxY);

    // Update health dots position to follow car.
    for (var i = 0; i < _healthDots.length; i++) {
      _healthDots[i].position.y = _playerCar.position.y + _carHeight / 2 + 10;
    }
  }

  void _activateBomb() {
    _bombActivated = true;

    // Show explosion effect — large red flash.
    add(
      RectangleComponent(
        position: Vector2(size.x * 0.5, size.y * 0.3),
        size: Vector2(size.x * 0.6, size.y * 0.4),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFFF4400),
        priority: 20,
      ),
    );

    add(
      TextComponent(
        text: 'BOOM!',
        position: Vector2(size.x / 2, size.y * 0.3),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFE8D5A3),
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
        priority: 21,
      ),
    );

    // Auto cleanWin after short delay.
    Future.delayed(const Duration(seconds: 2), () {
      if (!_gameOver) {
        _gameOver = true;
        onComplete(DriveByResult.bombResult());
      }
    });
  }

  void _finishGame({required bool playerDead}) {
    _gameOver = true;
    final result = DriveByResult.fromOutcome(
      targetsHit: _targetsHit,
      totalTargets: config.totalTargets,
      damageTaken: config.playerHealth - _health,
      playerDead: playerDead,
    );
    onComplete(result);
  }
}
