import 'package:equatable/equatable.dart';

import '../characters/npc_state.dart';
import '../veils/veil_state.dart';
import '../veils/veil_type.dart';

/// Immutable save data model with JSON serialization.
///
/// Captures the full game state at a point in time: current scene,
/// veil values, NPC relationships, story flags, and cash.
class SaveData extends Equatable {
  final String currentSceneId;
  final VeilState veilState;
  final NpcState npcState;
  final Map<String, dynamic> storyFlags;
  final int cash;

  const SaveData({
    required this.currentSceneId,
    required this.veilState,
    required this.npcState,
    required this.storyFlags,
    required this.cash,
  });

  /// Serializes this save data to a JSON-compatible map.
  ///
  /// Veils are serialized as `{ "dread": 30, "kinship": 50, ... }`.
  /// NPC relationships are serialized as `{ "tommy": 20, ... }`.
  /// Story flags are serialized as-is.
  Map<String, dynamic> toJson() {
    final veilMap = <String, dynamic>{
      for (final veil in VeilType.values) veil.name: veilState.getValue(veil),
    };

    final npcMap = <String, dynamic>{
      for (final entry in npcState.toMap().entries) entry.key: entry.value,
    };

    return {
      'currentSceneId': currentSceneId,
      'veilState': veilMap,
      'npcState': npcMap,
      'storyFlags': Map<String, dynamic>.from(storyFlags),
      'cash': cash,
    };
  }

  /// Deserializes save data from a JSON-compatible map.
  ///
  /// Expects the same structure produced by [toJson].
  factory SaveData.fromJson(Map<String, dynamic> json) {
    final veilJson = json['veilState'] as Map<String, dynamic>;
    final veilMap = <VeilType, int>{
      for (final veil in VeilType.values)
        veil: (veilJson[veil.name] as num?)?.toInt() ?? 0,
    };

    final npcJson = json['npcState'] as Map<String, dynamic>;
    final npcMap = <String, int>{
      for (final entry in npcJson.entries)
        entry.key: (entry.value as num).toInt(),
    };

    final storyFlagsJson = json['storyFlags'] as Map<String, dynamic>;

    return SaveData(
      currentSceneId: json['currentSceneId'] as String,
      veilState: VeilState.fromMap(veilMap),
      npcState: NpcState.fromMap(npcMap),
      storyFlags: Map<String, dynamic>.unmodifiable(storyFlagsJson),
      cash: (json['cash'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [
        currentSceneId,
        veilState,
        npcState,
        storyFlags,
        cash,
      ];
}
