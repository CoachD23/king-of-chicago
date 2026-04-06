import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/empire/territory/territory.dart';
import 'package:king_of_chicago/empire/territory/territory_state.dart';

void main() {
  group('Territory', () {
    test('mvpTerritories contains 3 territories', () {
      expect(Territory.mvpTerritories.length, equals(3));
    });

    test('mvpTerritories have correct ids', () {
      final ids = Territory.mvpTerritories.map((t) => t.id).toList();
      expect(ids, containsAll(['south_side', 'little_italy', 'the_loop']));
    });

    test('effectiveIncome returns baseIncome when capo assigned', () {
      const territory = Territory(
        id: 'test',
        name: 'Test',
        character: 'Test character',
        primaryRacket: 'Test racket',
        baseIncome: 500,
        assignedCapo: 'capo_1',
      );
      expect(territory.effectiveIncome, equals(500));
    });

    test('effectiveIncome returns 0 when no capo assigned', () {
      const territory = Territory(
        id: 'test',
        name: 'Test',
        character: 'Test character',
        primaryRacket: 'Test racket',
        baseIncome: 500,
      );
      expect(territory.effectiveIncome, equals(0));
    });

    test('copyWith creates new territory without mutation', () {
      const original = Territory(
        id: 'test',
        name: 'Test',
        character: 'Test character',
        primaryRacket: 'Test racket',
        baseIncome: 500,
        heat: 10,
      );

      final updated = original.copyWith(heat: 50);

      expect(updated.heat, equals(50));
      expect(original.heat, equals(10));
      expect(identical(original, updated), isFalse);
    });

    test('equality works via equatable', () {
      const a = Territory(
        id: 'test',
        name: 'Test',
        character: 'c',
        primaryRacket: 'r',
        baseIncome: 100,
      );
      const b = Territory(
        id: 'test',
        name: 'Test',
        character: 'c',
        primaryRacket: 'r',
        baseIncome: 100,
      );
      const c = Territory(
        id: 'other',
        name: 'Other',
        character: 'c',
        primaryRacket: 'r',
        baseIncome: 200,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('TerritoryState', () {
    test('initial MVP state has 3 territories', () {
      final state = TerritoryState.mvpInitial();

      expect(state.territories.length, equals(3));
    });

    test('getTerritory returns correct territory by id', () {
      final state = TerritoryState.mvpInitial();

      final territory = state.getTerritory('south_side');
      expect(territory.name, equals('South Side'));
      expect(territory.baseIncome, equals(500));
    });

    test('getTerritory throws for unknown id', () {
      final state = TerritoryState.mvpInitial();

      expect(
        () => state.getTerritory('nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('can assign a capo to a territory (original unchanged)', () {
      final original = TerritoryState.mvpInitial();
      final updated = original.assignCapo('south_side', 'capo_vince');

      final updatedTerritory = updated.getTerritory('south_side');
      expect(updatedTerritory.assignedCapo, equals('capo_vince'));

      final originalTerritory = original.getTerritory('south_side');
      expect(originalTerritory.assignedCapo, isNull);
      expect(identical(original, updated), isFalse);
    });

    test('heat increases and is clamped at 100', () {
      final state = TerritoryState.mvpInitial();

      final heated = state.addHeat('south_side', 30);
      expect(heated.getTerritory('south_side').heat, equals(30));

      final overheated = heated.addHeat('south_side', 80);
      expect(overheated.getTerritory('south_side').heat, equals(100));
    });

    test('heat decreases and is clamped at 0', () {
      final state = TerritoryState.mvpInitial();

      final cooled = state.addHeat('south_side', -10);
      expect(cooled.getTerritory('south_side').heat, equals(0));
    });

    test('income is calculated from controlled territories', () {
      final state = TerritoryState.mvpInitial();

      // No capos assigned, total income should be 0
      expect(state.totalIncome(), equals(0));

      // Assign capo to south_side (500) and the_loop (800)
      final withCapos = state
          .assignCapo('south_side', 'capo_a')
          .assignCapo('the_loop', 'capo_b');

      expect(withCapos.totalIncome(), equals(1300));
    });

    test('assigning capo to all territories sums all incomes', () {
      final state = TerritoryState.mvpInitial()
          .assignCapo('south_side', 'capo_a')
          .assignCapo('little_italy', 'capo_b')
          .assignCapo('the_loop', 'capo_c');

      // 500 + 200 + 800 = 1500
      expect(state.totalIncome(), equals(1500));
    });

    test('equality works via equatable', () {
      final a = TerritoryState.mvpInitial();
      final b = TerritoryState.mvpInitial();
      final c = a.assignCapo('south_side', 'capo_x');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
