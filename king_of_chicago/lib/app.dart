import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'narrative/dialogue/dialogue_screen.dart';
import 'narrative/engine/narrative_provider.dart';
import 'ui/theme/game_theme.dart';

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

    if (narrativeState.isLoading || narrativeState.currentScene == null) {
      return Scaffold(
        backgroundColor: GameTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('KING OF CHICAGO', style: GameTheme.titleStyle),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: GameTheme.accent,
              ),
            ],
          ),
        ),
      );
    }

    return DialogueScreen(
      scene: narrativeState.currentScene!,
      onChoiceSelected: (choice) {
        ref.read(narrativeProvider.notifier).selectChoice(choice);
      },
    );
  }
}
