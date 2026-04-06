import 'veil_state.dart';
import 'veil_type.dart';

class VeilEngine {
  VeilEngine._();

  static final Map<String, VeilType> _nameToType = {
    for (final veil in VeilType.values) veil.name: veil,
  };

  static VeilState applyChoice(VeilState state, Map<String, int> veilDeltas) {
    final typedDeltas = <VeilType, int>{};
    for (final entry in veilDeltas.entries) {
      final veilType = _nameToType[entry.key];
      if (veilType != null) {
        typedDeltas[veilType] = entry.value;
      }
    }
    return state.applyDeltas(typedDeltas);
  }

  static bool isChoiceAvailable(
    VeilState state,
    Map<String, int>? requirements,
  ) {
    if (requirements == null || requirements.isEmpty) {
      return true;
    }
    for (final entry in requirements.entries) {
      final veilType = _nameToType[entry.key];
      if (veilType != null && !state.meetsThreshold(veilType, entry.value)) {
        return false;
      }
    }
    return true;
  }
}
