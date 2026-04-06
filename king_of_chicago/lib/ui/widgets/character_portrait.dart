import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Displays a character's pixel art portrait next to their name.
///
/// Maps speaker names to portrait asset files. Shows a small 32x32
/// portrait with a thin gold border in the Art Deco noir style.
class CharacterPortrait extends StatelessWidget {
  final String speaker;
  final double size;

  const CharacterPortrait({
    super.key,
    required this.speaker,
    this.size = 32,
  });

  static const Map<String, String> _speakerToAsset = {
    'vince': 'assets/portraits/vince.png',
    'vincenzo': 'assets/portraits/vince.png',
    'enzo': 'assets/portraits/enzo.png',
    'tommy': 'assets/portraits/tommy.png',
    'rosa': 'assets/portraits/rosa.png',
    'mickey': 'assets/portraits/mickey.png',
    'narrator': 'assets/portraits/narrator.png',
  };

  String? _resolveAsset() {
    final key = speaker.toLowerCase().trim();
    return _speakerToAsset[key];
  }

  @override
  Widget build(BuildContext context) {
    final asset = _resolveAsset();

    if (asset == null) {
      return SizedBox(width: size, height: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: GameTheme.goldAccent.withAlpha(100),
          width: 0.5,
        ),
      ),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, __, ___) => SizedBox(
          width: size,
          height: size,
        ),
      ),
    );
  }
}
