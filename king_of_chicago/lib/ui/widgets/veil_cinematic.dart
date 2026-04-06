import 'package:flutter/material.dart';

import '../../core/veils/veil_type.dart';
import '../theme/game_theme.dart';
import '../theme/veil_colors.dart';

class VeilCinematic extends StatefulWidget {
  final VeilType veil;
  final String message;
  final VoidCallback onComplete;

  const VeilCinematic({
    super.key,
    required this.veil,
    required this.message,
    required this.onComplete,
  });

  @override
  State<VeilCinematic> createState() => _VeilCinematicState();
}

class _VeilCinematicState extends State<VeilCinematic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = VeilColors.getGlow(widget.veil);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Background: fades in 0-0.4, holds, fades out 0.7-1.0
        final bgOpacity = t < 0.4
            ? (t / 0.4) * 0.4
            : t > 0.7
                ? (1.0 - t) / 0.3 * 0.4
                : 0.4;
        // Text: fades in 0.3-0.5, holds, fades out 0.7-1.0
        final textOpacity = t < 0.3
            ? 0.0
            : t < 0.5
                ? ((t - 0.3) / 0.2)
                : t > 0.7
                    ? ((1.0 - t) / 0.3)
                    : 1.0;

        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Veil color wash
              Container(
                color: color.withOpacity(bgOpacity.clamp(0.0, 1.0)),
              ),
              // Message
              Center(
                child: Opacity(
                  opacity: textOpacity.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.veil.displayName.toUpperCase(),
                        style: GameTheme.labelStyle.copyWith(
                          color: color,
                          fontSize: 14,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.message,
                        style: GameTheme.titleStyle.copyWith(
                          color: GameTheme.parchment,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
