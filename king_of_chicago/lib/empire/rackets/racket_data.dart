import 'racket.dart';

/// Static racket definitions for all 8 territories.
///
/// Each territory has a racket with 3 tiers.
/// Tier 0 is the starting tier (free).
class RacketData {
  RacketData._();

  static const List<Racket> allRackets = [
    // South Side - Bootlegging
    Racket(
      territoryId: 'south_side',
      type: 'bootlegging',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Backroom Still',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Distillery',
          incomeMultiplier: 2,
          upgradeCost: 500,
          veilEffect: {'empire': 2},
        ),
        RacketTier(
          name: 'Distribution Network',
          incomeMultiplier: 3,
          upgradeCost: 1500,
          veilEffect: {'empire': 3, 'legend': 1},
        ),
      ],
    ),

    // Little Italy - Loan Sharking
    Racket(
      territoryId: 'little_italy',
      type: 'loan_sharking',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Street Corner',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Neighborhood Bank',
          incomeMultiplier: 2,
          upgradeCost: 400,
          veilEffect: {'kinship': 2},
        ),
        RacketTier(
          name: 'Community Trust',
          incomeMultiplier: 3,
          upgradeCost: 1200,
          veilEffect: {'kinship': 2, 'respect': 2},
        ),
      ],
    ),

    // The Loop - Gambling
    Racket(
      territoryId: 'the_loop',
      type: 'gambling',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Back Alley Dice',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Speakeasy Tables',
          incomeMultiplier: 2,
          upgradeCost: 600,
          veilEffect: {'empire': 2, 'sway': 1},
        ),
        RacketTier(
          name: 'Jazz Club Casino',
          incomeMultiplier: 3,
          upgradeCost: 2000,
          veilEffect: {'empire': 3, 'legend': 2},
        ),
      ],
    ),

    // North Side - Smuggling
    Racket(
      territoryId: 'north_side',
      type: 'smuggling',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Dock Runner',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Import Operation',
          incomeMultiplier: 2,
          upgradeCost: 550,
          veilEffect: {'empire': 2},
        ),
        RacketTier(
          name: 'Shipping Syndicate',
          incomeMultiplier: 3,
          upgradeCost: 1600,
          veilEffect: {'empire': 3, 'sway': 2},
        ),
      ],
    ),

    // West Side - Protection
    Racket(
      territoryId: 'west_side',
      type: 'protection',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Street Shakedown',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Neighborhood Watch',
          incomeMultiplier: 2,
          upgradeCost: 450,
          veilEffect: {'respect': 2},
        ),
        RacketTier(
          name: 'District Enforcer',
          incomeMultiplier: 3,
          upgradeCost: 1300,
          veilEffect: {'respect': 3, 'empire': 1},
        ),
      ],
    ),

    // Stockyards - Labor Racketeering
    Racket(
      territoryId: 'stockyards',
      type: 'labor_racketeering',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Union Dues Skim',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Union Boss',
          incomeMultiplier: 2,
          upgradeCost: 500,
          veilEffect: {'kinship': 2},
        ),
        RacketTier(
          name: 'Labor Cartel',
          incomeMultiplier: 3,
          upgradeCost: 1400,
          veilEffect: {'kinship': 2, 'empire': 2},
        ),
      ],
    ),

    // Gold Coast - Extortion
    Racket(
      territoryId: 'gold_coast',
      type: 'extortion',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Petty Blackmail',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Society Secrets',
          incomeMultiplier: 2,
          upgradeCost: 650,
          veilEffect: {'sway': 2},
        ),
        RacketTier(
          name: 'Political Leverage',
          incomeMultiplier: 3,
          upgradeCost: 1800,
          veilEffect: {'sway': 3, 'legend': 1},
        ),
      ],
    ),

    // Levee District - Nightclubs
    Racket(
      territoryId: 'levee_district',
      type: 'nightclubs',
      currentTier: 0,
      tiers: [
        RacketTier(
          name: 'Dive Bar',
          incomeMultiplier: 1,
          upgradeCost: 0,
          veilEffect: {},
        ),
        RacketTier(
          name: 'Jazz Lounge',
          incomeMultiplier: 2,
          upgradeCost: 600,
          veilEffect: {'legend': 2},
        ),
        RacketTier(
          name: 'The Grand Palace',
          incomeMultiplier: 3,
          upgradeCost: 1700,
          veilEffect: {'legend': 3, 'sway': 1},
        ),
      ],
    ),
  ];
}
