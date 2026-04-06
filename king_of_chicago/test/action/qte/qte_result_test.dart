import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';

void main() {
  group('QteResult', () {
    test('cleanWin has correct outcome', () {
      const result = QteResult(
        outcome: QteOutcome.cleanWin,
        veilDeltas: {'dread': 3, 'legend': 1},
        heatDelta: 1,
      );

      expect(result.outcome, QteOutcome.cleanWin);
      expect(result.veilDeltas['dread'], 3);
      expect(result.veilDeltas['legend'], 1);
      expect(result.heatDelta, 1);
    });

    test('messyWin adds heat', () {
      const result = QteResult(
        outcome: QteOutcome.messyWin,
        veilDeltas: {'dread': 1, 'legend': 2},
        heatDelta: 5,
      );

      expect(result.outcome, QteOutcome.messyWin);
      expect(result.heatDelta, 5);
      expect(result.veilDeltas['dread'], 1);
      expect(result.veilDeltas['legend'], 2);
    });

    test('failure has negative consequences', () {
      const result = QteResult(
        outcome: QteOutcome.failure,
        veilDeltas: {'respect': -2},
        heatDelta: 10,
      );

      expect(result.outcome, QteOutcome.failure);
      expect(result.heatDelta, 10);
      expect(result.veilDeltas['respect'], -2);
    });

    test('factory cleanWin produces correct deltas', () {
      final result = QteResult.cleanWin();

      expect(result.outcome, QteOutcome.cleanWin);
      expect(result.veilDeltas['dread'], 3);
      expect(result.veilDeltas['legend'], 1);
      expect(result.heatDelta, 1);
    });

    test('factory messyWin produces correct deltas', () {
      final result = QteResult.messyWin();

      expect(result.outcome, QteOutcome.messyWin);
      expect(result.veilDeltas['dread'], 1);
      expect(result.veilDeltas['legend'], 2);
      expect(result.heatDelta, 5);
    });

    test('factory failure produces correct deltas', () {
      final result = QteResult.failure();

      expect(result.outcome, QteOutcome.failure);
      expect(result.veilDeltas['respect'], -2);
      expect(result.heatDelta, 10);
    });

    test('fromHitRatio returns cleanWin for 80%+ ratio', () {
      final result = QteResult.fromHitRatio(hits: 8, total: 10);

      expect(result.outcome, QteOutcome.cleanWin);
    });

    test('fromHitRatio returns messyWin for 40-79% ratio', () {
      final result = QteResult.fromHitRatio(hits: 5, total: 10);

      expect(result.outcome, QteOutcome.messyWin);
    });

    test('fromHitRatio returns failure for below 40% ratio', () {
      final result = QteResult.fromHitRatio(hits: 3, total: 10);

      expect(result.outcome, QteOutcome.failure);
    });

    test('fromHitRatio handles zero total gracefully', () {
      final result = QteResult.fromHitRatio(hits: 0, total: 0);

      expect(result.outcome, QteOutcome.failure);
    });
  });
}
