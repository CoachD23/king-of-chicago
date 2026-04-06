import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/veils/veil_provider.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/veil_hud.dart';
import '../engine/narrative_engine.dart';
import '../engine/scene.dart';
import 'choice_wheel.dart';
import 'dialogue_text.dart';

/// Displays a scene's dialogue lines with Veil-aware choice selection.
class DialogueScreen extends ConsumerWidget {
  final Scene scene;
  final void Function(Choice choice) onChoiceSelected;

  const DialogueScreen({
    super.key,
    required this.scene,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veilState = ref.watch(veilProvider);
    final available = NarrativeEngine.getAvailableChoices(scene, veilState);
    final locked = NarrativeEngine.getLockedChoices(scene, veilState);

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationHeader(),
            const VeilHud(),
            Expanded(child: _buildDialogueList()),
            ChoiceWheel(
              availableChoices: available,
              lockedChoices: locked,
              onChoiceSelected: onChoiceSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: GameTheme.borderColor),
        ),
      ),
      child: Text(
        scene.location.toUpperCase(),
        style: GameTheme.locationStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDialogueList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: scene.dialogue.length,
      itemBuilder: (context, index) {
        return DialogueText(dialogueLine: scene.dialogue[index]);
      },
    );
  }
}
