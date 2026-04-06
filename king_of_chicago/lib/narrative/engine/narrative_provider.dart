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
  final String? pendingAction;
  final Map<String, dynamic>? pendingActionConfig;
  final String? error;

  const NarrativeState({
    this.currentScene,
    this.sceneHistory = const [],
    this.isLoading = false,
    this.pendingAction,
    this.pendingActionConfig,
    this.error,
  });

  NarrativeState copyWith({
    Scene? currentScene,
    List<String>? sceneHistory,
    bool? isLoading,
    String? pendingAction,
    Map<String, dynamic>? pendingActionConfig,
    String? error,
    bool clearPendingAction = false,
    bool clearError = false,
  }) {
    return NarrativeState(
      currentScene: currentScene ?? this.currentScene,
      sceneHistory: sceneHistory ?? this.sceneHistory,
      isLoading: isLoading ?? this.isLoading,
      pendingAction: clearPendingAction ? null : (pendingAction ?? this.pendingAction),
      pendingActionConfig:
          clearPendingAction ? null : (pendingActionConfig ?? this.pendingActionConfig),
      error: clearError ? null : (error ?? this.error),
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
  ///
  /// If the YAML file does not exist, sets an error state instead of crashing.
  Future<void> loadScene(String sceneId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final yamlString =
          await rootBundle.loadString('assets/story/act1/$sceneId.yaml');
      final scene = SceneParser.parseFromString(yamlString);

      state = NarrativeState(
        currentScene: scene,
        sceneHistory: [...state.sceneHistory, sceneId],
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Scene not found: $sceneId ($e)',
      );
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

    // Check if the newly loaded scene has an action trigger
    final scene = state.currentScene;
    if (scene != null && scene.action != null) {
      state = state.copyWith(
        pendingAction: scene.action,
        pendingActionConfig: scene.actionConfig,
      );
    }
  }

  /// Clears the pending action after the action screen completes.
  void clearPendingAction() {
    state = state.copyWith(clearPendingAction: true);
  }

  /// Clears the error state and returns to the last valid scene.
  void clearError() {
    if (state.sceneHistory.length >= 2) {
      final previousSceneId =
          state.sceneHistory[state.sceneHistory.length - 2];
      loadScene(previousSceneId);
    } else {
      state = state.copyWith(clearError: true);
    }
  }
}

/// Provider for the narrative game flow controller.
final narrativeProvider =
    NotifierProvider<NarrativeNotifier, NarrativeState>(NarrativeNotifier.new);
