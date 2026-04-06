import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../territory/territory_provider.dart';
import '../../core/veils/veil_provider.dart';
import '../../core/veils/veil_type.dart';

/// Immutable state representing the player's cash and current week.
class EmpireState extends Equatable {
  final int cash;
  final int week;

  const EmpireState({this.cash = 1000, this.week = 1});

  EmpireState copyWith({int? cash, int? week}) {
    return EmpireState(
      cash: cash ?? this.cash,
      week: week ?? this.week,
    );
  }

  @override
  List<Object?> get props => [cash, week];
}

/// Fixed weekly crew wages.
const int crewWages = 200;

/// Calculates bribe cost based on Sway veil level.
int bribeCost(int swayLevel) => (swayLevel * 1.5).round();

/// Notifier managing the empire economy state.
class EmpireNotifier extends Notifier<EmpireState> {
  @override
  EmpireState build() => const EmpireState();

  /// Adds (or subtracts) cash.
  void addCash(int amount) {
    state = state.copyWith(cash: state.cash + amount);
  }

  /// Collects income from territories, pays expenses, and advances the week.
  void advanceWeek() {
    final territories = ref.read(territoryProvider);
    final veils = ref.read(veilProvider);

    final income = territories.totalIncome();
    final swayLevel = veils.getValue(VeilType.sway);
    final expenses = crewWages + bribeCost(swayLevel);
    final net = income - expenses;

    state = state.copyWith(
      cash: state.cash + net,
      week: state.week + 1,
    );
  }
}

/// Riverpod provider for the empire economy state.
final empireProvider =
    NotifierProvider<EmpireNotifier, EmpireState>(EmpireNotifier.new);
