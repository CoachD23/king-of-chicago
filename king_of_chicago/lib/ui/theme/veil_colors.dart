import 'package:flutter/material.dart';

import '../../core/veils/veil_type.dart';

/// Rich, atmospheric colors for each Veil — a primary and a luminous glow.
class VeilColors {
  VeilColors._();

  static const Map<VeilType, Color> primary = {
    VeilType.dread: Color(0xFF8B1A1A),
    VeilType.respect: Color(0xFFC9A84C),
    VeilType.sway: Color(0xFF4A6A8B),
    VeilType.empire: Color(0xFF1B5E3A),
    VeilType.guile: Color(0xFF5B2D7A),
    VeilType.legend: Color(0xFF8B5A00),
    VeilType.kinship: Color(0xFF7A4A2A),
  };

  static const Map<VeilType, Color> glow = {
    VeilType.dread: Color(0xFFE04040),
    VeilType.respect: Color(0xFFE8D5A3),
    VeilType.sway: Color(0xFF8AB4E8),
    VeilType.empire: Color(0xFF50C878),
    VeilType.guile: Color(0xFFB080E0),
    VeilType.legend: Color(0xFFE8A020),
    VeilType.kinship: Color(0xFFD4A060),
  };

  static Color getColor(VeilType veil) => primary[veil] ?? Colors.white;

  static Color getGlow(VeilType veil) => glow[veil] ?? Colors.white;
}
