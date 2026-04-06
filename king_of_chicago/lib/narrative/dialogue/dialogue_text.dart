import 'package:flutter/material.dart';

import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/character_portrait.dart';
import '../engine/scene.dart';

/// Art Deco styled dialogue line display.
///
/// Speaker names appear in Josefin Sans, uppercase, gold, with a thin underline.
/// Dialogue uses Crimson Text in parchment. Narrator text is italic with a
/// left gold border like a pull quote. Each line fades in for drama.
class DialogueText extends StatefulWidget {
  final DialogueLine dialogueLine;

  const DialogueText({super.key, required this.dialogueLine});

  @override
  State<DialogueText> createState() => _DialogueTextState();
}

class _DialogueTextState extends State<DialogueText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool get _isNarrator =>
      widget.dialogueLine.speaker.isEmpty ||
      widget.dialogueLine.speaker.toLowerCase() == 'narrator';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        child: _isNarrator ? _buildNarratorText() : _buildSpeakerText(),
      ),
    );
  }

  Widget _buildSpeakerText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CharacterPortrait(speaker: widget.dialogueLine.speaker),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speaker name with gold underline
              Container(
                padding: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: GameTheme.goldAccent,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  widget.dialogueLine.speaker.toUpperCase(),
                  style: GameTheme.speakerStyle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.dialogueLine.line,
                style: GameTheme.dialogueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarratorText() {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      decoration: const BoxDecoration(
        color: Color(0x08C9A84C),
        border: Border(
          left: BorderSide(
            color: GameTheme.goldAccent,
            width: 3.0,
          ),
        ),
      ),
      child: Text(
        widget.dialogueLine.line,
        style: GameTheme.narratorStyle,
      ),
    );
  }
}
