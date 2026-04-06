import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'action/qte/ambush_game.dart';
import 'action/qte/qte_result.dart';
import 'action/shakedown/shakedown_screen.dart';
import 'core/veils/veil_provider.dart';
import 'narrative/dialogue/dialogue_screen.dart';
import 'narrative/engine/narrative_provider.dart';
import 'ui/theme/game_theme.dart';
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
      return const Scaffold(
        backgroundColor: GameTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('KING OF CHICAGO', style: GameTheme.titleStyle),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: GameTheme.accent,
              ),
            ],
          ),
        ),
      );
    }

    // Feature 1: Show action screen when pending action exists
    final pendingAction = narrativeState.pendingAction;
    if (pendingAction != null) {
      return _buildActionScreen(pendingAction, narrativeState.pendingActionConfig);
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

  void _onAmbushComplete(QteResult result) {
    // Apply veil deltas from the QTE result
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: GameTheme.danger,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scene Not Found',
                  style: GameTheme.titleStyle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: GameTheme.narratorStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameTheme.accent,
                    foregroundColor: GameTheme.background,
                  ),
                  onPressed: () {
                    ref.read(narrativeProvider.notifier).clearError();
                  },
                  child: const Text('Return to last scene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
