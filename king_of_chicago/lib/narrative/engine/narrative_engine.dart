import '../../core/veils/veil_engine.dart';
import '../../core/veils/veil_state.dart';
import 'scene.dart';

class NarrativeEngine {
  NarrativeEngine._();

  /// Returns choices the player CAN select (meets all veil thresholds).
  static List<Choice> getAvailableChoices(Scene scene, VeilState state) {
    return scene.choices
        .where((choice) => VeilEngine.isChoiceAvailable(state, choice.requires))
        .toList(growable: false);
  }

  /// Returns choices that are visible but locked (does not meet thresholds).
  /// Excludes hidden choices — those should not appear at all when locked.
  static List<Choice> getLockedChoices(Scene scene, VeilState state) {
    return scene.choices
        .where((choice) =>
            !VeilEngine.isChoiceAvailable(state, choice.requires) &&
            !choice.hidden)
        .toList(growable: false);
  }
}
