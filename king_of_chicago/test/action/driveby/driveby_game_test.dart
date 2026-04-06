import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/driveby/driveby_game.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';

void main() {
  group('DriveByConfig', () {
    test('default config values', () {
      final config = DriveByConfig(
        dreadLevel: 0,
        guileLevel: 0,
        empirLevel: 0,
      );

      expect(config.totalTargets, 12);
      expect(config.playerHealth, 3);
      expect(config.hasBombOption, false);
      expect(config.hasImprovedGuns, false);
    });

    test('dread >= 50 gives extra health (armor bonus)', () {
      final config = DriveByConfig(
        dreadLevel: 50,
        guileLevel: 0,
        empirLevel: 0,
      );

      expect(config.playerHealth, 4);
    });

    test('dread below 50 gives default health', () {
      final config = DriveByConfig(
        dreadLevel: 49,
        guileLevel: 0,
        empirLevel: 0,
      );

      expect(config.playerHealth, 3);
    });

    test('guile >= 60 enables bomb option', () {
      final config = DriveByConfig(
        dreadLevel: 0,
        guileLevel: 60,
        empirLevel: 0,
      );

      expect(config.hasBombOption, true);
    });

    test('guile below 60 disables bomb option', () {
      final config = DriveByConfig(
        dreadLevel: 0,
        guileLevel: 59,
        empirLevel: 0,
      );

      expect(config.hasBombOption, false);
    });

    test('empir >= 40 enables improved guns', () {
      final config = DriveByConfig(
        dreadLevel: 0,
        guileLevel: 0,
        empirLevel: 40,
      );

      expect(config.hasImprovedGuns, true);
    });

    test('empir below 40 disables improved guns', () {
      final config = DriveByConfig(
        dreadLevel: 0,
        guileLevel: 0,
        empirLevel: 39,
      );

      expect(config.hasImprovedGuns, false);
    });

    test('all bonuses active simultaneously', () {
      final config = DriveByConfig(
        dreadLevel: 50,
        guileLevel: 60,
        empirLevel: 40,
      );

      expect(config.playerHealth, 4);
      expect(config.hasBombOption, true);
      expect(config.hasImprovedGuns, true);
    });
  });

  group('DriveByResult', () {
    test('80%+ targets hit and no damage returns cleanWin', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 10,
        totalTargets: 12,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.cleanWin);
      expect(result.veilDeltas['dread'], 2);
      expect(result.veilDeltas['legend'], 2);
      expect(result.heatDelta, 3);
    });

    test('exactly 80% hit ratio with no damage returns cleanWin', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 8,
        totalTargets: 10,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.cleanWin);
    });

    test('80%+ targets hit but with damage returns messyWin', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 10,
        totalTargets: 12,
        damageTaken: 1,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.messyWin);
    });

    test('50-79% targets hit returns messyWin', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 7,
        totalTargets: 12,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.messyWin);
      expect(result.veilDeltas['dread'], 1);
      expect(result.veilDeltas['legend'], 1);
      expect(result.heatDelta, 5);
    });

    test('exactly 50% hit ratio returns messyWin', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 6,
        totalTargets: 12,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.messyWin);
    });

    test('below 50% targets hit returns failure', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 5,
        totalTargets: 12,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.failure);
      expect(result.veilDeltas['respect'], -1);
      expect(result.heatDelta, 8);
    });

    test('player dead returns failure regardless of hits', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 12,
        totalTargets: 12,
        damageTaken: 3,
        playerDead: true,
      );

      expect(result.outcome, QteOutcome.failure);
    });

    test('zero total targets returns failure', () {
      final result = DriveByResult.fromOutcome(
        targetsHit: 0,
        totalTargets: 0,
        damageTaken: 0,
        playerDead: false,
      );

      expect(result.outcome, QteOutcome.failure);
    });

    test('bomb option returns cleanWin', () {
      final result = DriveByResult.bombResult();

      expect(result.outcome, QteOutcome.cleanWin);
    });
  });
}
