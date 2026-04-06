import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/characters/npc_provider.dart';
import '../../core/veils/veil_provider.dart';
import '../../empire/territory/territory_provider.dart';
import 'scene.dart';
import 'scene_parser.dart';

/// Immutable state for the narrative system.
class NarrativeState {
  final Scene? currentScene;
  final List<String> sceneHistory;
  final bool isLoading;

  const NarrativeState({
    this.currentScene,
    this.sceneHistory = const [],
    this.isLoading = false,
  });

  NarrativeState copyWith({
    Scene? currentScene,
    List<String>? sceneHistory,
    bool? isLoading,
  }) {
    return NarrativeState(
      currentScene: currentScene ?? this.currentScene,
      sceneHistory: sceneHistory ?? this.sceneHistory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier that orchestrates narrative flow across game systems.
///
/// Loads YAML scene files, applies choice effects to veils, NPCs,
/// and territories, then advances to the next scene.
class NarrativeNotifier extends Notifier<NarrativeState> {
  @override
  NarrativeState build() => const NarrativeState();

  /// Loads a scene from `assets/story/act1/[sceneId].yaml`.
  Future<void> loadScene(String sceneId) async {
    state = state.copyWith(isLoading: true);

    try {
      final yamlString =
          await rootBundle.loadString('assets/story/act1/$sceneId.yaml');
      final scene = SceneParser.parseFromString(yamlString);

      state = NarrativeState(
        currentScene: scene,
        sceneHistory: [...state.sceneHistory, sceneId],
        isLoading: false,
      );
    } on Exception {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Applies all effects from [choice] and loads the next scene.
  ///
  /// Order: veil deltas -> NPC deltas -> heat deltas -> next scene.
  Future<void> selectChoice(Choice choice) async {
    // Apply veil deltas
    if (choice.veils.isNotEmpty) {
      ref.read(veilProvider.notifier).applyStringDeltas(choice.veils);
    }

    // Apply NPC relationship deltas
    final npcDeltas = choice.npcDeltas;
    if (npcDeltas != null && npcDeltas.isNotEmpty) {
      final npcNotifier = ref.read(npcProvider.notifier);
      for (final entry in npcDeltas.entries) {
        npcNotifier.applyDelta(entry.key, entry.value);
      }
    }

    // Apply heat deltas to territories
    final heatDeltas = choice.heat;
    if (heatDeltas != null && heatDeltas.isNotEmpty) {
      final territoryNotifier = ref.read(territoryProvider.notifier);
      for (final entry in heatDeltas.entries) {
        territoryNotifier.addHeat(entry.key, entry.value);
      }
    }

    // Load the next scene
    await loadScene(choice.next);
  }
}

/// Provider for the narrative game flow controller.
final narrativeProvider =
    NotifierProvider<NarrativeNotifier, NarrativeState>(NarrativeNotifier.new);
