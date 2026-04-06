import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/save/save_data.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/characters/npc_state.dart';

void main() {
  group('SaveData', () {
    late SaveData saveData;
    late VeilState veilState;
    late NpcState npcState;
    late Map<String, dynamic> storyFlags;

    setUp(() {
      veilState = VeilState.fromMap({
        VeilType.dread: 30,
        VeilType.respect: 50,
        VeilType.sway: 10,
        VeilType.empire: 0,
        VeilType.guile: 75,
        VeilType.legend: 20,
        VeilType.kinship: 45,
      });

      npcState = NpcState.fromMap({
        'tommy': 20,
        'mickey': -15,
        'enzo': 40,
        'rosa': 60,
      });

      storyFlags = {
        'chapter1_complete': true,
        'met_tommy': true,
        'speakeasy_open': false,
        'money_stash': 500,
        'ally_name': 'Enzo',
      };

      saveData = SaveData(
        currentSceneId: 'scene_chapter2_intro',
        veilState: veilState,
        npcState: npcState,
        storyFlags: storyFlags,
        cash: 1500,
      );
    });

    test('is Equatable', () {
      final same = SaveData(
        currentSceneId: 'scene_chapter2_intro',
        veilState: veilState,
        npcState: npcState,
        storyFlags: storyFlags,
        cash: 1500,
      );

      expect(saveData, equals(same));
    });

    test('different values are not equal', () {
      final different = SaveData(
        currentSceneId: 'scene_chapter2_intro',
        veilState: veilState,
        npcState: npcState,
        storyFlags: storyFlags,
        cash: 9999,
      );

      expect(saveData, isNot(equals(different)));
    });

    group('JSON serialization', () {
      test('toJson produces expected structure', () {
        final json = saveData.toJson();

        expect(json['currentSceneId'], equals('scene_chapter2_intro'));
        expect(json['cash'], equals(1500));
        expect(json['storyFlags'], equals(storyFlags));
      });

      test('toJson serializes veils as name-value map', () {
        final json = saveData.toJson();
        final veils = json['veilState'] as Map<String, dynamic>;

        expect(veils['dread'], equals(30));
        expect(veils['respect'], equals(50));
        expect(veils['sway'], equals(10));
        expect(veils['empire'], equals(0));
        expect(veils['guile'], equals(75));
        expect(veils['legend'], equals(20));
        expect(veils['kinship'], equals(45));
      });

      test('toJson serializes NPC relationships as id-value map', () {
        final json = saveData.toJson();
        final npcs = json['npcState'] as Map<String, dynamic>;

        expect(npcs['tommy'], equals(20));
        expect(npcs['mickey'], equals(-15));
        expect(npcs['enzo'], equals(40));
        expect(npcs['rosa'], equals(60));
      });

      test('round-trip: fromJson(toJson(data)) == data', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored, equals(saveData));
      });

      test('round-trip preserves all veil values', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        for (final veil in VeilType.values) {
          expect(
            restored.veilState.getValue(veil),
            equals(saveData.veilState.getValue(veil)),
            reason: 'Veil ${veil.name} mismatch',
          );
        }
      });

      test('round-trip preserves all NPC relationships', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        for (final npcId in ['tommy', 'mickey', 'enzo', 'rosa']) {
          expect(
            restored.npcState.getRelationship(npcId),
            equals(saveData.npcState.getRelationship(npcId)),
            reason: 'NPC $npcId relationship mismatch',
          );
        }
      });

      test('round-trip preserves storyFlags with mixed types', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored.storyFlags['chapter1_complete'], isTrue);
        expect(restored.storyFlags['met_tommy'], isTrue);
        expect(restored.storyFlags['speakeasy_open'], isFalse);
        expect(restored.storyFlags['money_stash'], equals(500));
        expect(restored.storyFlags['ally_name'], equals('Enzo'));
      });

      test('round-trip preserves currentSceneId', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored.currentSceneId, equals('scene_chapter2_intro'));
      });

      test('round-trip preserves cash', () {
        final json = saveData.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored.cash, equals(1500));
      });

      test('handles empty storyFlags', () {
        final emptyFlags = SaveData(
          currentSceneId: 'scene_start',
          veilState: VeilState.initial(),
          npcState: NpcState.fromMap({'tommy': 0}),
          storyFlags: const {},
          cash: 0,
        );

        final json = emptyFlags.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored, equals(emptyFlags));
        expect(restored.storyFlags, isEmpty);
      });

      test('handles zero cash and initial veil state', () {
        final minimal = SaveData(
          currentSceneId: 'scene_start',
          veilState: VeilState.initial(),
          npcState: NpcState.fromMap({'tommy': 0}),
          storyFlags: const {},
          cash: 0,
        );

        final json = minimal.toJson();
        final restored = SaveData.fromJson(json);

        expect(restored, equals(minimal));
        expect(restored.cash, equals(0));
        for (final veil in VeilType.values) {
          expect(restored.veilState.getValue(veil), equals(0));
        }
      });
    });
  });
}
