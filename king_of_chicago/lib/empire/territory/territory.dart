import 'package:equatable/equatable.dart';

/// Represents a territory in 1920s Chicago that can be controlled by the player's empire.
///
/// Territories generate income when a capo is assigned to them.
/// Heat tracks law enforcement attention (0-100).
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

  /// Returns [baseIncome] if a capo is assigned, 0 otherwise.
  int get effectiveIncome => assignedCapo != null ? baseIncome : 0;

  /// Creates a copy with the specified fields replaced.
  /// Heat is always clamped to 0-100.
  Territory copyWith({
    int? heat,
    String? assignedCapo,
    bool? isActive,
    bool clearCapo = false,
  }) {
    final newHeat = heat ?? this.heat;
    return Territory(
      id: id,
      name: name,
      character: character,
      primaryRacket: primaryRacket,
      baseIncome: baseIncome,
      heat: newHeat.clamp(0, 100),
      assignedCapo: clearCapo ? null : (assignedCapo ?? this.assignedCapo),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        character,
        primaryRacket,
        baseIncome,
        heat,
        assignedCapo,
        isActive,
      ];

  /// The 3 MVP territories for the initial game.
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

  /// All 8 territories for the full game.
  static const List<Territory> allTerritories = [
    ...mvpTerritories,
    Territory(
      id: 'north_side',
      name: 'North Side',
      character: "Rival Irish gang (O'Banion crew)",
      primaryRacket: 'Smuggling, docks',
      baseIncome: 600,
    ),
    Territory(
      id: 'west_side',
      name: 'West Side',
      character: 'Contested no-man\'s land',
      primaryRacket: 'Protection rackets',
      baseIncome: 400,
    ),
    Territory(
      id: 'stockyards',
      name: 'Stockyards',
      character: 'Working-class union territory',
      primaryRacket: 'Labor racketeering',
      baseIncome: 450,
    ),
    Territory(
      id: 'gold_coast',
      name: 'Gold Coast',
      character: 'Old money, high society',
      primaryRacket: 'Extortion & blackmail',
      baseIncome: 700,
    ),
    Territory(
      id: 'levee_district',
      name: 'Levee District',
      character: 'Vice district, red-light',
      primaryRacket: 'Nightclubs & prostitution',
      baseIncome: 650,
    ),
  ];
}
