import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';

void main() {
  group('VeilState', () {
    test('initial state has all veils at 0', () {
      final state = VeilState.initial();

      for (final veil in VeilType.values) {
        expect(state.getValue(veil), equals(0));
      }
    });

    test('applyDeltas returns new state without mutation', () {
      final original = VeilState.initial();
      final updated = original.applyDeltas({VeilType.dread: 10});

      expect(updated.getValue(VeilType.dread), equals(10));
      expect(original.getValue(VeilType.dread), equals(0));
      expect(identical(original, updated), isFalse);
    });

    test('veils are clamped between 0 and 100', () {
      final state = VeilState.initial();

      final overMax = state.applyDeltas({VeilType.respect: 150});
      expect(overMax.getValue(VeilType.respect), equals(100));

      final underMin = state.applyDeltas({VeilType.sway: -50});
      expect(underMin.getValue(VeilType.sway), equals(0));
    });

    test('getDominantVeils returns top N sorted descending', () {
      final state = VeilState.initial().applyDeltas({
        VeilType.dread: 50,
        VeilType.respect: 30,
        VeilType.sway: 70,
        VeilType.empire: 10,
        VeilType.guile: 90,
        VeilType.legend: 40,
        VeilType.kinship: 60,
      });

      final top3 = state.getDominantVeils(3);
      expect(top3, equals([VeilType.guile, VeilType.sway, VeilType.kinship]));
    });

    test('meetsThreshold checks correctly', () {
      final state = VeilState.initial().applyDeltas({
        VeilType.dread: 50,
      });

      expect(state.meetsThreshold(VeilType.dread, 50), isTrue);
      expect(state.meetsThreshold(VeilType.dread, 49), isTrue);
      expect(state.meetsThreshold(VeilType.dread, 51), isFalse);
    });

    test('fromMap clamps values', () {
      final state = VeilState.fromMap({
        VeilType.dread: 200,
        VeilType.respect: -10,
      });

      expect(state.getValue(VeilType.dread), equals(100));
      expect(state.getValue(VeilType.respect), equals(0));
      expect(state.getValue(VeilType.sway), equals(0));
    });

    test('toMap returns unmodifiable map', () {
      final state = VeilState.initial().applyDeltas({VeilType.dread: 25});
      final map = state.toMap();

      expect(map[VeilType.dread], equals(25));
      expect(() => map[VeilType.dread] = 99, throwsUnsupportedError);
    });

    test('equality works via equatable', () {
      final a = VeilState.initial().applyDeltas({VeilType.dread: 10});
      final b = VeilState.initial().applyDeltas({VeilType.dread: 10});
      final c = VeilState.initial().applyDeltas({VeilType.dread: 20});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
