import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/veils/veil_provider.dart';
import '../../core/veils/veil_type.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/art_deco_border.dart';
import '../../ui/widgets/gold_divider.dart';
import '../territory/territory_provider.dart';
import 'empire_provider.dart';

/// Weekly Empire Dashboard showing income, expenses, and territory summary.
class EmpireDashboardScreen extends ConsumerWidget {
  const EmpireDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final territoryState = ref.watch(territoryProvider);
    final veilState = ref.watch(veilProvider);
    final empireState = ref.watch(empireProvider);

    final totalIncome = territoryState.totalIncome();
    final totalHeat = territoryState.territories.fold<int>(
      0,
      (sum, t) => sum + t.heat,
    );
    final swayLevel = veilState.getValue(VeilType.sway);
    final bribes = bribeCost(swayLevel);
    final totalExpenses = crewWages + bribes;
    final netIncome = totalIncome - totalExpenses;

    final controlled = territoryState.territories
        .where((t) => t.assignedCapo != null)
        .length;
    final total = territoryState.territories.length;

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header
              Text(
                'WEEKLY REPORT',
                style: GoogleFonts.playfairDisplay(
                  color: GameTheme.goldHighlight,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              const GoldDivider(verticalPadding: 10, diamondSize: 5),
              Text(
                'WEEK ${empireState.week}',
                style: GameTheme.subtitleStyle,
              ),
              const SizedBox(height: 20),

              // Total Income
              ArtDecoBorder(
                cornerSize: 16,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GameTheme.surface,
                    border: Border.all(
                      color: GameTheme.smoke,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL INCOME',
                        style: GameTheme.labelStyle.copyWith(
                          color: GameTheme.ash,
                          letterSpacing: 3.0,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$$totalIncome',
                        style: GoogleFonts.playfairDisplay(
                          color: GameTheme.goldAccent,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _heatSummary(totalHeat, total),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Income Breakdown
              _sectionHeader('INCOME BREAKDOWN'),
              const SizedBox(height: 8),
              ...territoryState.territories
                  .where((t) => t.assignedCapo != null)
                  .map((t) => _lineItem(
                        t.name,
                        '+\$${t.effectiveIncome}',
                        const Color(0xFF4A7C59),
                      )),
              if (territoryState.territories
                  .every((t) => t.assignedCapo == null))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No territories generating income',
                    style: GoogleFonts.crimsonText(
                      color: GameTheme.ash,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const GoldDivider(verticalPadding: 12, diamondSize: 3),

              // Outgoing
              _sectionHeader('OUTGOING'),
              const SizedBox(height: 8),
              _lineItem('Crew Wages', '-\$$crewWages', GameTheme.bloodAccent),
              _lineItem('Bribes (Sway $swayLevel)', '-\$$bribes',
                  GameTheme.bloodAccent),
              const GoldDivider(verticalPadding: 12, diamondSize: 3),

              // Net Income
              ArtDecoBorder(
                cornerSize: 12,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.surface,
                    border: Border.all(
                      color: GameTheme.smoke,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NET INCOME',
                        style: GameTheme.labelStyle.copyWith(
                          color: GameTheme.ash,
                          letterSpacing: 3.0,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${netIncome >= 0 ? '+' : ''}\$$netIncome',
                        style: GoogleFonts.josefinSans(
                          color: netIncome >= 0
                              ? const Color(0xFF4A7C59)
                              : GameTheme.bloodAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Territory Status
              _sectionHeader('TERRITORY STATUS'),
              const SizedBox(height: 8),
              ArtDecoBorder(
                cornerSize: 10,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameTheme.surface,
                    border: Border.all(
                      color: GameTheme.smoke,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statColumn('CONTROLLED', '$controlled', GameTheme.goldAccent),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: GameTheme.smoke,
                      ),
                      _statColumn('UNCONTROLLED', '${total - controlled}',
                          GameTheme.ash),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: GameTheme.smoke,
                      ),
                      _statColumn('TOTAL', '$total', GameTheme.goldHighlight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current Cash
              ArtDecoBorder(
                cornerSize: 14,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GameTheme.surface,
                    border: Border.all(
                      color: GameTheme.goldAccent.withAlpha(60),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CURRENT CASH',
                        style: GameTheme.labelStyle.copyWith(
                          color: GameTheme.ash,
                          letterSpacing: 3.0,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${empireState.cash}',
                        style: GoogleFonts.playfairDisplay(
                          color: GameTheme.goldHighlight,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GameTheme.speakerStyle.copyWith(
          fontSize: 12,
          letterSpacing: 3.0,
        ),
      ),
    );
  }

  Widget _lineItem(String label, String amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.crimsonText(
              color: GameTheme.parchment,
              fontSize: 15,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.josefinSans(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatSummary(int totalHeat, int territoryCount) {
    final avgHeat = territoryCount > 0 ? totalHeat ~/ territoryCount : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'AVG HEAT: ',
          style: GameTheme.labelStyle.copyWith(
            color: GameTheme.ash,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          '$avgHeat',
          style: GameTheme.labelStyle.copyWith(
            color: avgHeat > 60
                ? GameTheme.bloodAccent
                : avgHeat > 30
                    ? const Color(0xFFBFA42E)
                    : const Color(0xFF2C5F8A),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _statColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.josefinSans(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GameTheme.labelStyle.copyWith(
            color: GameTheme.ash,
            letterSpacing: 1.5,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
