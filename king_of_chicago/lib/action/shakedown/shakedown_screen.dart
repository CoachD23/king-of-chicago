import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/veils/veil_provider.dart';
import '../../core/veils/veil_state.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/theme/veil_colors.dart';
import 'shakedown_state.dart';

class ShakedownScreen extends ConsumerStatefulWidget {
  final String targetName;
  final int targetResistance;
  final void Function(bool success) onComplete;

  const ShakedownScreen({
    super.key,
    required this.targetName,
    required this.targetResistance,
    required this.onComplete,
  });

  @override
  ConsumerState<ShakedownScreen> createState() => _ShakedownScreenState();
}

class _ShakedownScreenState extends ConsumerState<ShakedownScreen> {
  late ShakedownState _state;

  @override
  void initState() {
    super.initState();
    _state = ShakedownState.initial(targetResistance: widget.targetResistance);
  }

  void _onApproachSelected(ShakedownApproach approach) {
    if (_state.isComplete) return;

    final veils = ref.read(veilProvider);
    setState(() {
      _state = _state.applyPressure(approach, veils);
    });

    if (_state.isComplete) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          widget.onComplete(_state.isSuccess);
        }
      });
    }
  }

  Color _resistanceColor() {
    final ratio = _state.resistance / widget.targetResistance;
    return Color.lerp(
      const Color(0xFFFF8C00),
      const Color(0xFFCC0000),
      ratio,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final veils = ref.watch(veilProvider);

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildResistanceBar(),
              const SizedBox(height: 8),
              _buildTurnsCounter(),
              const SizedBox(height: 24),
              if (_state.isComplete)
                _buildCompletionMessage()
              else
                Expanded(child: _buildApproachButtons(veils)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'THE SHAKEDOWN',
          style: GameTheme.speakerStyle.copyWith(
            fontSize: 18,
            letterSpacing: 4.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.targetName,
          style: GameTheme.dialogueStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResistanceBar() {
    final ratio = _state.resistance / widget.targetResistance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESISTANCE',
          style: GameTheme.locationStyle.copyWith(
            fontSize: 10,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: GameTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(_resistanceColor()),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_state.resistance} / ${widget.targetResistance}',
          style: GameTheme.deltaHintStyle,
        ),
      ],
    );
  }

  Widget _buildTurnsCounter() {
    return Text(
      'Turns remaining: ${_state.turnsRemaining}',
      style: GameTheme.deltaHintStyle.copyWith(fontSize: 13),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCompletionMessage() {
    final success = _state.isSuccess;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? const Color(0xFF228B22) : const Color(0xFFCC0000),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'They broke.' : 'They held firm.',
              style: GameTheme.dialogueStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              success
                  ? 'The mark folded under your pressure.'
                  : 'You ran out of moves. The mark walks away.',
              style: GameTheme.narratorStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproachButtons(VeilState veils) {
    return ListView.separated(
      itemCount: ShakedownApproach.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final approach = ShakedownApproach.values[index];
        final isUsed = _state.usedApproaches.contains(approach);
        final veilValue = veils.getValue(approach.veil);
        final color = VeilColors.getColor(approach.veil);

        return _ApproachButton(
          approach: approach,
          veilValue: veilValue,
          color: color,
          isUsed: isUsed,
          onTap: () => _onApproachSelected(approach),
        );
      },
    );
  }
}

class _ApproachButton extends StatelessWidget {
  final ShakedownApproach approach;
  final int veilValue;
  final Color color;
  final bool isUsed;
  final VoidCallback onTap;

  const _ApproachButton({
    required this.approach,
    required this.veilValue,
    required this.color,
    required this.isUsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = isUsed ? 0.5 : 1.0;

    return Opacity(
      opacity: effectiveOpacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withOpacity(isUsed ? 0.3 : 0.7),
              ),
              borderRadius: BorderRadius.circular(8),
              color: color.withOpacity(0.08),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      approach.veil.displayName[0],
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            approach.label,
                            style: GameTheme.choiceStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          if (isUsed) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(USED -50%)',
                              style: GameTheme.deltaHintStyle.copyWith(
                                color: const Color(0xFFCC0000),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        approach.description,
                        style: GameTheme.deltaHintStyle,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$veilValue',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
