import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/empire/rackets/racket.dart';
import 'package:king_of_chicago/empire/rackets/racket_data.dart';
import 'package:king_of_chicago/empire/rackets/racket_state.dart';

void main() {
  group('RacketTier', () {
    test('holds name, income multiplier, cost, and veil effect', () {
      const tier = RacketTier(
        name: 'Test Tier',
        incomeMultiplier: 2,
        upgradeCost: 500,
        veilEffect: {'empire': 2},
      );

      expect(tier.name, equals('Test Tier'));
      expect(tier.incomeMultiplier, equals(2));
      expect(tier.upgradeCost, equals(500));
      expect(tier.veilEffect, equals({'empire': 2}));
    });

    test('equality works via equatable', () {
      const a = RacketTier(
        name: 'Tier',
        incomeMultiplier: 1,
        upgradeCost: 0,
        veilEffect: {},
      );
      const b = RacketTier(
        name: 'Tier',
        incomeMultiplier: 1,
        upgradeCost: 0,
        veilEffect: {},
      );
      const c = RacketTier(
        name: 'Other',
        incomeMultiplier: 2,
        upgradeCost: 100,
        veilEffect: {'empire': 1},
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Racket', () {
    test('current returns the tier at currentTier index', () {
      const racket = Racket(
        territoryId: 'south_side',
        type: 'bootlegging',
        currentTier: 0,
        tiers: [
          RacketTier(
            name: 'Tier 1',
            incomeMultiplier: 1,
            upgradeCost: 0,
            veilEffect: {},
          ),
          RacketTier(
            name: 'Tier 2',
            incomeMultiplier: 2,
            upgradeCost: 500,
            veilEffect: {'empire': 2},
          ),
        ],
      );

      expect(racket.current.name, equals('Tier 1'));
      expect(racket.incomeMultiplier, equals(1));
    });

    test('canUpgrade is true when not at max tier', () {
      const racket = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 0,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
          RacketTier(
              name: 'T2',
              incomeMultiplier: 2,
              upgradeCost: 500,
              veilEffect: {}),
        ],
      );

      expect(racket.canUpgrade, isTrue);
    });

    test('canUpgrade is false when at max tier', () {
      const racket = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 1,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
          RacketTier(
              name: 'T2',
              incomeMultiplier: 2,
              upgradeCost: 500,
              veilEffect: {}),
        ],
      );

      expect(racket.canUpgrade, isFalse);
    });

    test('nextTier returns next tier when available', () {
      const racket = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 0,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
          RacketTier(
              name: 'T2',
              incomeMultiplier: 2,
              upgradeCost: 500,
              veilEffect: {}),
        ],
      );

      expect(racket.nextTier, isNotNull);
      expect(racket.nextTier!.name, equals('T2'));
    });

    test('nextTier returns null when at max tier', () {
      const racket = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 1,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
          RacketTier(
              name: 'T2',
              incomeMultiplier: 2,
              upgradeCost: 500,
              veilEffect: {}),
        ],
      );

      expect(racket.nextTier, isNull);
    });

    test('equality works via equatable', () {
      const a = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 0,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
        ],
      );
      const b = Racket(
        territoryId: 'test',
        type: 'test',
        currentTier: 0,
        tiers: [
          RacketTier(
              name: 'T1',
              incomeMultiplier: 1,
              upgradeCost: 0,
              veilEffect: {}),
        ],
      );

      expect(a, equals(b));
    });
  });

  group('RacketData', () {
    test('defines rackets for all 8 territories', () {
      expect(RacketData.allRackets.length, equals(8));
    });

    test('each racket has exactly 3 tiers', () {
      for (final racket in RacketData.allRackets) {
        expect(racket.tiers.length, equals(3),
            reason: '${racket.territoryId} should have 3 tiers');
      }
    });

    test('tier 0 always has upgradeCost 0 (starting tier)', () {
      for (final racket in RacketData.allRackets) {
        expect(racket.tiers[0].upgradeCost, equals(0),
            reason: '${racket.territoryId} tier 0 should be free');
      }
    });

    test('income multipliers increase with tier', () {
      for (final racket in RacketData.allRackets) {
        expect(racket.tiers[0].incomeMultiplier, equals(1));
        expect(racket.tiers[1].incomeMultiplier, equals(2));
        expect(racket.tiers[2].incomeMultiplier, equals(3));
      }
    });

    test('south_side racket is bootlegging', () {
      final southSide = RacketData.allRackets
          .firstWhere((r) => r.territoryId == 'south_side');

      expect(southSide.type, equals('bootlegging'));
      expect(southSide.tiers[0].name, equals('Backroom Still'));
      expect(southSide.tiers[1].name, equals('Distillery'));
      expect(southSide.tiers[2].name, equals('Distribution Network'));
    });

    test('the_loop tier 3 costs 2000', () {
      final loop = RacketData.allRackets
          .firstWhere((r) => r.territoryId == 'the_loop');

      expect(loop.tiers[2].upgradeCost, equals(2000));
    });
  });

  group('RacketState', () {
    test('initial state has all rackets at tier 0', () {
      final state = RacketState.initial();

      expect(state.rackets.length, equals(8));
      for (final racket in state.rackets) {
        expect(racket.currentTier, equals(0),
            reason: '${racket.territoryId} should start at tier 0');
      }
    });

    test('upgradeRacket increments tier (immutable)', () {
      final original = RacketState.initial();
      final updated = original.upgradeRacket('south_side');

      final updatedRacket = updated.getRacket('south_side');
      expect(updatedRacket.currentTier, equals(1));

      final originalRacket = original.getRacket('south_side');
      expect(originalRacket.currentTier, equals(0));
      expect(identical(original, updated), isFalse);
    });

    test('upgradeRacket can go from tier 1 to tier 2', () {
      final state = RacketState.initial().upgradeRacket('south_side');
      final upgraded = state.upgradeRacket('south_side');

      expect(upgraded.getRacket('south_side').currentTier, equals(2));
    });

    test('cannot upgrade past tier 2', () {
      final state = RacketState.initial()
          .upgradeRacket('south_side')
          .upgradeRacket('south_side');

      expect(
        () => state.upgradeRacket('south_side'),
        throwsA(isA<StateError>()),
      );
    });

    test('income multiplier increases with tier', () {
      final state0 = RacketState.initial();
      expect(state0.getIncomeMultiplier('south_side'), equals(1));

      final state1 = state0.upgradeRacket('south_side');
      expect(state1.getIncomeMultiplier('south_side'), equals(2));

      final state2 = state1.upgradeRacket('south_side');
      expect(state2.getIncomeMultiplier('south_side'), equals(3));
    });

    test('upgrade cost is correct per tier', () {
      final state = RacketState.initial();
      final southSide = state.getRacket('south_side');

      // Tier 0 -> 1: cost from tier 1
      expect(southSide.nextTier!.upgradeCost, equals(500));

      final upgraded = state.upgradeRacket('south_side');
      final southSideT1 = upgraded.getRacket('south_side');

      // Tier 1 -> 2: cost from tier 2
      expect(southSideT1.nextTier!.upgradeCost, equals(1500));
    });

    test('getRacket throws for unknown territory id', () {
      final state = RacketState.initial();

      expect(
        () => state.getRacket('nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('upgradeRacket throws for unknown territory id', () {
      final state = RacketState.initial();

      expect(
        () => state.upgradeRacket('nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('equality works via equatable', () {
      final a = RacketState.initial();
      final b = RacketState.initial();
      final c = a.upgradeRacket('south_side');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
