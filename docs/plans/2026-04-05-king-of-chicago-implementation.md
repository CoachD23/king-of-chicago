# King of Chicago — MVP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the Phase 1 MVP — Act 1 ("The Pilot Episode") with the Seven Veils engine, narrative system, dialogue wheel, 3 territories, Ambush QTE, Shakedown mini-game, and 4 NPCs.

**Architecture:** Flutter app with Flame engine for action sequences. Riverpod for immutable state management. Data-driven narrative engine parsing YAML scene files. Hive for local save persistence.

**Tech Stack:** Flutter 3.x, Flame 1.x, Riverpod 2.x (NotifierProvider pattern), Hive 4.x, yaml package, path_provider

---

## Task 1: Flutter Project Scaffold

**Files:**
- Create: `king_of_chicago/` (Flutter project root)
- Create: `king_of_chicago/pubspec.yaml`
- Create: `king_of_chicago/lib/main.dart`
- Create: `king_of_chicago/lib/app.dart`

**Step 1: Create Flutter project**

Run:
```bash
cd "/Users/fcp/King of chicago"
flutter create king_of_chicago --org com.kingofchicago --platforms ios,android
```

Expected: Project created with standard Flutter structure.

**Step 2: Add dependencies to pubspec.yaml**

Replace the `dependencies` and `dev_dependencies` sections in `king_of_chicago/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.22.0
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  hive: ^4.0.0
  isar_flutter_libs: ^4.0.0-dev.13
  path_provider: ^2.0.0
  yaml: ^3.1.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.2
  mocktail: ^1.0.4
```

**Step 3: Install dependencies**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter pub get
```

Expected: All packages resolved successfully.

**Step 4: Create app shell**

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KingOfChicagoApp extends StatelessWidget {
  const KingOfChicagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King of Chicago',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'King of Chicago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
```

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: KingOfChicagoApp(),
    ),
  );
}
```

**Step 5: Verify build**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter analyze
```

Expected: No issues found.

**Step 6: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/
git commit -m "feat: scaffold Flutter project with Flame, Riverpod, and Hive dependencies"
```

---

## Task 2: Seven Veils Engine (Core State)

**Files:**
- Create: `lib/core/veils/veil_type.dart`
- Create: `lib/core/veils/veil_state.dart`
- Create: `lib/core/veils/veil_engine.dart`
- Create: `lib/core/veils/veil_provider.dart`
- Test: `test/core/veils/veil_engine_test.dart`
- Test: `test/core/veils/veil_state_test.dart`

**Step 1: Write failing tests for VeilState**

Create `test/core/veils/veil_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';

