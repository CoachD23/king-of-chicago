import 'package:equatable/equatable.dart';

import 'territory.dart';

/// Immutable state holding all territories in the player's empire.
///
/// All mutation methods return a new [TerritoryState] instance;
/// the original is never modified.
class TerritoryState extends Equatable {
  final List<Territory> territories;

  const TerritoryState({required this.territories});

  /// Creates the initial MVP state with 3 territories.
  factory TerritoryState.mvpInitial() {
    return TerritoryState(
      territories: List.unmodifiable(Territory.mvpTerritories),
    );
  }

  /// Returns the territory with the given [id].
  ///
  /// Throws [ArgumentError] if no territory with that id exists.
  Territory getTerritory(String id) {
    final index = territories.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw ArgumentError('Territory not found: $id');
    }
    return territories[index];
  }

  /// Returns a new state with [capoId] assigned to the territory [territoryId].
  TerritoryState assignCapo(String territoryId, String capoId) {
    return _updateTerritory(
      territoryId,
      (t) => t.copyWith(assignedCapo: capoId),
    );
  }

  /// Returns a new state with heat adjusted by [amount] on [territoryId].
  ///
  /// Heat is clamped to 0-100.
  TerritoryState addHeat(String territoryId, int amount) {
    return _updateTerritory(
      territoryId,
      (t) => t.copyWith(heat: t.heat + amount),
    );
  }

  /// Returns the sum of effective incomes across all territories.
  int totalIncome() {
    return territories.fold<int>(0, (sum, t) => sum + t.effectiveIncome);
  }

  /// Internal helper: returns a new state with one territory replaced.
  TerritoryState _updateTerritory(
    String territoryId,
    Territory Function(Territory) update,
  ) {
    final newTerritories = territories.map((t) {
      if (t.id == territoryId) {
        return update(t);
      }
      return t;
    }).toList();

    return TerritoryState(territories: List.unmodifiable(newTerritories));
  }

  @override
  List<Object?> get props => [territories];
}
