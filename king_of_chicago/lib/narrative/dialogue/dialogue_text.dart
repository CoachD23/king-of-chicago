import 'package:flutter/material.dart';

import '../../ui/theme/game_theme.dart';
import '../engine/scene.dart';

class DialogueText extends StatelessWidget {
  final DialogueLine dialogueLine;

  const DialogueText({super.key, required this.dialogueLine});

  bool get _isNarrator =>
      dialogueLine.speaker.isEmpty ||
      dialogueLine.speaker.toLowerCase() == 'narrator';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isNarrator)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                dialogueLine.speaker.toUpperCase(),
                style: GameTheme.speakerStyle,
              ),
            ),
          Text(
            dialogueLine.line,
            style: _isNarrator
                ? GameTheme.narratorStyle
                : GameTheme.dialogueStyle,
          ),
        ],
      ),
    );
  }
}
