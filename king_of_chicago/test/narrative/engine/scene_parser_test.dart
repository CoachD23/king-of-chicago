import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/narrative/engine/scene_parser.dart';

void main() {
  const validYaml = '''
scene: funeral_arrival
location: south_side
characters:
  - vince
  - enzo
  - tommy
mood: somber
type: river
dialogue:
  - speaker: narrator
    line: "Rain hammers the black umbrellas."
  - speaker: enzo
    line: "Vince. Come."
choices:
  - id: respect_enzo
    line: "Of course, Uncle Enzo."
    veils:
      kinship: 2
      respect: 1
    npc_deltas:
      enzo: 5
    next: enzo_backroom
  - id: scan_crowd
    line: "In a minute."
    veils:
      guile: 2
    heat:
      south_side: 1
    next: funeral_crowd_scan
  - id: secret_option
    line: "I know what really happened."
    veils:
      dread: 3
    requires:
      guile: 10
    next: secret_scene
    hidden: true
''';

  group('SceneParser', () {
    test('parses a valid YAML scene (id, location, characters, mood, type)',
        () {
      final scene = SceneParser.parseFromString(validYaml);

      expect(scene.id, 'funeral_arrival');
      expect(scene.location, 'south_side');
      expect(scene.characters, ['vince', 'enzo', 'tommy']);
      expect(scene.mood, 'somber');
      expect(scene.type, 'river');
    });

    test('parses dialogue lines (speaker, line content)', () {
      final scene = SceneParser.parseFromString(validYaml);

      expect(scene.dialogue, hasLength(2));
      expect(scene.dialogue[0].speaker, 'narrator');
      expect(scene.dialogue[0].line, 'Rain hammers the black umbrellas.');
      expect(scene.dialogue[1].speaker, 'enzo');
      expect(scene.dialogue[1].line, 'Vince. Come.');
    });

    test('parses choices with veils, heat, requirements, next, hidden', () {
      final scene = SceneParser.parseFromString(validYaml);

      expect(scene.choices, hasLength(3));

      // Choice with npc_deltas
      final choice0 = scene.choices[0];
      expect(choice0.id, 'respect_enzo');
      expect(choice0.line, 'Of course, Uncle Enzo.');
      expect(choice0.veils, {'kinship': 2, 'respect': 1});
      expect(choice0.npcDeltas, {'enzo': 5});
      expect(choice0.next, 'enzo_backroom');
      expect(choice0.hidden, false);
      expect(choice0.heat, isNull);
      expect(choice0.requires, isNull);

      // Choice with heat
      final choice1 = scene.choices[1];
      expect(choice1.heat, {'south_side': 1});

      // Choice with requires and hidden
      final choice2 = scene.choices[2];
      expect(choice2.requires, {'guile': 10});
      expect(choice2.hidden, true);
    });

    test('parses scene without optional type field', () {
      const yamlNoType = '''
scene: test_scene
location: downtown
characters:
  - vince
mood: tense
dialogue:
  - speaker: narrator
    line: "Test."
choices:
  - id: go
    line: "Go."
    veils:
      dread: 1
    next: next_scene
''';
      final scene = SceneParser.parseFromString(yamlNoType);
      expect(scene.type, isNull);
      expect(scene.id, 'test_scene');
    });
  });
}
