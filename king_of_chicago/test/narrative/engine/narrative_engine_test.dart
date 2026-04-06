import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/narrative/engine/narrative_engine.dart';
import 'package:king_of_chicago/narrative/engine/scene.dart';

void main() {
  late Scene testScene;

  setUp(() {
    testScene = const Scene(
      id: 'test_scene',
      location: 'south_side',
      characters: ['vince', 'enzo'],
      mood: 'somber',
      dialogue: [
        DialogueLine(speaker: 'narrator', line: 'Test.'),
      ],
      choices: [
        // No requirements — always available
        Choice(
          id: 'free_choice',
          line: 'Always available.',
          veils: {'kinship': 2},
          next: 'next_a',
        ),
        // Requires guile >= 10
        Choice(
          id: 'guile_choice',
          line: 'Need guile.',
          veils: {'guile': 1},
          requires: {'guile': 10},
          next: 'next_b',
        ),
        // Requires dread >= 20, hidden when locked
        Choice(
          id: 'hidden_choice',
          line: 'Secret option.',
          veils: {'dread': 3},
          requires: {'dread': 20},
          next: 'next_c',
          hidden: true,
        ),
      ],
    );
  });

  group('NarrativeEngine', () {
    test('getAvailableChoices filters by veil thresholds', () {
      final state = VeilState.initial(); // all zeros

      final available = NarrativeEngine.getAvailableChoices(testScene, state);

      expect(available, hasLength(1));
      expect(available[0].id, 'free_choice');
    });

    test('getAvailableChoices unlocks when threshold met', () {
      final state = VeilState.fromMap({
        VeilType.guile: 15,
        VeilType.dread: 25,
      });

      final available = NarrativeEngine.getAvailableChoices(testScene, state);

      expect(available, hasLength(3));
      expect(available.map((c) => c.id).toList(),
          ['free_choice', 'guile_choice', 'hidden_choice']);
    });

    test('getLockedChoices shows visible locked options (excludes hidden)', () {
      final state = VeilState.initial(); // all zeros

      final locked = NarrativeEngine.getLockedChoices(testScene, state);

      // guile_choice is locked but visible (hidden: false)
      // hidden_choice is locked AND hidden — excluded
      expect(locked, hasLength(1));
      expect(locked[0].id, 'guile_choice');
    });

    test('getLockedChoices returns empty when all thresholds met', () {
      final state = VeilState.fromMap({
        VeilType.guile: 15,
        VeilType.dread: 25,
      });

      final locked = NarrativeEngine.getLockedChoices(testScene, state);

      expect(locked, isEmpty);
    });
  });
}
