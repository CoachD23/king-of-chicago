import 'package:yaml/yaml.dart';

import 'scene.dart';

class SceneParser {
  SceneParser._();

  static Scene parseFromString(String yamlString) {
    final doc = loadYaml(yamlString) as YamlMap;

    final characters = (doc['characters'] as YamlList)
        .map((c) => c.toString())
        .toList(growable: false);

    final dialogue = (doc['dialogue'] as YamlList).map((d) {
      final map = d as YamlMap;
      return DialogueLine(
        speaker: map['speaker'] as String,
        line: map['line'] as String,
      );
    }).toList(growable: false);

    final choices = (doc['choices'] as YamlList).map((c) {
      final map = c as YamlMap;
      return Choice(
        id: map['id'] as String,
        line: map['line'] as String,
        veils: _parseStringIntMap(map['veils'] as YamlMap),
        heat: map['heat'] != null
            ? _parseStringIntMap(map['heat'] as YamlMap)
            : null,
        requires: map['requires'] != null
            ? _parseStringIntMap(map['requires'] as YamlMap)
            : null,
        npcDeltas: map['npc_deltas'] != null
            ? _parseStringIntMap(map['npc_deltas'] as YamlMap)
            : null,
        next: map['next'] as String,
        hidden: (map['hidden'] as bool?) ?? false,
      );
    }).toList(growable: false);

    return Scene(
      id: doc['scene'] as String,
      location: doc['location'] as String,
      characters: characters,
      mood: doc['mood'] as String,
      dialogue: dialogue,
      choices: choices,
      type: doc['type'] as String?,
    );
  }

  static Map<String, int> _parseStringIntMap(YamlMap yamlMap) {
    return Map<String, int>.unmodifiable({
      for (final entry in yamlMap.entries)
        entry.key.toString(): (entry.value as num).toInt(),
    });
  }
}
