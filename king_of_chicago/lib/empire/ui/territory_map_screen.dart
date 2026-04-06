import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/art_deco_border.dart';
import '../../ui/widgets/gold_divider.dart';
import '../territory/territory.dart';
import '../territory/territory_provider.dart';

/// Visual territory map showing all territories as Art Deco cards.
class TerritoryMapScreen extends ConsumerWidget {
  const TerritoryMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final territoryState = ref.watch(territoryProvider);

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'TERRITORIES',
              style: GameTheme.titleStyle.copyWith(fontSize: 24),
            ),
            const GoldDivider(verticalPadding: 8, diamondSize: 5),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: territoryState.territories.length,
                itemBuilder: (context, index) {
                  final territory = territoryState.territories[index];
                  return _TerritoryCard(territory: territory);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single territory card with Art Deco styling.
class _TerritoryCard extends StatelessWidget {
  final Territory territory;

  const _TerritoryCard({required this.territory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showTerritoryDetail(context),
        child: ArtDecoBorder(
          cornerSize: 14,
          strokeWidth: 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: GameTheme.surface,
              border: Border.all(
                color: GameTheme.smoke,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Territory name
                Text(
                  territory.name.toUpperCase(),
                  style: GoogleFonts.josefinSans(
                    color: GameTheme.goldAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 4),
                // Character description
                Text(
                  territory.character,
                  style: GoogleFonts.crimsonText(
                    color: GameTheme.ash,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Primary racket
                Row(
                  children: [
                    Text(
                      'RACKET: ',
                      style: GameTheme.labelStyle.copyWith(
                        color: GameTheme.ash,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        territory.primaryRacket,
                        style: GameTheme.labelStyle.copyWith(
                          color: GameTheme.goldHighlight,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Income bar
                _buildBar(
                  label: 'INCOME',
                  value: territory.baseIncome,
                  maxValue: 1000,
                  color: const Color(0xFF4A7C59),
                  valueLabel: '\$${territory.baseIncome}',
                ),
                const SizedBox(height: 6),
                // Heat bar
                _buildHeatBar(),
                const SizedBox(height: 10),
                // Assigned capo
                Row(
                  children: [
                    Text(
                      'CAPO: ',
                      style: GameTheme.labelStyle.copyWith(
                        color: GameTheme.ash,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      territory.assignedCapo?.toUpperCase() ?? 'UNASSIGNED',
                      style: GameTheme.labelStyle.copyWith(
                        color: territory.assignedCapo != null
                            ? GameTheme.goldHighlight
                            : GameTheme.bloodAccent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required int value,
    required int maxValue,
    required Color color,
    required String valueLabel,
  }) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: GameTheme.labelStyle.copyWith(
              color: GameTheme.ash,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: GameTheme.smoke,
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            valueLabel,
            textAlign: TextAlign.right,
            style: GameTheme.labelStyle.copyWith(
              color: GameTheme.goldHighlight,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatBar() {
    final fraction = (territory.heat / 100).clamp(0.0, 1.0);
    // Gradient: blue (cold) -> yellow (warm) -> red (hot)
    final heatColor = _heatColor(fraction);
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            'HEAT',
            style: GameTheme.labelStyle.copyWith(
              color: GameTheme.ash,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: GameTheme.smoke,
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2C5F8A),
                      const Color(0xFFBFA42E),
                      heatColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${territory.heat}',
            textAlign: TextAlign.right,
            style: GameTheme.labelStyle.copyWith(
              color: heatColor,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a color on the blue -> yellow -> red gradient for heat.
  Color _heatColor(double fraction) {
    if (fraction < 0.5) {
      return Color.lerp(
        const Color(0xFF2C5F8A),
        const Color(0xFFBFA42E),
        fraction * 2,
      )!;
    }
    return Color.lerp(
      const Color(0xFFBFA42E),
      const Color(0xFF8B1A1A),
      (fraction - 0.5) * 2,
    )!;
  }

  void _showTerritoryDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  territory.name.toUpperCase(),
                  style: GameTheme.titleStyle.copyWith(fontSize: 20),
                ),
              ),
              const GoldDivider(verticalPadding: 12, diamondSize: 4),
              _detailRow('Character', territory.character),
              const SizedBox(height: 8),
              _detailRow('Primary Racket', territory.primaryRacket),
              const SizedBox(height: 8),
              _detailRow('Base Income', '\$${territory.baseIncome}/week'),
              const SizedBox(height: 8),
              _detailRow('Heat Level', '${territory.heat}/100'),
              const SizedBox(height: 8),
              _detailRow(
                'Assigned Capo',
                territory.assignedCapo ?? 'None',
              ),
              const SizedBox(height: 8),
              _detailRow(
                'Status',
                territory.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label.toUpperCase(),
            style: GameTheme.labelStyle.copyWith(
              color: GameTheme.ash,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.crimsonText(
              color: GameTheme.parchment,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
