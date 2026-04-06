import 'package:equatable/equatable.dart';

import '../../core/veils/veil_state.dart';
import '../../core/veils/veil_type.dart';

enum ShakedownApproach {
  push('Push', VeilType.dread, 'Threaten violence'),
  leverage('Leverage', VeilType.guile, 'Use what you know'),
  protect('Protect', VeilType.respect, 'Offer your protection'),
  bribe('Bribe', VeilType.empire, 'Make it worth their while'),
  callFavor('Call in a Favor', VeilType.kinship, 'Remind them who you know');

  const ShakedownApproach(this.label, this.veil, this.description);
  final String label;
  final VeilType veil;
  final String description;
}

class ShakedownState extends Equatable {
  final int resistance;
  final int turnsRemaining;
  final List<ShakedownApproach> usedApproaches;

  const ShakedownState._({
    required this.resistance,
    required this.turnsRemaining,
    required this.usedApproaches,
  });

  factory ShakedownState.initial({required int targetResistance}) {
    return ShakedownState._(
      resistance: targetResistance,
      turnsRemaining: 3,
      usedApproaches: const [],
    );
  }

  static const int _basePressure = 20;
  static const double _repeatPenalty = 0.5;

  ShakedownState applyPressure(
    ShakedownApproach approach,
    VeilState veils,
  ) {
    final veilValue = veils.getValue(approach.veil);
    final rawPressure = _basePressure + (veilValue / 100.0) * _basePressure;

    final isRepeat = usedApproaches.contains(approach);
    final effectivePressure =
        isRepeat ? (rawPressure * _repeatPenalty).round() : rawPressure.round();

    final newResistance = (resistance - effectivePressure).clamp(0, resistance);
    final newUsed = isRepeat
        ? usedApproaches
        : List<ShakedownApproach>.unmodifiable([...usedApproaches, approach]);

    return ShakedownState._(
      resistance: newResistance,
      turnsRemaining: turnsRemaining - 1,
      usedApproaches: newUsed,
    );
  }

  bool get isComplete => turnsRemaining <= 0 || resistance <= 0;

  bool get isSuccess => resistance <= 0;

  @override
  List<Object?> get props => [resistance, turnsRemaining, usedApproaches];
}
