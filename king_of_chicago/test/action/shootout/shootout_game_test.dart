import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';
import 'package:king_of_chicago/action/shootout/shootout_game.dart';

void main() {
  group('ShootoutConfig', () {
    test('default enemy count is 8 with low veil levels', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 0,
        respectLevel: 0,
      );

      expect(config.totalEnemies, 8);
    });

    test('enemy aim time is base 2.0s with low dread', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 0,
        respectLevel: 0,
      );

      expect(config.enemyAimDuration, 2.0);
    });

    test('high dread (>= 50) adds 0.5s panic delay to aim time', () {
      final config = ShootoutConfig(
        dreadLevel: 50,
        kinshipLevel: 0,
        respectLevel: 0,
      );

      expect(config.enemyAimDuration, 2.5);
    });

    test('dread at 49 does not trigger panic bonus', () {
      final config = ShootoutConfig(
        dreadLevel: 49,
        kinshipLevel: 0,
        respectLevel: 0,
      );

      expect(config.enemyAimDuration, 2.0);
    });

    test('high kinship (>= 40) provides 1-2 ally count', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 40,
        respectLevel: 0,
      );

      expect(config.allyCount, greaterThanOrEqualTo(1));
      expect(config.allyCount, lessThanOrEqualTo(2));
    });

    test('low kinship (< 40) provides no allies', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 39,
        respectLevel: 0,
      );

      expect(config.allyCount, 0);
    });

    test('high respect (>= 60) enables surrender mechanic', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 0,
        respectLevel: 60,
      );

      expect(config.firstEnemySurrenders, isTrue);
    });

    test('low respect (< 60) disables surrender mechanic', () {
      final config = ShootoutConfig(
        dreadLevel: 0,
        kinshipLevel: 0,
        respectLevel: 59,
      );

      expect(config.firstEnemySurrenders, isFalse);
    });
  });

  group('ShootoutResult', () {
    test('all enemies down with 0 damage returns cleanWin', () {
      final result = ShootoutResult.fromOutcome(
        enemiesKilled: 8,
        totalEnemies: 8,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.cleanWin);
    });

    test('all enemies down with some damage returns messyWin', () {
      final result = ShootoutResult.fromOutcome(
        enemiesKilled: 8,
        totalEnemies: 8,
        damageTaken: 2,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.messyWin);
    });

    test('player dead returns failure', () {
      final result = ShootoutResult.fromOutcome(
        enemiesKilled: 3,
        totalEnemies: 8,
        damageTaken: 3,
        playerDead: true,
      );

      expect(result.outcome, QteOutcome.failure);
    });

    test('cleanWin has positive veil deltas', () {
      final result = ShootoutResult.fromOutcome(
        enemiesKilled: 8,
        totalEnemies: 8,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.veilDeltas['dread'], greaterThan(0));
    });

    test('failure has negative veil deltas', () {
      final result = ShootoutResult.fromOutcome(
        enemiesKilled: 2,
        totalEnemies: 8,
        damageTaken: 3,
        playerDead: true,
      );

      expect(result.veilDeltas['respect'], lessThan(0));
    });
  });
}
