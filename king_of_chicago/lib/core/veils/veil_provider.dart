import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'veil_engine.dart';
import 'veil_state.dart';
import 'veil_type.dart';

class VeilNotifier extends Notifier<VeilState> {
  @override
  VeilState build() => VeilState.initial();

  void applyDeltas(Map<VeilType, int> deltas) {
    state = state.applyDeltas(deltas);
  }

  void applyStringDeltas(Map<String, int> deltas) {
    state = VeilEngine.applyChoice(state, deltas);
  }

  void reset() {
    state = VeilState.initial();
  }
}

final veilProvider = NotifierProvider<VeilNotifier, VeilState>(
  VeilNotifier.new,
);
