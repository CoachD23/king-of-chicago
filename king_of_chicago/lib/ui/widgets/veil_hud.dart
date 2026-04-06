import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/veils/veil_provider.dart';
import '../../core/veils/veil_type.dart';
import '../theme/game_theme.dart';
import '../theme/veil_colors.dart';
import 'art_deco_border.dart';

/// An elegant art deco status bar showing all 7 Veils as vertical bars.
///
/// Each indicator is a small vertical bar whose height fills based on value
/// (0-100), colored with the Veil's glow color. The whole bar sits in a
/// panel with art deco corner decorations.
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

    return ArtDecoBorder(
      cornerSize: 10,
      strokeWidth: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: GameTheme.backgroundColor,
          border: Border(
            top: BorderSide(color: GameTheme.goldAccent, width: 0.5),
            bottom: BorderSide(color: GameTheme.goldAccent, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: VeilType.values.map((veil) {
            final glowColor = VeilColors.getGlow(veil);
            final primaryColor = VeilColors.getColor(veil);
            final value = veilState.getValue(veil);
            final abbr = _abbreviations[veil] ??
                veil.displayName.substring(0, 3).toUpperCase();

            return _VeilBar(
              glowColor: glowColor,
              primaryColor: primaryColor,
              abbreviation: abbr,
              value: value,
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _VeilBar extends StatelessWidget {
  final Color glowColor;
  final Color primaryColor;
  final String abbreviation;
  final int value;

  static const double _barHeight = 40.0;
  static const double _barWidth = 20.0;

  const _VeilBar({
    required this.glowColor,
    required this.primaryColor,
    required this.abbreviation,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final fillFraction = (value / 100).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Value above bar
        if (value > 0)
          Text(
            '$value',
            style: GameTheme.veilValueStyle.copyWith(color: glowColor),
          ),
        if (value == 0)
          Text(
            '-',
            style: GameTheme.veilValueStyle.copyWith(
              color: GameTheme.ash.withAlpha(80),
            ),
          ),
        const SizedBox(height: 2),
        // The vertical bar
        Container(
          width: _barWidth,
          height: _barHeight,
          decoration: BoxDecoration(
            color: GameTheme.backgroundColor,
            border: Border.all(color: glowColor.withAlpha(100), width: 1.0),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: _barWidth,
              height: _barHeight * fillFraction,
              decoration: BoxDecoration(
                color: glowColor.withAlpha(220),
                borderRadius: BorderRadius.circular(2),
                boxShadow: value > 0
                    ? [
                        BoxShadow(
                          color: glowColor.withAlpha(80),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Abbreviated label
        Text(
          abbreviation,
          style: GameTheme.labelStyle.copyWith(
            color: primaryColor.withAlpha(180),
          ),
        ),
      ],
    );
  }
}
