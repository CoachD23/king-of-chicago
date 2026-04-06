import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/characters/npc.dart';
import 'package:king_of_chicago/core/characters/npc_state.dart';

void main() {
  group('NpcState', () {
    group('initial', () {
      test('creates all MVP NPCs at relationship 0', () {
        final state = NpcState.initial();

        for (final npc in Npc.mvpNpcs) {
          expect(state.getRelationship(npc.id), equals(0));
        }
      });

      test('contains exactly the 4 MVP NPC ids', () {
        final state = NpcState.initial();
        final map = state.toMap();

        expect(map.length, equals(4));
        expect(map.containsKey('mickey'), isTrue);
        expect(map.containsKey('enzo'), isTrue);
        expect(map.containsKey('tommy'), isTrue);
        expect(map.containsKey('rosa'), isTrue);
      });
    });

    group('fromMap', () {
      test('clamps values to -100 to 100 range', () {
        final state = NpcState.fromMap(const {
          'mickey': 150,
          'enzo': -200,
          'tommy': 50,
          'rosa': 100,
        });

        expect(state.getRelationship('mickey'), equals(100));
        expect(state.getRelationship('enzo'), equals(-100));
        expect(state.getRelationship('tommy'), equals(50));
        expect(state.getRelationship('rosa'), equals(100));
      });
    });

    group('applyDelta', () {
      test('returns new state with updated relationship', () {
        final original = NpcState.initial();
        final updated = original.applyDelta('mickey', 25);

        // Original is unchanged (immutability)
        expect(original.getRelationship('mickey'), equals(0));

        // Updated has new value
        expect(updated.getRelationship('mickey'), equals(25));
      });

      test('does not affect other NPC relationships', () {
        final original = NpcState.initial();
        final updated = original.applyDelta('mickey', 25);

        expect(updated.getRelationship('enzo'), equals(0));
        expect(updated.getRelationship('tommy'), equals(0));
        expect(updated.getRelationship('rosa'), equals(0));
      });

      test('clamps result to 100 when exceeding upper bound', () {
        final state = NpcState.fromMap(const {
          'mickey': 90,
          'enzo': 0,
          'tommy': 0,
          'rosa': 0,
        });
        final updated = state.applyDelta('mickey', 20);

        expect(updated.getRelationship('mickey'), equals(100));
      });

      test('clamps result to -100 when exceeding lower bound', () {
        final state = NpcState.fromMap(const {
          'mickey': -90,
          'enzo': 0,
          'tommy': 0,
          'rosa': 0,
        });
        final updated = state.applyDelta('mickey', -20);

        expect(updated.getRelationship('mickey'), equals(-100));
      });

      test('supports negative deltas', () {
        final state = NpcState.initial();
        final updated = state.applyDelta('rosa', -30);

        expect(updated.getRelationship('rosa'), equals(-30));
      });

      test('throws for unknown NPC id', () {
        final state = NpcState.initial();

        expect(
          () => state.applyDelta('unknown_npc', 10),
          throwsArgumentError,
        );
      });
    });

    group('getRelationship', () {
      test('throws for unknown NPC id', () {
        final state = NpcState.initial();

        expect(
          () => state.getRelationship('unknown_npc'),
          throwsArgumentError,
        );
      });
    });

    group('toMap', () {
      test('returns unmodifiable map', () {
        final state = NpcState.initial();
        final map = state.toMap();

        expect(
          () => map['mickey'] = 50,
          throwsUnsupportedError,
        );
      });
    });

    group('equality', () {
      test('two initial states are equal', () {
        final a = NpcState.initial();
        final b = NpcState.initial();

        expect(a, equals(b));
      });

      test('different states are not equal', () {
        final a = NpcState.initial();
        final b = a.applyDelta('mickey', 10);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
