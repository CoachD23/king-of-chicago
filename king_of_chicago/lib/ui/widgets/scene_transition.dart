import 'package:flutter/material.dart';

/// A fade transition wrapper for scene changes.
///
/// Uses [AnimatedSwitcher] internally. When the [sceneKey] changes,
/// the old content fades out and the new content fades in over ~500ms.
class SceneTransition extends StatelessWidget {
  /// A unique key representing the current scene (typically the scene ID).
  final String sceneKey;

  /// The child widget to display with fade transitions.
  final Widget child;

  /// Duration of the fade transition.
  final Duration duration;

  const SceneTransition({
    super.key,
    required this.sceneKey,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<String>(sceneKey),
        child: child,
      ),
    );
  }
}
