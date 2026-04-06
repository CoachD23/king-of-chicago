import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'racket_state.dart';

/// Riverpod NotifierProvider for racket upgrade state management.
final racketProvider =
    NotifierProvider<RacketNotifier, RacketState>(RacketNotifier.new);

/// Notifier that manages racket state transitions immutably.
class RacketNotifier extends Notifier<RacketState> {
  @override
  RacketState build() {
    return RacketState.initial();
  }

  /// Upgrades the racket for the given territory by one tier.
  ///
  /// Throws [StateError] if already at max tier.
  /// Throws [ArgumentError] if territory not found.
  void upgradeRacket(String territoryId) {
    state = state.upgradeRacket(territoryId);
  }
}
