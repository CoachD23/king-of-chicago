import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/qte/qte_skip_checker.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';

void main() {
  group('QteSkipChecker', () {
    test('returns null when no Veil at 80+', () {
      final state = VeilState.initial().applyDeltas({VeilType.dread: 79});
      expect(QteSkipChecker.canSkip(state, 'ambush'), isNull);
    });

    test('returns Dread for ambush when Dread >= 80', () {
      final state = VeilState.initial().applyDeltas({VeilType.dread: 80});
      final result = QteSkipChecker.canSkip(state, 'ambush');
      expect(result, isNotNull);
      expect(result!.veil, VeilType.dread);
    });

    test('returns Legend for ambush when Legend >= 80', () {
      final state = VeilState.initial().applyDeltas({VeilType.legend: 85});
      final result = QteSkipChecker.canSkip(state, 'ambush');
      expect(result!.veil, VeilType.legend);
    });

    test('returns highest qualifying Veil when multiple at 80+', () {
      final state = VeilState.initial().applyDeltas({
        VeilType.dread: 85,
        VeilType.legend: 90,
      });
      final result = QteSkipChecker.canSkip(state, 'ambush');
      expect(result!.veil, VeilType.legend); // 90 > 85
    });

    test('returns null for shakedown (can never skip)', () {
      final state = VeilState.initial().applyDeltas({VeilType.dread: 100});
      expect(QteSkipChecker.canSkip(state, 'shakedown'), isNull);
    });

    test('returns Respect for shootout when Respect >= 80', () {
      final state = VeilState.initial().applyDeltas({VeilType.respect: 80});
      final result = QteSkipChecker.canSkip(state, 'shootout');
      expect(result!.veil, VeilType.respect);
    });

    test('returns Guile for driveby when Guile >= 80', () {
      final state = VeilState.initial().applyDeltas({VeilType.guile: 80});
      final result = QteSkipChecker.canSkip(state, 'driveby');
      expect(result!.veil, VeilType.guile);
    });
  });
}
