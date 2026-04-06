import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'territory_state.dart';

/// Riverpod NotifierProvider for territory/empire state management.
final territoryProvider =
    NotifierProvider<TerritoryNotifier, TerritoryState>(TerritoryNotifier.new);

/// Notifier that manages territory state transitions immutably.
class TerritoryNotifier extends Notifier<TerritoryState> {
  @override
  TerritoryState build() {
    return TerritoryState.mvpInitial();
  }

  /// Assigns a capo to a territory.
  void assignCapo(String territoryId, String capoId) {
    state = state.assignCapo(territoryId, capoId);
  }

  /// Adds heat to a territory (clamped 0-100).
  void addHeat(String territoryId, int amount) {
    state = state.addHeat(territoryId, amount);
  }
}
