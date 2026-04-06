import 'package:flutter/material.dart';

import '../../core/veils/veil_type.dart';

class VeilColors {
  VeilColors._();

  static const Map<VeilType, Color> primary = {
    VeilType.dread: Color(0xFFCC0000),
    VeilType.respect: Color(0xFFD4AF37),
    VeilType.sway: Color(0xFF4169E1),
    VeilType.empire: Color(0xFF228B22),
    VeilType.guile: Color(0xFF8B008B),
    VeilType.legend: Color(0xFFFF8C00),
    VeilType.kinship: Color(0xFF8B4513),
  };

  static Color getColor(VeilType veil) => primary[veil] ?? Colors.white;
}
