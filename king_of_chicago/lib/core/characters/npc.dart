/// Represents a non-player character in the game world.
///
/// Each NPC has a unique [id], display [name], narrative [role],
/// and a [territoryAnchor] linking them to a map territory.
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

  /// The 4 MVP NPCs available at launch.
  static const List<Npc> mvpNpcs = [
    Npc(
      id: 'mickey',
      name: "Mickey O'Banion",
      role: 'Rival',
      territoryAnchor: 'north_side',
    ),
    Npc(
      id: 'enzo',
      name: 'Enzo "The Barber" Castellano',
      role: 'Mentor',
      territoryAnchor: 'little_italy',
    ),
    Npc(
      id: 'tommy',
      name: 'Tommy "Two-Tone" Rizzo',
      role: 'Right Hand',
      territoryAnchor: 'south_side',
    ),
    Npc(
      id: 'rosa',
      name: 'Rosa Moretti',
      role: 'Sister',
      territoryAnchor: 'little_italy',
    ),
  ];
}
