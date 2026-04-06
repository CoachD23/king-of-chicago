import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'npc_state.dart';

/// Riverpod provider for NPC relationship state.
///
/// Usage:
/// ```dart
/// final relationships = ref.watch(npcProvider);
/// ref.read(npcProvider.notifier).applyDelta('mickey', 10);
/// ```
final npcProvider = NotifierProvider<NpcNotifier, NpcState>(NpcNotifier.new);

/// Notifier managing NPC relationship state transitions.
///
/// All state changes produce new immutable [NpcState] instances.
class NpcNotifier extends Notifier<NpcState> {
  @override
  NpcState build() => NpcState.initial();

  /// Applies a relationship [delta] to the NPC identified by [npcId].
  ///
  /// The resulting value is clamped to [-100, 100].
  void applyDelta(String npcId, int delta) {
    state = state.applyDelta(npcId, delta);
  }

  /// Resets all NPC relationships to their initial values (0).
  void reset() {
    state = NpcState.initial();
  }
}
