import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/theme/game_theme.dart';
import '../../ui/widgets/art_deco_border.dart';
import '../../ui/widgets/gold_divider.dart';
import 'save_data.dart';
import 'save_manager.dart';

/// A screen displaying 3 save slots with Art Deco styling.
///
/// Each slot shows save metadata (scene, dominant veil, cash, date) when
/// occupied, or "EMPTY" when vacant. Supports save, load, and delete actions.
class SaveScreen extends StatefulWidget {
  /// If true, shows a "SAVE" button on each slot (in-game context).
  final bool allowSave;

  /// Called when the user taps "LOAD" on a populated slot.
  final void Function(SaveData data)? onLoad;

  /// Called to build a [SaveData] snapshot for saving.
  final SaveData Function()? buildSaveData;

  const SaveScreen({
    super.key,
    this.allowSave = false,
    this.onLoad,
    this.buildSaveData,
  });

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  static const _slotCount = 3;
  static const _slotLabels = ['SAVE I', 'SAVE II', 'SAVE III'];

  final List<SaveData?> _slots = List.filled(_slotCount, null);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSlots();
  }

  Future<void> _loadAllSlots() async {
    final results = await Future.wait([
      for (int i = 0; i < _slotCount; i++) SaveManager.load(slot: i),
    ]);
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _slotCount; i++) {
        _slots[i] = results[i];
      }
      _loading = false;
    });
  }

  Future<void> _saveToSlot(int slot) async {
    final data = widget.buildSaveData?.call();
    if (data == null) return;
    await SaveManager.save(data, slot: slot);
    if (!mounted) return;
    setState(() => _slots[slot] = data);
  }

  Future<void> _deleteSlot(int slot) async {
    await SaveManager.deleteSave(slot: slot);
    if (!mounted) return;
    setState(() => _slots[slot] = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: GameTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GameTheme.goldAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SAVE FILES',
          style: GoogleFonts.playfairDisplay(
            color: GameTheme.goldAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: GameTheme.goldAccent),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const GoldDivider(verticalPadding: 4, diamondSize: 5),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _slotCount; i++) ...[
                    _buildSlotCard(i),
                    if (i < _slotCount - 1) const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSlotCard(int slot) {
    final data = _slots[slot];
    final isOccupied = data != null;

    return ArtDecoBorder(
      cornerSize: 20,
      strokeWidth: 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.surface,
          border: Border.all(color: GameTheme.smoke, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slot header
            Text(
              _slotLabels[slot],
              style: GameTheme.speakerStyle.copyWith(
                fontSize: 14,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            const GoldDivider(verticalPadding: 4, diamondSize: 3),
            const SizedBox(height: 8),

            if (isOccupied) _buildOccupiedContent(data) else _buildEmptyContent(),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.allowSave)
                  _buildActionButton(
                    label: 'SAVE',
                    icon: Icons.save_outlined,
                    onPressed: () => _saveToSlot(slot),
                  ),
                if (widget.allowSave && isOccupied) const SizedBox(width: 8),
                if (isOccupied)
                  _buildActionButton(
                    label: 'LOAD',
                    icon: Icons.upload_outlined,
                    onPressed: () {
                      widget.onLoad?.call(data);
                      Navigator.of(context).pop();
                    },
                  ),
                if (isOccupied) const SizedBox(width: 8),
                if (isOccupied)
                  _buildActionButton(
                    label: 'DELETE',
                    icon: Icons.delete_outline,
                    color: GameTheme.bloodAccent,
                    onPressed: () => _confirmDelete(slot),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupiedContent(SaveData data) {
    final dominantVeil = data.veilState.getDominantVeils(1).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scene name
        Text(
          data.currentSceneId.toUpperCase().replaceAll('_', ' '),
          style: GameTheme.dialogueStyle.copyWith(
            fontSize: 14,
            color: GameTheme.parchment,
          ),
        ),
        const SizedBox(height: 6),
        // Dominant veil + cash
        Row(
          children: [
            _buildInfoChip(dominantVeil.displayName, GameTheme.goldAccent),
            const SizedBox(width: 12),
            _buildInfoChip('\$${data.cash}', GameTheme.goldHighlight),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Text(
      'EMPTY',
      style: GameTheme.labelStyle.copyWith(
        color: GameTheme.ash,
        fontSize: 14,
        letterSpacing: 6.0,
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(80), width: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: GameTheme.labelStyle.copyWith(
          color: color,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = GameTheme.goldAccent,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(120), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GameTheme.labelStyle.copyWith(
                color: color,
                fontSize: 9,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameTheme.surface,
        title: Text(
          'DELETE ${_slotLabels[slot]}?',
          style: GameTheme.speakerStyle.copyWith(fontSize: 14),
        ),
        content: Text(
          'This cannot be undone.',
          style: GameTheme.narratorStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: GameTheme.labelStyle.copyWith(
                color: GameTheme.ash,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'DELETE',
              style: GameTheme.labelStyle.copyWith(
                color: GameTheme.bloodAccent,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteSlot(slot);
    }
  }
}
