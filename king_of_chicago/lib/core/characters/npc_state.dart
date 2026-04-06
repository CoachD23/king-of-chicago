import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'npc.dart';

/// Immutable state tracking relationship values for all NPCs.
///
/// Relationship values are integers clamped to the range [-100, 100].
/// Positive values indicate friendship/trust, negative values indicate
/// hostility/distrust.
class NpcState extends Equatable {
  final Map<String, int> _relationships;

  const NpcState._(this._relationships);

  /// Creates the initial state with all MVP NPCs at relationship 0.
  factory NpcState.initial() {
    final map = <String, int>{
      for (final npc in Npc.mvpNpcs) npc.id: 0,
    };
    return NpcState._(Map.unmodifiable(map));
  }

  /// Creates state from a map, clamping all values to [-100, 100].
  factory NpcState.fromMap(Map<String, int> relationships) {
    final clamped = <String, int>{
      for (final entry in relationships.entries)
        entry.key: entry.value.clamp(-100, 100),
    };
    return NpcState._(Map.unmodifiable(clamped));
  }

  /// Returns the relationship value for the given [npcId].
  ///
  /// Throws [ArgumentError] if the NPC id is not found.
  int getRelationship(String npcId) {
    if (!_relationships.containsKey(npcId)) {
      throw ArgumentError('Unknown NPC id: $npcId');
    }
    return _relationships[npcId]!;
  }

  /// Returns a new [NpcState] with [delta] applied to the given [npcId].
  ///
  /// The result is clamped to [-100, 100]. The original state is unchanged.
  /// Throws [ArgumentError] if the NPC id is not found.
  NpcState applyDelta(String npcId, int delta) {
    if (!_relationships.containsKey(npcId)) {
      throw ArgumentError('Unknown NPC id: $npcId');
    }
    final updated = Map<String, int>.from(_relationships);
    updated[npcId] = (_relationships[npcId]! + delta).clamp(-100, 100);
    return NpcState._(Map.unmodifiable(updated));
  }

  /// Returns an unmodifiable view of the relationship map.
  Map<String, int> toMap() {
    return UnmodifiableMapView<String, int>(_relationships);
  }

  @override
  List<Object?> get props => [_relationships];
}
