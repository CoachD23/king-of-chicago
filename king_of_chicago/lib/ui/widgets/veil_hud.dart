import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/veils/veil_provider.dart';
import '../../core/veils/veil_type.dart';
import '../theme/game_theme.dart';
import '../theme/veil_colors.dart';

/// A compact horizontal bar showing all 7 Veils with colored dots and values.
///
/// Watches [veilProvider] for reactive updates. Designed to sit at the top
/// of the DialogueScreen between the location header and dialogue content.
class VeilHud extends ConsumerWidget {
  const VeilHud({super.key});

  static const Map<VeilType, String> _abbreviations = {
    VeilType.dread: 'DRD',
    VeilType.respect: 'RSP',
    VeilType.sway: 'SWY',
    VeilType.empire: 'EMP',
    VeilType.guile: 'GLE',
    VeilType.legend: 'LGD',
    VeilType.kinship: 'KIN',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veilState = ref.watch(veilProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(
          bottom: BorderSide(color: GameTheme.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: VeilType.values.map((veil) {
          final color = VeilColors.getColor(veil);
          final value = veilState.getValue(veil);
          final abbr = _abbreviations[veil] ?? veil.displayName.substring(0, 3).toUpperCase();

          return _VeilChip(color: color, abbreviation: abbr, value: value);
        }).toList(growable: false),
      ),
    );
  }
}

class _VeilChip extends StatelessWidget {
  final Color color;
  final String abbreviation;
  final int value;

  const _VeilChip({
    required this.color,
    required this.abbreviation,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          abbreviation,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: color.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
