import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// A horizontal divider: thin gold line with a small diamond in the center.
/// Classic art deco detail.
class GoldDivider extends StatelessWidget {
  final double thickness;
  final double diamondSize;
  final Color color;
  final double verticalPadding;

  const GoldDivider({
    super.key,
    this.thickness = 0.5,
    this.diamondSize = 6.0,
    this.color = GameTheme.goldAccent,
    this.verticalPadding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(height: thickness, color: color.withAlpha(120)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Transform.rotate(
              angle: 0.7854, // 45 degrees in radians
              child: Container(
                width: diamondSize,
                height: diamondSize,
                decoration: BoxDecoration(
                  color: color.withAlpha(180),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(height: thickness, color: color.withAlpha(120)),
          ),
        ],
      ),
    );
  }
}
