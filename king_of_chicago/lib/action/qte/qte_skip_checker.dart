import '../../core/veils/veil_state.dart';
import '../../core/veils/veil_type.dart';

class SkipResult {
  final VeilType veil;
  final String message;
  const SkipResult(this.veil, this.message);
}

class QteSkipChecker {
  const QteSkipChecker._();

  static SkipResult? canSkip(VeilState veilState, String actionType) {
    final checks = _actionSkipMap[actionType];
    if (checks == null) return null;

    // Return the highest-value qualifying Veil
    SkipResult? best;
    int bestValue = 0;
    for (final entry in checks.entries) {
      final value = veilState.getValue(entry.key);
      if (value >= 80 && value > bestValue) {
        bestValue = value;
        best = SkipResult(entry.key, entry.value);
      }
    }
    return best;
  }

  static const _actionSkipMap = <String, Map<VeilType, String>>{
    'ambush': {
      VeilType.dread: 'They freeze.',
      VeilType.legend: 'They know who you are.',
    },
    'shootout': {
      VeilType.dread: 'They freeze.',
      VeilType.respect: 'Your word alone is enough.',
    },
    'driveby': {
      VeilType.guile: 'Three moves ahead.',
      VeilType.empire: 'Money talks. They listen.',
    },
    // shakedown: intentionally absent — can never be skipped
  };
}
