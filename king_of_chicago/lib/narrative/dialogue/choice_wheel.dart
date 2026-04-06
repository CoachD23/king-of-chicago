import 'package:flutter/material.dart';

import '../../core/veils/veil_type.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/theme/veil_colors.dart';
import '../../ui/widgets/art_deco_border.dart';
import '../engine/scene.dart';

/// Choices presented as noir cards on felt.
///
/// Each choice has a thin vertical bar on the left in the Veil's color,
/// art deco corner decorations, and hover/tap glow effects.
class ChoiceWheel extends StatelessWidget {
  final List<Choice> availableChoices;
  final List<Choice> lockedChoices;
  final void Function(Choice choice) onChoiceSelected;

  const ChoiceWheel({
    super.key,
    required this.availableChoices,
    required this.lockedChoices,
    required this.onChoiceSelected,
  });

  static final Map<String, VeilType> _nameToType = {
    for (final veil in VeilType.values) veil.name: veil,
  };

  static VeilType? _primaryVeil(Map<String, int> veils) {
    if (veils.isEmpty) return null;
    String? maxKey;
    int maxAbs = 0;
    for (final entry in veils.entries) {
      final abs = entry.value.abs();
      if (abs > maxAbs) {
        maxAbs = abs;
        maxKey = entry.key;
      }
    }
    return maxKey == null ? null : _nameToType[maxKey];
  }

  static IconData _veilIcon(VeilType veil) {
    return switch (veil) {
      VeilType.dread => Icons.whatshot,
      VeilType.respect => Icons.star,
      VeilType.sway => Icons.people,
      VeilType.empire => Icons.account_balance,
      VeilType.guile => Icons.psychology,
      VeilType.legend => Icons.auto_awesome,
      VeilType.kinship => Icons.favorite,
    };
  }

  static String _deltaHints(Map<String, int> veils) {
    final parts = <String>[];
    for (final entry in veils.entries) {
      final veil = _nameToType[entry.key];
      if (veil == null) continue;
      final sign = entry.value > 0 ? '+' : '';
      parts.add('$sign${entry.value} ${veil.displayName}');
    }
    return parts.join('  ');
  }

  static String _requirementText(Map<String, int> requires) {
    final parts = <String>[];
    for (final entry in requires.entries) {
      final veil = _nameToType[entry.key];
      if (veil == null) continue;
      parts.add('Requires ${veil.displayName} ${entry.value}+');
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: GameTheme.surface,
        border: Border(
          top: BorderSide(color: GameTheme.goldAccent, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...availableChoices.map(_buildAvailableChoice),
          ...lockedChoices.map(_buildLockedChoice),
        ],
      ),
    );
  }

  Widget _buildAvailableChoice(Choice choice) {
    final veil = _primaryVeil(choice.veils);
    final color =
        veil != null ? VeilColors.getGlow(veil) : GameTheme.goldAccent;
    final primaryColor =
        veil != null ? VeilColors.getColor(veil) : GameTheme.smoke;
    final hints = _deltaHints(choice.veils);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _ChoiceCard(
        choice: choice,
        veilColor: color,
        primaryColor: primaryColor,
        veil: veil,
        hints: hints,
        onTap: () => onChoiceSelected(choice),
      ),
    );
  }

  Widget _buildLockedChoice(Choice choice) {
    final requirementLabel = choice.requires != null
        ? _requirementText(choice.requires!)
        : 'Locked';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArtDecoBorder(
        color: GameTheme.lockedGrey.withAlpha(60),
        cornerSize: 8,
        strokeWidth: 0.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GameTheme.backgroundColor,
            border: Border(
              left:
                  BorderSide(color: GameTheme.lockedGrey.withAlpha(80), width: 3),
              top:
                  BorderSide(color: GameTheme.smoke.withAlpha(60), width: 0.5),
              bottom:
                  BorderSide(color: GameTheme.smoke.withAlpha(60), width: 0.5),
              right:
                  BorderSide(color: GameTheme.smoke.withAlpha(60), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.lock_outline,
                  color: GameTheme.lockedGrey,
                  size: 18,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(choice.line, style: GameTheme.lockedChoiceStyle),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        requirementLabel,
                        style: GameTheme.deltaHintStyle.copyWith(
                          color: GameTheme.lockedGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single choice card with hover/tap interaction.
class _ChoiceCard extends StatefulWidget {
  final Choice choice;
  final Color veilColor;
  final Color primaryColor;
  final VeilType? veil;
  final String hints;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.choice,
    required this.veilColor,
    required this.primaryColor,
    required this.veil,
    required this.hints,
    required this.onTap,
  });

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final decoration = _isHovered
        ? GameTheme.hoveredChoiceCardDecoration(widget.veilColor)
        : GameTheme.choiceCardDecoration(widget.veilColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ArtDecoBorder(
          color: _isHovered
              ? widget.veilColor.withAlpha(120)
              : GameTheme.smoke.withAlpha(60),
          cornerSize: 8,
          strokeWidth: 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: decoration,
            child: Row(
              children: [
                if (widget.veil != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      ChoiceWheel._veilIcon(widget.veil!),
                      color: _isHovered
                          ? widget.veilColor
                          : widget.primaryColor,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.choice.line,
                        style: GameTheme.choiceStyle,
                      ),
                      if (widget.hints.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.hints,
                            style: GameTheme.deltaHintStyle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
