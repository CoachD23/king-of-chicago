import 'package:flutter/material.dart';

import '../../core/veils/veil_type.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/theme/veil_colors.dart';
import '../engine/scene.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final color = veil != null ? VeilColors.getColor(veil) : Colors.white;
    final hints = _deltaHints(choice.veils);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => onChoiceSelected(choice),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            border: Border.all(color: color.withAlpha(100)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (veil != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(_veilIcon(veil), color: color, size: 20),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(choice.line, style: GameTheme.choiceStyle),
                    if (hints.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(hints, style: GameTheme.deltaHintStyle),
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

  Widget _buildLockedChoice(Choice choice) {
    final requirementLabel = choice.requires != null
        ? _requirementText(choice.requires!)
        : 'Locked';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GameTheme.lockedGrey.withAlpha(15),
          border: Border.all(color: GameTheme.lockedGrey.withAlpha(60)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child:
                  Icon(Icons.lock_outline, color: GameTheme.lockedGrey, size: 20),
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
    );
  }
}
