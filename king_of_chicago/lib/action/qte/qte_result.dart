/// Possible outcomes for a Quick Time Event.
enum QteOutcome { cleanWin, messyWin, failure }

/// Immutable result of a QTE action sequence.
///
/// Contains the [outcome], a map of Veil stat deltas ([veilDeltas]),
/// and the change in heat ([heatDelta]).
class QteResult {
  final QteOutcome outcome;
  final Map<String, int> veilDeltas;
  final int heatDelta;

  const QteResult({
    required this.outcome,
    required this.veilDeltas,
    required this.heatDelta,
  });

  /// 80%+ hit ratio: dread +3, legend +1, heat +1.
  factory QteResult.cleanWin() => const QteResult(
        outcome: QteOutcome.cleanWin,
        veilDeltas: {'dread': 3, 'legend': 1},
        heatDelta: 1,
      );

  /// 40-79% hit ratio: dread +1, legend +2, heat +5.
  factory QteResult.messyWin() => const QteResult(
        outcome: QteOutcome.messyWin,
        veilDeltas: {'dread': 1, 'legend': 2},
        heatDelta: 5,
      );

  /// Below 40% hit ratio: respect -2, heat +10.
  factory QteResult.failure() => const QteResult(
        outcome: QteOutcome.failure,
        veilDeltas: {'respect': -2},
        heatDelta: 10,
      );

  /// Determine outcome from hit ratio and return the appropriate result.
  ///
  /// [hits] is the number of targets successfully tapped.
  /// [total] is the total number of targets spawned.
  factory QteResult.fromHitRatio({
    required int hits,
    required int total,
  }) {
    if (total <= 0) return QteResult.failure();

    final ratio = hits / total;
    if (ratio >= 0.8) return QteResult.cleanWin();
    if (ratio >= 0.4) return QteResult.messyWin();
    return QteResult.failure();
  }
}
