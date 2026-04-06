import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_engine.dart';

void main() {
  group('VeilEngine', () {
    test('applyChoice applies deltas from string map', () {
      final state = VeilState.initial();
      final result = VeilEngine.applyChoice(state, {
        'dread': 20,
        'respect': 15,
      });

      expect(result.getValue(VeilType.dread), equals(20));
      expect(result.getValue(VeilType.respect), equals(15));
    });

    test('applyChoice ignores unknown veil names', () {
      final state = VeilState.initial();
      final result = VeilEngine.applyChoice(state, {
        'dread': 10,
        'nonsense': 50,
        'also_fake': 99,
      });

      expect(result.getValue(VeilType.dread), equals(10));
      // All other veils should remain 0
      expect(result.getValue(VeilType.respect), equals(0));
      expect(result.getValue(VeilType.sway), equals(0));
    });

    test('isChoiceAvailable returns true for null requirements', () {
      final state = VeilState.initial();
      expect(VeilEngine.isChoiceAvailable(state, null), isTrue);
    });

    test('isChoiceAvailable returns true for empty requirements', () {
      final state = VeilState.initial();
      expect(VeilEngine.isChoiceAvailable(state, {}), isTrue);
    });

    test('isChoiceAvailable checks threshold requirements', () {
      final state = VeilState.initial().applyDeltas({
        VeilType.dread: 50,
        VeilType.respect: 30,
      });

      // Met
      expect(
        VeilEngine.isChoiceAvailable(state, {'dread': 40, 'respect': 20}),
        isTrue,
      );

      // Not met — respect too low
      expect(
        VeilEngine.isChoiceAvailable(state, {'dread': 40, 'respect': 50}),
        isFalse,
      );
    });

    test('isChoiceAvailable ignores unknown veil names in requirements', () {
      final state = VeilState.initial().applyDeltas({VeilType.dread: 50});

      // Unknown key should not block
      expect(
        VeilEngine.isChoiceAvailable(state, {'dread': 40, 'fake': 99}),
        isTrue,
      );
    });
  });
}
