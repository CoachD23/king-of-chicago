import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'action/driveby/driveby_game.dart';
import 'action/qte/ambush_game.dart';
import 'action/qte/qte_result.dart';
import 'action/shakedown/shakedown_screen.dart';
import 'action/shootout/shootout_game.dart';
import 'core/veils/veil_provider.dart';
import 'core/veils/veil_type.dart';
import 'narrative/dialogue/dialogue_screen.dart';
import 'narrative/engine/narrative_provider.dart';
import 'ui/theme/game_theme.dart';
import 'ui/widgets/art_deco_border.dart';
import 'ui/widgets/gold_divider.dart';
import 'ui/widgets/grain_overlay.dart';
import 'ui/widgets/scene_transition.dart';

class KingOfChicagoApp extends StatelessWidget {
  const KingOfChicagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King of Chicago',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameTheme.background,
      ),
      home: const GameScreen(),
    );
  }
}

/// Root game screen that loads the first scene and displays dialogue.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Load the intro scene after the first frame.
    Future.microtask(
      () => ref.read(narrativeProvider.notifier).loadScene('intro'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrativeState = ref.watch(narrativeProvider);

    // Feature 4: Error state
    if (narrativeState.error != null) {
      return _buildErrorScreen(narrativeState.error!);
    }

    if (narrativeState.isLoading || narrativeState.currentScene == null) {
      return _buildTitleScreen();
    }

    // Feature 1: Show action screen when pending action exists
    final pendingAction = narrativeState.pendingAction;
    if (pendingAction != null) {
      return _buildActionScreen(
        pendingAction,
        narrativeState.pendingActionConfig,
      );
    }

    // Feature 3: Wrap dialogue in a scene transition
    final sceneId = narrativeState.currentScene!.id;
    return SceneTransition(
      sceneKey: sceneId,
      child: DialogueScreen(
        scene: narrativeState.currentScene!,
        onChoiceSelected: (choice) {
          ref.read(narrativeProvider.notifier).selectChoice(choice);
        },
      ),
    );
  }

  /// Art Deco title screen — movie title card aesthetic.
  Widget _buildTitleScreen() {
    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: Stack(
        children: [
          const GrainOverlay(opacity: 0.04),
          Center(
            child: ArtDecoBorder(
              cornerSize: 28,
              strokeWidth: 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KING OF CHICAGO',
                      style: GameTheme.titleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const GoldDivider(
                      verticalPadding: 12,
                      diamondSize: 5,
                    ),
                    Text(
                      'CHICAGO, 1929',
                      style: GameTheme.subtitleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    const _GoldPulsingDot(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the appropriate action screen based on the pending action type.
  Widget _buildActionScreen(String action, Map<String, dynamic>? config) {
    switch (action) {
      case 'ambush':
        final dreadLevel = (config?['dreadLevel'] as num?)?.toInt() ?? 0;
        return Scaffold(
          backgroundColor: GameTheme.background,
          body: GameWidget(
            game: AmbushGame(
              dreadLevel: dreadLevel,
              onComplete: (QteResult result) => _onAmbushComplete(result),
            ),
          ),
        );
      case 'shootout':
        final veilState = ref.read(veilProvider);
        return Scaffold(
          backgroundColor: GameTheme.background,
          body: GameWidget(
            game: ShootoutGame(
              config: ShootoutConfig(
                dreadLevel: veilState.getValue(VeilType.dread),
                kinshipLevel: veilState.getValue(VeilType.kinship),
                respectLevel: veilState.getValue(VeilType.respect),
              ),
              onComplete: (result) => _onActionComplete(result),
            ),
          ),
        );
      case 'driveby':
        final veilState = ref.read(veilProvider);
        return Scaffold(
          backgroundColor: GameTheme.background,
          body: GameWidget(
            game: DriveByGame(
              config: DriveByConfig(
                dreadLevel: veilState.getValue(VeilType.dread),
                guileLevel: veilState.getValue(VeilType.guile),
                empirLevel: veilState.getValue(VeilType.empire),
              ),
              onComplete: (result) => _onActionComplete(result),
            ),
          ),
        );
      case 'shakedown':
        final targetName = (config?['targetName'] as String?) ?? 'Unknown';
        final targetResistance =
            (config?['targetResistance'] as num?)?.toInt() ?? 60;
        return ShakedownScreen(
          targetName: targetName,
          targetResistance: targetResistance,
          onComplete: (success) => _onShakedownComplete(success),
        );
      default:
        // Unknown action type -- clear and continue
        ref.read(narrativeProvider.notifier).clearPendingAction();
        return const SizedBox.shrink();
    }
  }

  void _onAmbushComplete(QteResult result) => _onActionComplete(result);

  void _onActionComplete(QteResult result) {
    if (result.veilDeltas.isNotEmpty) {
      ref.read(veilProvider.notifier).applyStringDeltas(result.veilDeltas);
    }
    ref.read(narrativeProvider.notifier).clearPendingAction();
  }

  void _onShakedownComplete(bool success) {
    // Apply veil deltas based on shakedown outcome
    final deltas = success
        ? const {'empire': 3, 'respect': 2}
        : const {'respect': -1};
    ref.read(veilProvider.notifier).applyStringDeltas(deltas);
    ref.read(narrativeProvider.notifier).clearPendingAction();
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            const GrainOverlay(opacity: 0.03),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ArtDecoBorder(
                  cornerSize: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: GameTheme.bloodAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SCENE NOT FOUND',
                          style: GameTheme.speakerStyle.copyWith(
                            fontSize: 16,
                            color: GameTheme.goldHighlight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const GoldDivider(
                          verticalPadding: 8,
                          diamondSize: 4,
                        ),
                        Text(
                          errorMessage,
                          style: GameTheme.narratorStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GameTheme.goldAccent,
                            foregroundColor: GameTheme.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          onPressed: () {
                            ref.read(narrativeProvider.notifier).clearError();
                          },
                          child: Text(
                            'RETURN TO LAST SCENE',
                            style: GameTheme.labelStyle.copyWith(
                              color: GameTheme.backgroundColor,
                              fontSize: 12,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pulsing gold dot for the loading screen — replaces the circular spinner.
class _GoldPulsingDot extends StatefulWidget {
  const _GoldPulsingDot();

  @override
  State<_GoldPulsingDot> createState() => _GoldPulsingDotState();
}

class _GoldPulsingDotState extends State<_GoldPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameTheme.goldAccent.withAlpha((_animation.value * 255).toInt()),
            boxShadow: [
              BoxShadow(
                color: GameTheme.goldAccent
                    .withAlpha((_animation.value * 80).toInt()),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
