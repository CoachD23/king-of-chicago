import 'package:equatable/equatable.dart';

import 'racket.dart';
import 'racket_data.dart';

/// Immutable state holding all rackets in the player's empire.
///
/// All mutation methods return a new [RacketState] instance;
/// the original is never modified.
class RacketState extends Equatable {
  final List<Racket> rackets;

  const RacketState({required this.rackets});

  /// Creates the initial state with all rackets at tier 0.
  factory RacketState.initial() {
    return RacketState(
      rackets: List.unmodifiable(RacketData.allRackets),
    );
  }

  /// Returns the racket for the given [territoryId].
  ///
  /// Throws [ArgumentError] if no racket exists for that territory.
  Racket getRacket(String territoryId) {
    final index = rackets.indexWhere((r) => r.territoryId == territoryId);
    if (index == -1) {
      throw ArgumentError('Racket not found for territory: $territoryId');
    }
    return rackets[index];
  }

  /// Returns the income multiplier for the given [territoryId].
  ///
  /// Throws [ArgumentError] if no racket exists for that territory.
  int getIncomeMultiplier(String territoryId) {
    return getRacket(territoryId).incomeMultiplier;
  }

  /// Returns a new state with the racket for [territoryId] upgraded by one tier.
  ///
  /// Throws [ArgumentError] if no racket exists for that territory.
  /// Throws [StateError] if the racket is already at max tier.
  RacketState upgradeRacket(String territoryId) {
    final index = rackets.indexWhere((r) => r.territoryId == territoryId);
    if (index == -1) {
      throw ArgumentError('Racket not found for territory: $territoryId');
    }

    final newRackets = rackets.map((r) {
      if (r.territoryId == territoryId) {
        return r.upgraded();
      }
      return r;
    }).toList();

    return RacketState(rackets: List.unmodifiable(newRackets));
  }

  @override
  List<Object?> get props => [rackets];
}