void main() {
  group('VeilState', () {
    test('initial state has all veils at 0', () {
      final state = VeilState.initial();
      for (final veil in VeilType.values) {
        expect(state.getValue(veil), 0);
      }
    });

    test('applying deltas returns new state without mutation', () {
      final state = VeilState.initial();
      final updated = state.applyDeltas({VeilType.dread: 5, VeilType.respect: -2});

      expect(updated.getValue(VeilType.dread), 5);
      expect(updated.getValue(VeilType.respect), 0); // clamped at 0
      expect(state.getValue(VeilType.dread), 0); // original unchanged
    });

    test('veils are clamped between 0 and 100', () {
      final state = VeilState.initial();
      final overMax = state.applyDeltas({VeilType.dread: 150});
      expect(overMax.getValue(VeilType.dread), 100);

      final underMin = state.applyDeltas({VeilType.empire: -50});
      expect(underMin.getValue(VeilType.empire), 0);
    });

    test('getDominantVeils returns top N veils sorted descending', () {
      final state = VeilState.initial().applyDeltas({
        VeilType.dread: 80,
        VeilType.legend: 60,
        VeilType.guile: 40,
        VeilType.kinship: 20,
      });
      final top3 = state.getDominantVeils(3);
      expect(top3, [VeilType.dread, VeilType.legend, VeilType.guile]);
    });

    test('meetsThreshold checks if veil meets minimum value', () {
      final state = VeilState.initial().applyDeltas({VeilType.sway: 65});
      expect(state.meetsThreshold(VeilType.sway, 60), true);
      expect(state.meetsThreshold(VeilType.sway, 70), false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/veils/veil_state_test.dart
```

Expected: FAIL — files don't exist yet.

**Step 3: Implement VeilType enum**

Create `lib/core/veils/veil_type.dart`:

```dart
enum VeilType {
  dread('Dread', 'The Monster', '🔴'),
  respect('Respect', 'The Honorable', '🤝'),
  sway('Sway', 'The Puppeteer', '⚖️'),
  empire('Empire', 'The Mogul', '💰'),
  guile('Guile', 'The Chessmaster', '♟️'),
  legend('Legend', 'The Icon', '📰'),
  kinship('Kinship', 'The Patriarch', '👨‍👩‍👧‍👦');

  const VeilType(this.displayName, this.fantasy, this.icon);

  final String displayName;
  final String fantasy;
  final String icon;
}
```

**Step 4: Implement VeilState (immutable)**

Create `lib/core/veils/veil_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'veil_type.dart';

class VeilState extends Equatable {
  final Map<VeilType, int> _values;

  const VeilState._(this._values);

  factory VeilState.initial() {
    return VeilState._(
      Map.fromEntries(VeilType.values.map((v) => MapEntry(v, 0))),
    );
  }

  factory VeilState.fromMap(Map<VeilType, int> values) {
    final clamped = Map.fromEntries(
      VeilType.values.map((v) => MapEntry(v, (values[v] ?? 0).clamp(0, 100))),
    );
    return VeilState._(clamped);
  }

  int getValue(VeilType veil) => _values[veil] ?? 0;

  VeilState applyDeltas(Map<VeilType, int> deltas) {
    final newValues = Map<VeilType, int>.from(_values);
    for (final entry in deltas.entries) {
      final current = newValues[entry.key] ?? 0;
      newValues[entry.key] = (current + entry.value).clamp(0, 100);
    }
    return VeilState._(newValues);
  }

  List<VeilType> getDominantVeils(int count) {
    final sorted = VeilType.values.toList()
      ..sort((a, b) => getValue(b).compareTo(getValue(a)));
    return sorted.take(count).toList();
  }

  bool meetsThreshold(VeilType veil, int threshold) {
    return getValue(veil) >= threshold;
  }

  Map<VeilType, int> toMap() => Map.unmodifiable(_values);

  @override
  List<Object?> get props => [_values];
}
```

**Step 5: Run tests to verify they pass**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/veils/veil_state_test.dart
```

Expected: All tests PASS.

**Step 6: Write failing tests for VeilEngine**

Create `test/core/veils/veil_engine_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_engine.dart';

void main() {
  group('VeilEngine', () {
    test('applyChoice applies veil deltas from a choice map', () {
      final state = VeilState.initial();
      final result = VeilEngine.applyChoice(
        state,
        {'dread': 3, 'respect': 1},
      );
      expect(result.getValue(VeilType.dread), 3);
      expect(result.getValue(VeilType.respect), 1);
    });

    test('applyChoice ignores unknown veil names', () {
      final state = VeilState.initial();
      final result = VeilEngine.applyChoice(
        state,
        {'dread': 5, 'nonsense': 10},
      );
      expect(result.getValue(VeilType.dread), 5);
    });

    test('isChoiceAvailable checks threshold requirements', () {
      final state = VeilState.initial().applyDeltas({VeilType.sway: 65});
      expect(
        VeilEngine.isChoiceAvailable(state, {'sway': 60}),
        true,
      );
      expect(
        VeilEngine.isChoiceAvailable(state, {'sway': 70}),
        false,
      );
      expect(
        VeilEngine.isChoiceAvailable(state, null),
        true,
      );
    });
  });
}
```

**Step 7: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/veils/veil_engine_test.dart
```

Expected: FAIL — VeilEngine doesn't exist yet.

**Step 8: Implement VeilEngine**

Create `lib/core/veils/veil_engine.dart`:

```dart
import 'veil_state.dart';
import 'veil_type.dart';

class VeilEngine {
  const VeilEngine._();

  static final _nameToType = {
    for (final veil in VeilType.values) veil.name: veil,
  };

  static VeilState applyChoice(
    VeilState state,
    Map<String, int> veilDeltas,
  ) {
    final typedDeltas = <VeilType, int>{};
    for (final entry in veilDeltas.entries) {
      final type = _nameToType[entry.key];
      if (type != null) {
        typedDeltas[type] = entry.value;
      }
    }
    return state.applyDeltas(typedDeltas);
  }

  static bool isChoiceAvailable(
    VeilState state,
    Map<String, int>? requirements,
  ) {
    if (requirements == null || requirements.isEmpty) return true;
    for (final entry in requirements.entries) {
      final type = _nameToType[entry.key];
      if (type != null && !state.meetsThreshold(type, entry.value)) {
        return false;
      }
    }
    return true;
  }
}
```

**Step 9: Run all veil tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/veils/
```

Expected: All tests PASS.

**Step 10: Create Riverpod provider**

Create `lib/core/veils/veil_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'veil_state.dart';
import 'veil_type.dart';

class VeilNotifier extends Notifier<VeilState> {
  @override
  VeilState build() => VeilState.initial();

  void applyDeltas(Map<VeilType, int> deltas) {
    state = state.applyDeltas(deltas);
  }

  void applyStringDeltas(Map<String, int> deltas) {
    final typedDeltas = <VeilType, int>{};
    for (final entry in deltas.entries) {
      try {
        final type = VeilType.values.firstWhere((v) => v.name == entry.key);
        typedDeltas[type] = entry.value;
      } catch (_) {
        // ignore unknown veil names
      }
    }
    state = state.applyDeltas(typedDeltas);
  }

  void reset() {
    state = VeilState.initial();
  }
}

final veilProvider = NotifierProvider<VeilNotifier, VeilState>(
  VeilNotifier.new,
);
```

**Step 11: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/core/veils/ king_of_chicago/test/core/veils/
git commit -m "feat: implement Seven Veils engine with immutable state and TDD tests"
```

---

## Task 3: NPC Relationship System

**Files:**
- Create: `lib/core/characters/npc.dart`
- Create: `lib/core/characters/npc_state.dart`
- Create: `lib/core/characters/npc_provider.dart`
- Test: `test/core/characters/npc_state_test.dart`

**Step 1: Write failing test**

Create `test/core/characters/npc_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/characters/npc.dart';
import 'package:king_of_chicago/core/characters/npc_state.dart';

void main() {
  group('NpcState', () {
    test('initial state creates all MVP NPCs at relationship 0', () {
      final state = NpcState.initial();
      expect(state.getRelationship('mickey'), 0);
      expect(state.getRelationship('enzo'), 0);
      expect(state.getRelationship('tommy'), 0);
      expect(state.getRelationship('rosa'), 0);
    });

    test('applyDelta returns new state with updated relationship', () {
      final state = NpcState.initial();
      final updated = state.applyDelta('tommy', 15);
      expect(updated.getRelationship('tommy'), 15);
      expect(state.getRelationship('tommy'), 0); // original unchanged
    });

    test('relationships are clamped between -100 and 100', () {
      final state = NpcState.initial();
      final over = state.applyDelta('mickey', 150);
      expect(over.getRelationship('mickey'), 100);

      final under = state.applyDelta('mickey', -150);
      expect(under.getRelationship('mickey'), -100);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/characters/npc_state_test.dart
```

Expected: FAIL.

**Step 3: Implement NPC data and state**

Create `lib/core/characters/npc.dart`:

```dart
class Npc {
  final String id;
  final String name;
  final String role;
  final String territoryAnchor;

  const Npc({
    required this.id,
    required this.name,
    required this.role,
    required this.territoryAnchor,
  });

  static const List<Npc> mvpNpcs = [
    Npc(id: 'mickey', name: 'Mickey O\'Banion', role: 'Rival', territoryAnchor: 'north_side'),
    Npc(id: 'enzo', name: 'Enzo "The Barber" Castellano', role: 'Mentor', territoryAnchor: 'little_italy'),
    Npc(id: 'tommy', name: 'Tommy "Two-Tone" Rizzo', role: 'Right Hand', territoryAnchor: 'south_side'),
    Npc(id: 'rosa', name: 'Rosa Moretti', role: 'Sister', territoryAnchor: 'little_italy'),
  ];
}
```

Create `lib/core/characters/npc_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'npc.dart';

class NpcState extends Equatable {
  final Map<String, int> _relationships;

  const NpcState._(this._relationships);

  factory NpcState.initial() {
    return NpcState._(
      Map.fromEntries(Npc.mvpNpcs.map((npc) => MapEntry(npc.id, 0))),
    );
  }

  factory NpcState.fromMap(Map<String, int> relationships) {
    final clamped = relationships.map(
      (key, value) => MapEntry(key, value.clamp(-100, 100)),
    );
    return NpcState._(clamped);
  }

  int getRelationship(String npcId) => _relationships[npcId] ?? 0;

  NpcState applyDelta(String npcId, int delta) {
    final newRelationships = Map<String, int>.from(_relationships);
    final current = newRelationships[npcId] ?? 0;
    newRelationships[npcId] = (current + delta).clamp(-100, 100);
    return NpcState._(newRelationships);
  }

  Map<String, int> toMap() => Map.unmodifiable(_relationships);

  @override
  List<Object?> get props => [_relationships];
}
```

Create `lib/core/characters/npc_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'npc_state.dart';

class NpcNotifier extends Notifier<NpcState> {
  @override
  NpcState build() => NpcState.initial();

  void applyDelta(String npcId, int delta) {
    state = state.applyDelta(npcId, delta);
  }

  void reset() {
    state = NpcState.initial();
  }
}

final npcProvider = NotifierProvider<NpcNotifier, NpcState>(
  NpcNotifier.new,
);
```

**Step 4: Run tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/characters/npc_state_test.dart
```

Expected: All tests PASS.

**Step 5: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/core/characters/ king_of_chicago/test/core/characters/
git commit -m "feat: implement NPC relationship system with immutable state"
```

---

## Task 4: Territory & Empire State

**Files:**
- Create: `lib/empire/territory/territory.dart`
- Create: `lib/empire/territory/territory_state.dart`
- Create: `lib/empire/territory/territory_provider.dart`
- Test: `test/empire/territory/territory_state_test.dart`

**Step 1: Write failing tests**

Create `test/empire/territory/territory_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/empire/territory/territory.dart';
import 'package:king_of_chicago/empire/territory/territory_state.dart';

void main() {
  group('TerritoryState', () {
    test('initial MVP state has 3 territories', () {
      final state = TerritoryState.mvpInitial();
      expect(state.territories.length, 3);
    });

    test('can assign a capo to a territory', () {
      final state = TerritoryState.mvpInitial();
      final updated = state.assignCapo('south_side', 'tommy');
      expect(updated.getTerritory('south_side').assignedCapo, 'tommy');
      expect(state.getTerritory('south_side').assignedCapo, isNull); // original unchanged
    });

    test('heat increases and is clamped 0-100', () {
      final state = TerritoryState.mvpInitial();
      final updated = state.addHeat('the_loop', 30);
      expect(updated.getTerritory('the_loop').heat, 30);

      final over = updated.addHeat('the_loop', 200);
      expect(over.getTerritory('the_loop').heat, 100);
    });

    test('income is calculated from controlled territories', () {
      final state = TerritoryState.mvpInitial();
      final controlled = state.assignCapo('south_side', 'tommy');
      expect(controlled.totalIncome(), greaterThan(0));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/empire/territory/territory_state_test.dart
```

Expected: FAIL.

**Step 3: Implement Territory and TerritoryState**

Create `lib/empire/territory/territory.dart`:

```dart
import 'package:equatable/equatable.dart';

class Territory extends Equatable {
  final String id;
  final String name;
  final String character;
  final String primaryRacket;
  final int baseIncome;
  final int heat;
  final String? assignedCapo;
  final bool isActive;

  const Territory({
    required this.id,
    required this.name,
    required this.character,
    required this.primaryRacket,
    required this.baseIncome,
    this.heat = 0,
    this.assignedCapo,
    this.isActive = true,
  });

  Territory copyWith({
    int? heat,
    String? assignedCapo,
    bool? isActive,
  }) {
    return Territory(
      id: id,
      name: name,
      character: character,
      primaryRacket: primaryRacket,
      baseIncome: baseIncome,
      heat: heat ?? this.heat,
      assignedCapo: assignedCapo ?? this.assignedCapo,
      isActive: isActive ?? this.isActive,
    );
  }

  int get effectiveIncome => assignedCapo != null ? baseIncome : 0;

  static const List<Territory> mvpTerritories = [
    Territory(
      id: 'south_side',
      name: 'South Side',
      character: 'Castellano family home turf',
      primaryRacket: 'Bootlegging, distilleries',
      baseIncome: 500,
    ),
    Territory(
      id: 'little_italy',
      name: 'Little Italy',
      character: 'Immigrant community, your roots',
      primaryRacket: 'Loan sharking & community',
      baseIncome: 200,
    ),
    Territory(
      id: 'the_loop',
      name: 'The Loop',
      character: 'Downtown power center',
      primaryRacket: 'Gambling halls, speakeasies',
      baseIncome: 800,
    ),
  ];

  @override
  List<Object?> get props => [id, name, heat, assignedCapo, isActive];
}
```

Create `lib/empire/territory/territory_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'territory.dart';

class TerritoryState extends Equatable {
  final List<Territory> territories;

  const TerritoryState._(this.territories);

  factory TerritoryState.mvpInitial() {
    return TerritoryState._(Territory.mvpTerritories);
  }

  Territory getTerritory(String id) {
    return territories.firstWhere((t) => t.id == id);
  }

  TerritoryState assignCapo(String territoryId, String capoId) {
    final updated = territories.map((t) {
      if (t.id == territoryId) return t.copyWith(assignedCapo: capoId);
      return t;
    }).toList();
    return TerritoryState._(updated);
  }

  TerritoryState addHeat(String territoryId, int amount) {
    final updated = territories.map((t) {
      if (t.id == territoryId) {
        return t.copyWith(heat: (t.heat + amount).clamp(0, 100));
      }
      return t;
    }).toList();
    return TerritoryState._(updated);
  }

  int totalIncome() {
    return territories.fold(0, (sum, t) => sum + t.effectiveIncome);
  }

  @override
  List<Object?> get props => [territories];
}
```

Create `lib/empire/territory/territory_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'territory_state.dart';

class TerritoryNotifier extends Notifier<TerritoryState> {
  @override
  TerritoryState build() => TerritoryState.mvpInitial();

  void assignCapo(String territoryId, String capoId) {
    state = state.assignCapo(territoryId, capoId);
  }

  void addHeat(String territoryId, int amount) {
    state = state.addHeat(territoryId, amount);
  }
}

final territoryProvider = NotifierProvider<TerritoryNotifier, TerritoryState>(
  TerritoryNotifier.new,
);
```

**Step 4: Run tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/empire/territory/territory_state_test.dart
```

Expected: All tests PASS.

**Step 5: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/empire/ king_of_chicago/test/empire/
git commit -m "feat: implement territory and empire state with 3 MVP territories"
```

---

## Task 5: Narrative Engine (YAML Scene Parser)

**Files:**
- Create: `lib/narrative/engine/scene.dart`
- Create: `lib/narrative/engine/scene_parser.dart`
- Create: `lib/narrative/engine/narrative_engine.dart`
- Create: `lib/narrative/engine/narrative_provider.dart`
- Create: `assets/story/act1/intro.yaml`
- Test: `test/narrative/engine/scene_parser_test.dart`
- Test: `test/narrative/engine/narrative_engine_test.dart`

**Step 1: Write failing test for scene parsing**

Create `test/narrative/engine/scene_parser_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/narrative/engine/scene.dart';
import 'package:king_of_chicago/narrative/engine/scene_parser.dart';

const testYaml = '''
scene: test_scene
location: little_italy
characters:
  - sal
  - vince
mood: tense
dialogue:
  - speaker: sal
    line: "The O'Banion boys came by yesterday."
choices:
  - id: threaten
    line: "I'll nail their heads to your door."
    veils:
      dread: 3
      respect: 1
    heat:
      little_italy: 2
    next: sal_relieved
  - id: protect
    line: "Sal, you're family."
    veils:
      kinship: 3
      empire: -1
    next: sal_grateful
  - id: power_move
    line: "I already bought their boss."
    requires:
      sway: 60
    veils:
      guile: 3
      legend: 1
    next: sal_stunned
''';

void main() {
  group('SceneParser', () {
    test('parses a valid YAML scene', () {
      final scene = SceneParser.parseFromString(testYaml);
      expect(scene.id, 'test_scene');
      expect(scene.location, 'little_italy');
      expect(scene.characters, ['sal', 'vince']);
      expect(scene.mood, 'tense');
    });

    test('parses dialogue lines', () {
      final scene = SceneParser.parseFromString(testYaml);
      expect(scene.dialogue.length, 1);
      expect(scene.dialogue.first.speaker, 'sal');
      expect(scene.dialogue.first.line, contains('O\'Banion'));
    });

    test('parses choices with veils and requirements', () {
      final scene = SceneParser.parseFromString(testYaml);
      expect(scene.choices.length, 3);

      final threaten = scene.choices.firstWhere((c) => c.id == 'threaten');
      expect(threaten.veils['dread'], 3);
      expect(threaten.heat?['little_italy'], 2);
      expect(threaten.next, 'sal_relieved');

      final powerMove = scene.choices.firstWhere((c) => c.id == 'power_move');
      expect(powerMove.requires?['sway'], 60);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/narrative/engine/scene_parser_test.dart
```

Expected: FAIL.

**Step 3: Implement Scene data model**

Create `lib/narrative/engine/scene.dart`:

```dart
import 'package:equatable/equatable.dart';

class DialogueLine extends Equatable {
  final String speaker;
  final String line;

  const DialogueLine({required this.speaker, required this.line});

  @override
  List<Object?> get props => [speaker, line];
}

class Choice extends Equatable {
  final String id;
  final String line;
  final Map<String, int> veils;
  final Map<String, int>? heat;
  final Map<String, int>? requires;
  final Map<String, int>? npcDeltas;
  final String next;
  final bool hidden;

  const Choice({
    required this.id,
    required this.line,
    required this.veils,
    this.heat,
    this.requires,
    this.npcDeltas,
    required this.next,
    this.hidden = false,
  });

  @override
  List<Object?> get props => [id, line, veils, heat, requires, next, hidden];
}

class Scene extends Equatable {
  final String id;
  final String location;
  final List<String> characters;
  final String mood;
  final List<DialogueLine> dialogue;
  final List<Choice> choices;
  final String? type; // river, rapids, tributary, falls

  const Scene({
    required this.id,
    required this.location,
    required this.characters,
    required this.mood,
    required this.dialogue,
    required this.choices,
    this.type,
  });

  @override
  List<Object?> get props => [id, location, characters, mood, dialogue, choices, type];
}
```

**Step 4: Implement SceneParser**

Create `lib/narrative/engine/scene_parser.dart`:

```dart
import 'package:yaml/yaml.dart';
import 'scene.dart';

class SceneParser {
  const SceneParser._();

  static Scene parseFromString(String yamlString) {
    final doc = loadYaml(yamlString) as YamlMap;
    return _parseScene(doc);
  }

  static Scene _parseScene(YamlMap map) {
    final dialogue = (map['dialogue'] as YamlList?)?.map((d) {
      final dm = d as YamlMap;
      return DialogueLine(
        speaker: dm['speaker'] as String,
        line: dm['line'] as String,
      );
    }).toList() ?? [];

    final choices = (map['choices'] as YamlList?)?.map((c) {
      final cm = c as YamlMap;
      return Choice(
        id: cm['id'] as String,
        line: cm['line'] as String,
        veils: _parseIntMap(cm['veils'] as YamlMap?),
        heat: cm['heat'] != null ? _parseIntMap(cm['heat'] as YamlMap) : null,
        requires: cm['requires'] != null ? _parseIntMap(cm['requires'] as YamlMap) : null,
        npcDeltas: cm['npc_deltas'] != null ? _parseIntMap(cm['npc_deltas'] as YamlMap) : null,
        next: cm['next'] as String,
        hidden: cm['hidden'] as bool? ?? false,
      );
    }).toList() ?? [];

    return Scene(
      id: map['scene'] as String,
      location: map['location'] as String,
      characters: (map['characters'] as YamlList).cast<String>(),
      mood: map['mood'] as String,
      dialogue: dialogue,
      choices: choices,
      type: map['type'] as String?,
    );
  }

  static Map<String, int> _parseIntMap(YamlMap? yamlMap) {
    if (yamlMap == null) return {};
    return yamlMap.map((key, value) => MapEntry(key as String, value as int));
  }
}
```

**Step 5: Run parser tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/narrative/engine/scene_parser_test.dart
```

Expected: All tests PASS.

**Step 6: Write failing test for NarrativeEngine**

Create `test/narrative/engine/narrative_engine_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/narrative/engine/scene.dart';
import 'package:king_of_chicago/narrative/engine/narrative_engine.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';

void main() {
  group('NarrativeEngine', () {
    final scene = Scene(
      id: 'test',
      location: 'test',
      characters: [],
      mood: 'tense',
      dialogue: [],
      choices: [
        const Choice(id: 'open', line: 'Open choice', veils: {'dread': 1}, next: 'a'),
        const Choice(id: 'locked', line: 'Locked', veils: {'guile': 3}, requires: {'sway': 60}, next: 'b'),
        const Choice(id: 'hidden', line: 'Hidden', veils: {'legend': 2}, requires: {'guile': 80}, next: 'c', hidden: true),
      ],
    );

    test('getAvailableChoices filters by veil thresholds', () {
      final state = VeilState.initial();
      final available = NarrativeEngine.getAvailableChoices(scene, state);
      expect(available.length, 1);
      expect(available.first.id, 'open');
    });

    test('getAvailableChoices unlocks when threshold met', () {
      final state = VeilState.initial().applyDeltas({VeilType.sway: 65});
      final available = NarrativeEngine.getAvailableChoices(scene, state);
      expect(available.length, 2);
      expect(available.map((c) => c.id), containsAll(['open', 'locked']));
    });

    test('getLockedChoices shows visible locked options', () {
      final state = VeilState.initial();
      final locked = NarrativeEngine.getLockedChoices(scene, state);
      expect(locked.length, 1);
      expect(locked.first.id, 'locked');
      // hidden choice should NOT appear in locked list
    });
  });
}
```

**Step 7: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/narrative/engine/narrative_engine_test.dart
```

Expected: FAIL.

**Step 8: Implement NarrativeEngine**

Create `lib/narrative/engine/narrative_engine.dart`:

```dart
import '../engine/scene.dart';
import '../../core/veils/veil_engine.dart';
import '../../core/veils/veil_state.dart';

class NarrativeEngine {
  const NarrativeEngine._();

  /// Returns choices the player CAN select (meets all thresholds)
  static List<Choice> getAvailableChoices(Scene scene, VeilState veilState) {
    return scene.choices.where((choice) {
      return VeilEngine.isChoiceAvailable(veilState, choice.requires);
    }).toList();
  }

  /// Returns choices that are visible but locked (shows threshold hint)
  /// Excludes hidden choices
  static List<Choice> getLockedChoices(Scene scene, VeilState veilState) {
    return scene.choices.where((choice) {
      final isLocked = !VeilEngine.isChoiceAvailable(veilState, choice.requires);
      final hasRequirements = choice.requires != null && choice.requires!.isNotEmpty;
      return isLocked && hasRequirements && !choice.hidden;
    }).toList();
  }
}
```

**Step 9: Run all narrative tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/narrative/
```

Expected: All tests PASS.

**Step 10: Create first YAML scene file**

Create `assets/story/act1/intro.yaml`:

```yaml
scene: funeral_arrival
location: south_side
characters:
  - vince
  - enzo
  - tommy
  - rosa
mood: somber
type: river
dialogue:
  - speaker: narrator
    line: "Rain hammers the black umbrellas outside Holy Name Cathedral. Don Castellano is in the box. Three days ago he was the most powerful man in Chicago. Now he's nothing."
  - speaker: enzo
    line: "Vince. Come. We need to talk before the others get their claws out."
choices:
  - id: respect_enzo
    line: "Of course, Uncle Enzo. Lead the way."
    veils:
      kinship: 2
      respect: 1
    npc_deltas:
      enzo: 5
    next: enzo_backroom
  - id: scan_crowd
    line: "In a minute. I want to see who showed up... and who didn't."
    veils:
      guile: 2
      legend: 1
    next: funeral_crowd_scan
  - id: confront_tommy
    line: "Tommy. Where the hell were you when it happened?"
    veils:
      dread: 2
      kinship: -1
    npc_deltas:
      tommy: -10
    next: tommy_confrontation
  - id: comfort_rosa
    line: "Rosa... hey. You okay?"
    veils:
      kinship: 3
      respect: 2
    npc_deltas:
      rosa: 10
    next: rosa_grief
```

**Step 11: Register assets in pubspec.yaml**

Add to `pubspec.yaml` under `flutter:`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/story/act1/
```

**Step 12: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/narrative/ king_of_chicago/test/narrative/ king_of_chicago/assets/
git commit -m "feat: implement narrative engine with YAML scene parser and first scene"
```

---

## Task 6: Save System

**Files:**
- Create: `lib/core/save/save_data.dart`
- Create: `lib/core/save/save_manager.dart`
- Test: `test/core/save/save_data_test.dart`

**Step 1: Write failing test**

Create `test/core/save/save_data_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/core/save/save_data.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/characters/npc_state.dart';

void main() {
  group('SaveData', () {
    test('serializes to JSON and deserializes back', () {
      final veilState = VeilState.initial().applyDeltas({
        VeilType.dread: 30,
        VeilType.kinship: 50,
      });
      final npcState = NpcState.initial().applyDelta('tommy', 20);

      final saveData = SaveData(
        currentSceneId: 'funeral_arrival',
        veilState: veilState,
        npcState: npcState,
        storyFlags: {'met_enzo': true, 'act': 1},
        cash: 1000,
      );

      final json = saveData.toJson();
      final restored = SaveData.fromJson(json);

      expect(restored.currentSceneId, 'funeral_arrival');
      expect(restored.veilState.getValue(VeilType.dread), 30);
      expect(restored.veilState.getValue(VeilType.kinship), 50);
      expect(restored.npcState.getRelationship('tommy'), 20);
      expect(restored.storyFlags['met_enzo'], true);
      expect(restored.cash, 1000);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/save/save_data_test.dart
```

Expected: FAIL.

**Step 3: Implement SaveData**

Create `lib/core/save/save_data.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../veils/veil_state.dart';
import '../veils/veil_type.dart';
import '../characters/npc_state.dart';

class SaveData extends Equatable {
  final String currentSceneId;
  final VeilState veilState;
  final NpcState npcState;
  final Map<String, dynamic> storyFlags;
  final int cash;

  const SaveData({
    required this.currentSceneId,
    required this.veilState,
    required this.npcState,
    required this.storyFlags,
    required this.cash,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentSceneId': currentSceneId,
      'veils': {
        for (final veil in VeilType.values) veil.name: veilState.getValue(veil),
      },
      'npcs': npcState.toMap(),
      'storyFlags': storyFlags,
      'cash': cash,
    };
  }

  factory SaveData.fromJson(Map<String, dynamic> json) {
    final veilMap = (json['veils'] as Map<String, dynamic>).map((key, value) {
      final type = VeilType.values.firstWhere((v) => v.name == key);
      return MapEntry(type, value as int);
    });

    final npcMap = (json['npcs'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value as int),
    );

    return SaveData(
      currentSceneId: json['currentSceneId'] as String,
      veilState: VeilState.fromMap(veilMap),
      npcState: NpcState.fromMap(npcMap),
      storyFlags: Map<String, dynamic>.from(json['storyFlags'] as Map),
      cash: json['cash'] as int,
    );
  }

  @override
  List<Object?> get props => [currentSceneId, veilState, npcState, storyFlags, cash];
}
```

Create `lib/core/save/save_manager.dart`:

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'save_data.dart';

class SaveManager {
  static const _boxName = 'king_of_chicago_saves';

  static Future<void> save(SaveData data, {int slot = 0}) async {
    final box = Hive.box(name: _boxName);
    box.put('save_$slot', jsonEncode(data.toJson()));
  }

  static SaveData? load({int slot = 0}) {
    final box = Hive.box(name: _boxName);
    final jsonString = box.get('save_$slot') as String?;
    if (jsonString == null) return null;
    return SaveData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static bool hasSave({int slot = 0}) {
    final box = Hive.box(name: _boxName);
    return box.get('save_$slot') != null;
  }

  static void deleteSave({int slot = 0}) {
    final box = Hive.box(name: _boxName);
    box.delete('save_$slot');
  }
}
```

**Step 4: Run tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/core/save/save_data_test.dart
```

Expected: All tests PASS.

**Step 5: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/core/save/ king_of_chicago/test/core/save/
git commit -m "feat: implement save system with JSON serialization and Hive persistence"
```

---

## Task 7: Dialogue Scene UI (Flutter Widget)

**Files:**
- Create: `lib/narrative/dialogue/dialogue_screen.dart`
- Create: `lib/narrative/dialogue/dialogue_text.dart`
- Create: `lib/narrative/dialogue/choice_wheel.dart`
- Create: `lib/ui/theme/game_theme.dart`
- Create: `lib/ui/theme/veil_colors.dart`

**Step 1: Create game theme and Veil color mapping**

Create `lib/ui/theme/veil_colors.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/veils/veil_type.dart';

class VeilColors {
  const VeilColors._();

  static const Map<VeilType, Color> primary = {
    VeilType.dread: Color(0xFFCC0000),
    VeilType.respect: Color(0xFFD4AF37),
    VeilType.sway: Color(0xFF4169E1),
    VeilType.empire: Color(0xFF228B22),
    VeilType.guile: Color(0xFF8B008B),
    VeilType.legend: Color(0xFFFF8C00),
    VeilType.kinship: Color(0xFF8B4513),
  };

  static Color getColor(VeilType veil) => primary[veil] ?? Colors.white;
}
```

Create `lib/ui/theme/game_theme.dart`:

```dart
import 'package:flutter/material.dart';

class GameTheme {
  const GameTheme._();

  static const backgroundColor = Color(0xFF0A0A0A);
  static const textColor = Color(0xFFE0D5C0);
  static const dialogueBackground = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF3A3A3A);

  static const dialogueTextStyle = TextStyle(
    color: textColor,
    fontSize: 16,
    height: 1.6,
    fontFamily: 'monospace',
  );

  static const speakerTextStyle = TextStyle(
    color: Color(0xFFD4AF37),
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );

  static const choiceTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'monospace',
  );

  static const lockedChoiceTextStyle = TextStyle(
    color: Color(0xFF666666),
    fontSize: 14,
    fontFamily: 'monospace',
    fontStyle: FontStyle.italic,
  );
}
```

**Step 2: Create dialogue text widget**

Create `lib/narrative/dialogue/dialogue_text.dart`:

```dart
import 'package:flutter/material.dart';
import '../../ui/theme/game_theme.dart';
import '../engine/scene.dart';

class DialogueText extends StatelessWidget {
  final DialogueLine line;

  const DialogueText({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (line.speaker != 'narrator')
            Text(
              line.speaker.toUpperCase(),
              style: GameTheme.speakerTextStyle,
            ),
          const SizedBox(height: 4),
          Text(
            line.line,
            style: line.speaker == 'narrator'
                ? GameTheme.dialogueTextStyle.copyWith(
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFAAAAAA),
                  )
                : GameTheme.dialogueTextStyle,
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Create choice wheel widget**

Create `lib/narrative/dialogue/choice_wheel.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/veils/veil_type.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/theme/veil_colors.dart';
import '../engine/scene.dart';

class ChoiceWheel extends StatelessWidget {
  final List<Choice> availableChoices;
  final List<Choice> lockedChoices;
  final void Function(Choice choice) onChoiceSelected;

  const ChoiceWheel({
    super.key,
    required this.availableChoices,
    required this.lockedChoices,
    required this.onChoiceSelected,
  });

  VeilType? _getPrimaryVeil(Choice choice) {
    if (choice.veils.isEmpty) return null;
    final sorted = choice.veils.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    try {
      return VeilType.values.firstWhere((v) => v.name == sorted.first.key);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...availableChoices.map((choice) {
          final veil = _getPrimaryVeil(choice);
          final color = veil != null ? VeilColors.getColor(veil) : Colors.white;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: InkWell(
              onTap: () => onChoiceSelected(choice),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(8),
                  color: color.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    if (veil != null) ...[
                      Text(veil.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(choice.line, style: GameTheme.choiceTextStyle),
                    ),
                    _buildVeilHints(choice),
                  ],
                ),
              ),
            ),
          );
        }),
        ...lockedChoices.map((choice) {
          final requiresText = choice.requires?.entries
              .map((e) => '${e.key.substring(0, 1).toUpperCase()}${e.key.substring(1)} ${e.value}+')
              .join(', ') ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF111111),
              ),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Requires $requiresText',
                      style: GameTheme.lockedChoiceTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVeilHints(Choice choice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: choice.veils.entries.take(2).map((entry) {
        final sign = entry.value > 0 ? '+' : '';
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '$sign${entry.value}',
            style: TextStyle(
              color: entry.value > 0 ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

**Step 4: Create dialogue screen**

Create `lib/narrative/dialogue/dialogue_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/veils/veil_provider.dart';
import '../../ui/theme/game_theme.dart';
import '../engine/narrative_engine.dart';
import '../engine/scene.dart';
import 'dialogue_text.dart';
import 'choice_wheel.dart';

class DialogueScreen extends ConsumerWidget {
  final Scene scene;
  final void Function(Choice choice) onChoiceSelected;

  const DialogueScreen({
    super.key,
    required this.scene,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veilState = ref.watch(veilProvider);
    final availableChoices = NarrativeEngine.getAvailableChoices(scene, veilState);
    final lockedChoices = NarrativeEngine.getLockedChoices(scene, veilState);

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Location header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: GameTheme.dialogueBackground,
              child: Text(
                scene.location.replaceAll('_', ' ').toUpperCase(),
                style: GameTheme.speakerTextStyle.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            // Dialogue
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  for (final line in scene.dialogue) DialogueText(line: line),
                ],
              ),
            ),
            // Choices
            Container(
              decoration: BoxDecoration(
                color: GameTheme.dialogueBackground,
                border: Border(
                  top: BorderSide(color: GameTheme.borderColor),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ChoiceWheel(
                availableChoices: availableChoices,
                lockedChoices: lockedChoices,
                onChoiceSelected: onChoiceSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Verify build**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter analyze
```

Expected: No issues.

**Step 6: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/narrative/dialogue/ king_of_chicago/lib/ui/
git commit -m "feat: implement dialogue screen with choice wheel and Veil-colored options"
```

---

## Task 8: Game Flow Controller (Wire It All Together)

**Files:**
- Create: `lib/narrative/engine/narrative_provider.dart`
- Modify: `lib/app.dart`

**Step 1: Create narrative provider**

Create `lib/narrative/engine/narrative_provider.dart`:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/veils/veil_provider.dart';
import '../../core/characters/npc_provider.dart';
import 'scene.dart';
import 'scene_parser.dart';

class NarrativeState {
  final Scene? currentScene;
  final List<String> sceneHistory;
  final bool isLoading;

  const NarrativeState({
    this.currentScene,
    this.sceneHistory = const [],
    this.isLoading = false,
  });

  NarrativeState copyWith({
    Scene? currentScene,
    List<String>? sceneHistory,
    bool? isLoading,
  }) {
    return NarrativeState(
      currentScene: currentScene ?? this.currentScene,
      sceneHistory: sceneHistory ?? this.sceneHistory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NarrativeNotifier extends Notifier<NarrativeState> {
  @override
  NarrativeState build() => const NarrativeState();

  Future<void> loadScene(String sceneId) async {
    state = state.copyWith(isLoading: true);

    try {
      final yamlString = await rootBundle.loadString(
        'assets/story/act1/$sceneId.yaml',
      );
      final scene = SceneParser.parseFromString(yamlString);
      state = NarrativeState(
        currentScene: scene,
        sceneHistory: [...state.sceneHistory, sceneId],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void selectChoice(Choice choice) {
    // Apply veil changes
    ref.read(veilProvider.notifier).applyStringDeltas(choice.veils);

    // Apply NPC relationship changes
    if (choice.npcDeltas != null) {
      for (final entry in choice.npcDeltas!.entries) {
        ref.read(npcProvider.notifier).applyDelta(entry.key, entry.value);
      }
    }

    // Navigate to next scene
    loadScene(choice.next);
  }
}

final narrativeProvider = NotifierProvider<NarrativeNotifier, NarrativeState>(
  NarrativeNotifier.new,
);
```

**Step 2: Update app.dart to wire everything**

Update `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'narrative/engine/narrative_provider.dart';
import 'narrative/dialogue/dialogue_screen.dart';
import 'ui/theme/game_theme.dart';

class KingOfChicagoApp extends StatelessWidget {
  const KingOfChicagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King of Chicago',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameTheme.backgroundColor,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Load the first scene after the widget tree is built
    Future.microtask(() {
      ref.read(narrativeProvider.notifier).loadScene('intro');
    });
  }

  @override
  Widget build(BuildContext context) {
    final narrativeState = ref.watch(narrativeProvider);

    if (narrativeState.isLoading || narrativeState.currentScene == null) {
      return const Scaffold(
        backgroundColor: GameTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'KING OF CHICAGO',
                style: TextStyle(
                  color: GameTheme.textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Color(0xFFD4AF37)),
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
```

**Step 3: Verify build**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter analyze
```

Expected: No issues.

**Step 4: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/
git commit -m "feat: wire game flow controller connecting narrative, veils, and NPC systems"
```

---

## Task 9: Ambush QTE (Flame Mini-Game)

**Files:**
- Create: `lib/action/qte/ambush_game.dart`
- Create: `lib/action/qte/ambush_target.dart`
- Create: `lib/action/qte/qte_result.dart`
- Test: `test/action/qte/qte_result_test.dart`

**Step 1: Create QTE result model with test**

Create `test/action/qte/qte_result_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/qte/qte_result.dart';

void main() {
  group('QteResult', () {
    test('clean win has positive outcome', () {
      const result = QteResult(
        outcome: QteOutcome.cleanWin,
        veilDeltas: {'dread': 2, 'legend': 1},
        heatDelta: 0,
      );
      expect(result.outcome, QteOutcome.cleanWin);
    });

    test('messy win adds heat', () {
      const result = QteResult(
        outcome: QteOutcome.messyWin,
        veilDeltas: {'dread': 3},
        heatDelta: 5,
      );
      expect(result.heatDelta, greaterThan(0));
    });

    test('failure has negative consequences', () {
      const result = QteResult(
        outcome: QteOutcome.failure,
        veilDeltas: {'respect': -2},
        heatDelta: 10,
      );
      expect(result.outcome, QteOutcome.failure);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/action/qte/qte_result_test.dart
```

Expected: FAIL.

**Step 3: Implement QTE result**

Create `lib/action/qte/qte_result.dart`:

```dart
enum QteOutcome { cleanWin, messyWin, failure }

class QteResult {
  final QteOutcome outcome;
  final Map<String, int> veilDeltas;
  final int heatDelta;

  const QteResult({
    required this.outcome,
    required this.veilDeltas,
    required this.heatDelta,
  });
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/action/qte/qte_result_test.dart
```

Expected: PASS.

**Step 5: Implement Ambush QTE game with Flame**

Create `lib/action/qte/ambush_target.dart`:

```dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AmbushTarget extends CircleComponent with TapCallbacks {
  final VoidCallback onTapped;
  double lifetime;
  double elapsed = 0;
  bool wasHit = false;

  AmbushTarget({
    required Vector2 position,
    required this.lifetime,
    required this.onTapped,
  }) : super(
          position: position,
          radius: 24,
          paint: Paint()..color = const Color(0xFFCC0000),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;

    // Pulse effect
    final pulse = 1.0 + 0.1 * sin(elapsed * 8);
    scale = Vector2.all(pulse);

    // Fade out near end of lifetime
    final remaining = (lifetime - elapsed) / lifetime;
    paint.color = Color(0xFFCC0000).withValues(alpha: remaining.clamp(0.2, 1.0));

    if (elapsed >= lifetime && !wasHit) {
      removeFromParent();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    wasHit = true;
    onTapped();
    removeFromParent();
  }
}
```

Create `lib/action/qte/ambush_game.dart`:

```dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ambush_target.dart';
import 'qte_result.dart';

class AmbushGame extends FlameGame {
  final int dreadLevel;
  final void Function(QteResult result) onComplete;
  final Random _random = Random();

  int _targetsHit = 0;
  int _targetsMissed = 0;
  int _totalTargets = 5;
  int _targetsSpawned = 0;
  double _spawnTimer = 0;
  bool _gameOver = false;

  AmbushGame({
    required this.dreadLevel,
    required this.onComplete,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF1A1A1A),
      ),
    );

    // Title text
    add(
      TextComponent(
        text: 'AMBUSH!',
        position: Vector2(size.x / 2, 30),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFCC0000),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // High Dread gives more time per target
    if (dreadLevel >= 80) {
      _totalTargets = 3; // Fewer targets needed — intimidation
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameOver) return;

    _spawnTimer += dt;
    final spawnInterval = dreadLevel >= 50 ? 1.5 : 1.2; // Dread slows enemies

    if (_spawnTimer >= spawnInterval && _targetsSpawned < _totalTargets) {
      _spawnTarget();
      _spawnTimer = 0;
      _targetsSpawned++;
    }

    if (_targetsHit + _targetsMissed >= _totalTargets) {
      _endGame();
    }
  }

  void _spawnTarget() {
    final targetLifetime = dreadLevel >= 50 ? 2.5 : 2.0;
    final target = AmbushTarget(
      position: Vector2(
        60 + _random.nextDouble() * (size.x - 120),
        100 + _random.nextDouble() * (size.y - 200),
      ),
      lifetime: targetLifetime,
      onTapped: () => _targetsHit++,
    );

    // Track missed targets
    target.removed.then((_) {
      if (!target.wasHit) _targetsMissed++;
    });

    add(target);
  }

  void _endGame() {
    _gameOver = true;
    final hitRatio = _targetsHit / _totalTargets;

    final QteResult result;
    if (hitRatio >= 0.8) {
      result = const QteResult(
        outcome: QteOutcome.cleanWin,
        veilDeltas: {'dread': 3, 'legend': 1},
        heatDelta: 1,
      );
    } else if (hitRatio >= 0.4) {
      result = const QteResult(
        outcome: QteOutcome.messyWin,
        veilDeltas: {'dread': 1, 'legend': 2},
        heatDelta: 5,
      );
    } else {
      result = const QteResult(
        outcome: QteOutcome.failure,
        veilDeltas: {'respect': -2},
        heatDelta: 10,
      );
    }

    onComplete(result);
  }
}
```

**Step 6: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/action/ king_of_chicago/test/action/
git commit -m "feat: implement Ambush QTE with Flame engine and Veil-gated difficulty"
```

---

## Task 10: Shakedown Mini-Game (Dialogue Negotiation)

**Files:**
- Create: `lib/action/shakedown/shakedown_state.dart`
- Create: `lib/action/shakedown/shakedown_screen.dart`
- Test: `test/action/shakedown/shakedown_state_test.dart`

**Step 1: Write failing test**

Create `test/action/shakedown/shakedown_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/action/shakedown/shakedown_state.dart';
import 'package:king_of_chicago/core/veils/veil_state.dart';
import 'package:king_of_chicago/core/veils/veil_type.dart';

void main() {
  group('ShakedownState', () {
    test('initial state has full target resistance', () {
      final state = ShakedownState.initial(targetResistance: 100);
      expect(state.targetResistance, 100);
      expect(state.turnsRemaining, 3);
      expect(state.isComplete, false);
    });

    test('applying pressure reduces resistance based on veil match', () {
      final veilState = VeilState.initial().applyDeltas({VeilType.dread: 50});
      final state = ShakedownState.initial(targetResistance: 100);
      final updated = state.applyPressure(ShakedownApproach.push, veilState);
      expect(updated.targetResistance, lessThan(100));
      expect(updated.turnsRemaining, 2);
    });

    test('game ends after 3 turns', () {
      var state = ShakedownState.initial(targetResistance: 50);
      final veilState = VeilState.initial().applyDeltas({VeilType.dread: 80});
      state = state.applyPressure(ShakedownApproach.push, veilState);
      state = state.applyPressure(ShakedownApproach.push, veilState);
      state = state.applyPressure(ShakedownApproach.push, veilState);
      expect(state.turnsRemaining, 0);
      expect(state.isComplete, true);
    });

    test('success when resistance drops to 0', () {
      final veilState = VeilState.initial().applyDeltas({VeilType.dread: 100});
      var state = ShakedownState.initial(targetResistance: 30);
      state = state.applyPressure(ShakedownApproach.push, veilState);
      expect(state.isSuccess, true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/action/shakedown/shakedown_state_test.dart
```

Expected: FAIL.

**Step 3: Implement ShakedownState**

Create `lib/action/shakedown/shakedown_state.dart`:

```dart
import '../../core/veils/veil_state.dart';
import '../../core/veils/veil_type.dart';

enum ShakedownApproach {
  push('Push', VeilType.dread, 'Threaten violence'),
  leverage('Leverage', VeilType.guile, 'Use what you know'),
  protect('Protect', VeilType.respect, 'Offer your protection'),
  bribe('Bribe', VeilType.empire, 'Make it worth their while'),
  callFavor('Call in a Favor', VeilType.kinship, 'Remind them who you know');

  const ShakedownApproach(this.label, this.veil, this.description);

  final String label;
  final VeilType veil;
  final String description;
}

class ShakedownState {
  final int targetResistance;
  final int turnsRemaining;
  final List<ShakedownApproach> approachesUsed;

  const ShakedownState({
    required this.targetResistance,
    required this.turnsRemaining,
    required this.approachesUsed,
  });

  factory ShakedownState.initial({required int targetResistance}) {
    return ShakedownState(
      targetResistance: targetResistance,
      turnsRemaining: 3,
      approachesUsed: const [],
    );
  }

  bool get isComplete => turnsRemaining <= 0 || targetResistance <= 0;
  bool get isSuccess => targetResistance <= 0;

  ShakedownState applyPressure(
    ShakedownApproach approach,
    VeilState veilState,
  ) {
    final veilValue = veilState.getValue(approach.veil);
    // Base pressure = 20, scaled by veil value (0-100)
    // At veil 50 -> 30 damage, at veil 100 -> 40 damage
    final pressure = 20 + (veilValue * 0.2).round();

    // Repeated approach is less effective
    final repeatPenalty = approachesUsed.contains(approach) ? 0.5 : 1.0;
    final effectivePressure = (pressure * repeatPenalty).round();

    final newResistance = (targetResistance - effectivePressure).clamp(0, 200);

    return ShakedownState(
      targetResistance: newResistance,
      turnsRemaining: turnsRemaining - 1,
      approachesUsed: [...approachesUsed, approach],
    );
  }
}
```

**Step 4: Run tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test test/action/shakedown/shakedown_state_test.dart
```

Expected: All tests PASS.

**Step 5: Create Shakedown screen widget**

Create `lib/action/shakedown/shakedown_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/veils/veil_provider.dart';
import '../../ui/theme/game_theme.dart';
import '../../ui/theme/veil_colors.dart';
import 'shakedown_state.dart';

class ShakedownScreen extends ConsumerStatefulWidget {
  final String targetName;
  final int targetResistance;
  final void Function(bool success, Map<String, int> veilDeltas) onComplete;

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

  void _selectApproach(ShakedownApproach approach) {
    final veilState = ref.read(veilProvider);
    setState(() {
      _state = _state.applyPressure(approach, veilState);
    });

    if (_state.isComplete) {
      final veilDeltas = _state.isSuccess
          ? {'empire': 3, 'respect': 1}
          : {'dread': 2, 'respect': -1};
      widget.onComplete(_state.isSuccess, veilDeltas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final veilState = ref.watch(veilProvider);

    return Scaffold(
      backgroundColor: GameTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Text(
                'THE SHAKEDOWN',
                style: GameTheme.speakerTextStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${widget.targetName}',
                style: GameTheme.dialogueTextStyle,
              ),
              const SizedBox(height: 16),

              // Resistance bar
              _buildResistanceBar(),
              const SizedBox(height: 8),
              Text(
                'Turns remaining: ${_state.turnsRemaining}',
                style: GameTheme.dialogueTextStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Approach options
              if (!_state.isComplete)
                ...ShakedownApproach.values.map((approach) {
                  final veilValue = veilState.getValue(approach.veil);
                  final color = VeilColors.getColor(approach.veil);
                  final wasUsed = _state.approachesUsed.contains(approach);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      onTap: () => _selectApproach(approach),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: wasUsed
                                ? color.withValues(alpha: 0.3)
                                : color.withValues(alpha: 0.7),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: color.withValues(alpha: wasUsed ? 0.05 : 0.1),
                        ),
                        child: Row(
                          children: [
                            Text(approach.veil.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    approach.label,
                                    style: GameTheme.choiceTextStyle.copyWith(
                                      color: wasUsed ? Colors.grey : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${approach.description} (${approach.veil.displayName}: $veilValue)',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (wasUsed)
                              const Text('↓', style: TextStyle(color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              // Result
              if (_state.isComplete) ...[
                const SizedBox(height: 32),
                Icon(
                  _state.isSuccess ? Icons.check_circle : Icons.cancel,
                  color: _state.isSuccess ? Colors.green : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  _state.isSuccess ? 'They cracked.' : 'They held firm.',
                  style: GameTheme.dialogueTextStyle.copyWith(fontSize: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResistanceBar() {
    final ratio = _state.targetResistance / widget.targetResistance;
    return Column(
      children: [
        const Text('RESISTANCE', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: const Color(0xFF333333),
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.5 ? Colors.red : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
```

**Step 6: Commit**

```bash
cd "/Users/fcp/King of chicago"
git add king_of_chicago/lib/action/shakedown/ king_of_chicago/test/action/shakedown/
git commit -m "feat: implement Shakedown negotiation mini-game with Veil-scaled pressure"
```

---

## Task 11: Run Full Test Suite & Verify Build

**Step 1: Run all tests**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter test
```

Expected: All tests PASS.

**Step 2: Run analyzer**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter analyze
```

Expected: No issues found.

**Step 3: Verify the app builds**

Run:
```bash
cd "/Users/fcp/King of chicago/king_of_chicago"
flutter build apk --debug
```

Expected: Build completes successfully.

**Step 4: Commit clean build**

```bash
cd "/Users/fcp/King of chicago"
git add -A
git commit -m "chore: verify full test suite and clean build for MVP foundation"
```

---

## Summary

This plan covers **11 tasks** that build the MVP foundation:

| Task | What It Builds | Tests |
|------|---------------|-------|
| 1 | Flutter project scaffold | - |
| 2 | Seven Veils engine | 8 tests |
| 3 | NPC relationship system | 3 tests |
| 4 | Territory & empire state | 4 tests |
| 5 | Narrative engine (YAML parser) | 6 tests |
| 6 | Save system | 1 test |
| 7 | Dialogue screen UI | - |
| 8 | Game flow controller | - |
| 9 | Ambush QTE (Flame) | 3 tests |
| 10 | Shakedown mini-game | 4 tests |
| 11 | Full build verification | - |

**After this plan:** You'll have a playable MVP shell — load the first scene, see dialogue with Veil-colored choices, make a choice that shifts your Veils and NPC relationships, and the next scene loads. The Ambush QTE and Shakedown mini-game are ready to be triggered from scene YAML. The save system can persist your progress.

**Next steps (not in this plan):** Write more Act 1 YAML scenes, create placeholder pixel art assets, build the territory map UI, and connect the action sequences to scene triggers.
