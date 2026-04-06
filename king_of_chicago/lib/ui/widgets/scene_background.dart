import 'package:flutter/material.dart';

/// Displays a location background image behind scene content.
///
/// Maps location names from scene YAML to background asset files.
/// Falls back to a dark gradient when no matching background exists.
class SceneBackground extends StatelessWidget {
  final String location;
  final Widget child;

  const SceneBackground({
    super.key,
    required this.location,
    required this.child,
  });

  static const Map<String, String> _locationToAsset = {
    'south side': 'assets/backgrounds/south_side.png',
    'south_side': 'assets/backgrounds/south_side.png',
    'little italy': 'assets/backgrounds/little_italy.png',
    'little_italy': 'assets/backgrounds/little_italy.png',
    'the loop': 'assets/backgrounds/the_loop.png',
    'the_loop': 'assets/backgrounds/the_loop.png',
    'loop': 'assets/backgrounds/the_loop.png',
    'north side': 'assets/backgrounds/north_side.png',
    'north_side': 'assets/backgrounds/north_side.png',
    'west side': 'assets/backgrounds/west_side.png',
    'west_side': 'assets/backgrounds/west_side.png',
    'stockyards': 'assets/backgrounds/stockyards.png',
    'stock yards': 'assets/backgrounds/stockyards.png',
    'gold coast': 'assets/backgrounds/gold_coast.png',
    'gold_coast': 'assets/backgrounds/gold_coast.png',
    'levee district': 'assets/backgrounds/levee_district.png',
    'levee_district': 'assets/backgrounds/levee_district.png',
    'levee': 'assets/backgrounds/levee_district.png',
  };

  String? _resolveAsset() {
    final key = location.toLowerCase().trim();
    return _locationToAsset[key];
  }

  @override
  Widget build(BuildContext context) {
    final asset = _resolveAsset();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (asset != null)
          Positioned.fill(
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        child,
      ],
    );
  }
}
