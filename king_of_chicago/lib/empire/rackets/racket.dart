import 'package:equatable/equatable.dart';

/// Represents a single tier of a racket upgrade.
///
/// Each tier has a name, an income multiplier, an upgrade cost,
/// and a map of veil effects that shift when the upgrade is applied.
class RacketTier extends Equatable {
  final String name;
  final int incomeMultiplier;
  final int upgradeCost;
  final Map<String, int> veilEffect;

  const RacketTier({
    required this.name,
    required this.incomeMultiplier,
    required this.upgradeCost,
    required this.veilEffect,
  });

  @override
  List<Object?> get props => [name, incomeMultiplier, upgradeCost, veilEffect];
}

/// Represents a racket attached to a territory.
///
/// Rackets can be upgraded through 3 tiers (indices 0, 1, 2).
/// Each upgrade increases income and shifts veils.
class Racket extends Equatable {
  final String territoryId;
  final String type;
  final int currentTier;
  final List<RacketTier> tiers;

  const Racket({
    required this.territoryId,
    required this.type,
    required this.currentTier,
    required this.tiers,
  });

  /// The current tier definition.
  RacketTier get current => tiers[currentTier];

  /// Whether the racket can be upgraded further.
  bool get canUpgrade => currentTier < tiers.length - 1;

  /// The next tier definition, or null if already at max.
  RacketTier? get nextTier => canUpgrade ? tiers[currentTier + 1] : null;

  /// The income multiplier for the current tier.
  int get incomeMultiplier => current.incomeMultiplier;

  /// Returns a new [Racket] with [currentTier] incremented by 1.
  ///
  /// Throws [StateError] if already at max tier.
  Racket upgraded() {
    if (!canUpgrade) {
      throw StateError(
        'Cannot upgrade racket "$type" in $territoryId: already at max tier',
      );
    }
    return Racket(
      territoryId: territoryId,
      type: type,
      currentTier: currentTier + 1,
      tiers: tiers,
    );
  }

  @override
  List<Object?> get props => [territoryId, type, currentTier, tiers];
}
