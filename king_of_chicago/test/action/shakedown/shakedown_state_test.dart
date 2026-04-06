import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/shakedown/shakedown_state.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';

void main() {
  group('ShakedownApproach', () {
    test('each approach maps to the correct veil type', () {
      expect(ShakedownApproach.push.veil, VeilType.dread);
      expect(ShakedownApproach.leverage.veil, VeilType.guile);
      expect(ShakedownApproach.protect.veil, VeilType.respect);
      expect(ShakedownApproach.bribe.veil, VeilType.empire);
      expect(ShakedownApproach.callFavor.veil, VeilType.kinship);
    });

    test('each approach has label and description', () {
      for (final approach in ShakedownApproach.values) {
        expect(approach.label, isNotEmpty);
        expect(approach.description, isNotEmpty);
      }
    });
  });

  group('ShakedownState', () {
    test('initial state has full resistance and 3 turns', () {
      final state = ShakedownState.initial(targetResistance: 100);

      expect(state.resistance, 100);
      expect(state.turnsRemaining, 3);
      expect(state.usedApproaches, isEmpty);
      expect(state.isComplete, false);
      expect(state.isSuccess, false);
    });

    test('initial state preserves custom resistance', () {
      final state = ShakedownState.initial(targetResistance: 60);

      expect(state.resistance, 60);
      expect(state.turnsRemaining, 3);
    });

    test('applyPressure reduces resistance based on veil value', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 50});

      final next = state.applyPressure(ShakedownApproach.push, veils);

      // Base 20 + (50 / 100) * 20 = 30
      expect(next.resistance, 70);
      expect(next.turnsRemaining, 2);
      expect(next.usedApproaches, contains(ShakedownApproach.push));
    });

    test('applyPressure with high veil does more damage', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 100});

      final next = state.applyPressure(ShakedownApproach.push, veils);

      // Base 20 + (100 / 100) * 20 = 40
      expect(next.resistance, 60);
      expect(next.turnsRemaining, 2);
    });

    test('applyPressure with zero veil does base damage only', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 0});

      final next = state.applyPressure(ShakedownApproach.push, veils);

      // Base 20 + (0 / 100) * 20 = 20
      expect(next.resistance, 80);
      expect(next.turnsRemaining, 2);
    });

    test('repeated approach has 0.5 multiplier', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 50});

      final after1 = state.applyPressure(ShakedownApproach.push, veils);
      final after2 = after1.applyPressure(ShakedownApproach.push, veils);

      // First: 30 damage, resistance = 70
      // Second: 30 * 0.5 = 15 damage, resistance = 55
      expect(after1.resistance, 70);
      expect(after2.resistance, 55);
      expect(after2.turnsRemaining, 1);
    });

    test('game ends after 3 turns', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 0});

      final after1 = state.applyPressure(ShakedownApproach.push, veils);
      final after2 =
          after1.applyPressure(ShakedownApproach.leverage, veils);
      final after3 =
          after2.applyPressure(ShakedownApproach.protect, veils);

      expect(after3.turnsRemaining, 0);
      expect(after3.isComplete, true);
      // 3 x 20 = 60 damage, resistance = 40, so not a success
      expect(after3.isSuccess, false);
    });

    test('success when resistance drops to 0', () {
      final state = ShakedownState.initial(targetResistance: 50);
      final veils = VeilState.fromMap(const {VeilType.dread: 100});

      final after1 = state.applyPressure(ShakedownApproach.push, veils);
      // 40 damage, resistance = 10
      final after2 =
          after1.applyPressure(ShakedownApproach.leverage, veils);
      // guile is 0, so base 20 damage, resistance = -10 clamped to 0

      expect(after2.resistance, 0);
      expect(after2.isComplete, true);
      expect(after2.isSuccess, true);
    });

    test('resistance does not go below 0', () {
      final state = ShakedownState.initial(targetResistance: 10);
      final veils = VeilState.fromMap(const {VeilType.dread: 100});

      final next = state.applyPressure(ShakedownApproach.push, veils);

      // 40 damage on 10 resistance => clamped to 0
      expect(next.resistance, 0);
    });

    test('immutability: original state unchanged after applyPressure', () {
      final state = ShakedownState.initial(targetResistance: 100);
      final veils = VeilState.fromMap(const {VeilType.dread: 50});

      state.applyPressure(ShakedownApproach.push, veils);

      expect(state.resistance, 100);
      expect(state.turnsRemaining, 3);
      expect(state.usedApproaches, isEmpty);
    });
  });
}
