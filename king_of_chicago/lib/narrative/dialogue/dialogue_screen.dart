import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/veils/veil_provider.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/art_deco_border.dart';
import '../../ui/widgets/gold_divider.dart';
import '../../ui/widgets/grain_overlay.dart';
import '../../ui/widgets/veil_hud.dart';
import '../engine/narrative_engine.dart';
import '../engine/scene.dart';
import 'choice_wheel.dart';
import 'dialogue_text.dart';

/// Displays a scene's dialogue lines with Veil-aware choice selection.
///
/// Full Art Deco Noir redesign: location header with gold dividers,
/// Veil HUD, scrollable dialogue, and choice cards at the bottom.
/// Reading a letter in a dark room by lamplight.
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
        child: Stack(
          children: [
            // Film grain overlay
            const GrainOverlay(opacity: 0.03),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return ArtDecoBorder(
      cornerSize: 12,
      strokeWidth: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: const BoxDecoration(
          color: GameTheme.surface,
        ),
        child: Column(
          children: [
            const GoldDivider(verticalPadding: 4, diamondSize: 4),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    scene.location.toUpperCase(),
                    style: GameTheme.locationStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (scene.mood.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(
                    _moodIcon(scene.mood),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            const GoldDivider(verticalPadding: 4, diamondSize: 4),
          ],
        ),
      ),
    );
  }

  String _moodIcon(String mood) {
    return switch (mood.toLowerCase()) {
      'tense' => '\u2620', // skull and crossbones
      'dark' => '\u263D', // crescent moon
      'hopeful' => '\u2605', // star
      'angry' => '\u2694', // crossed swords
      'calm' => '\u2015', // horizontal bar
      _ => '\u25C6', // diamond
    };
  }

  Widget _buildDialogueList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: scene.dialogue.length,
      itemBuilder: (context, index) {
        return DialogueText(dialogueLine: scene.dialogue[index]);
      },
    );
  }
}
