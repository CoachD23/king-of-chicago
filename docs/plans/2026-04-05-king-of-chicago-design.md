# King of Chicago — Game Design Document

## Final Design Summary

- **Genre:** Interactive fiction / narrative with action mini-games
- **Platform:** Mobile (iOS + Android) via Flutter + Flame
- **Setting:** 1920s-30s Prohibition Chicago
- **Protagonist:** Vince Moretti, mid-level enforcer stepping into a power vacuum
- **Art style:** Retro pixel art (320x180 base, 64x64 portraits)
- **Core system:** Seven Veils (Dread, Respect, Sway, Empire, Guile, Legend, Kinship) — Respect sits at the center as the "humanity" modifier that tensions against every extreme build
- **Narrative:** 5 Acts, river-with-rapids branching, 8 key NPCs, 4-5 hand-authored major endings shaped by your top 2-3 Veils (20+ meaningful variations)
- **Dialogue:** 7-point radial wheel with Veil-gated and hidden options
- **Action:** Hybrid — 4 QTE types for reactive moments + 5 mini-games for planned operations (Shakedown, Shootout, Drive-By, Bomb Run, Heist)
- **Empire:** 8 territories, capo assignment, 3-tier racket upgrades, per-territory heat system, Weekly Empire dashboard
- **Signature motif:** Reputation flashback cuts tied to each Veil
- **MVP (Phase 1):** Act 1 only (~30-45 min), 3 territories, radial wheel + Respect tension, 1 QTE + Shakedown, 4 NPCs
- **Replay incentives:** New Game+ (start with one Veil at 50), Veil-locked scenes, and alternate phoenix branches revealed on subsequent playthroughs

---

## 1. Game Concept & Premise

**Title:** King of Chicago

**Premise:** Chicago, 1929. You're Vince Moretti, a mid-level enforcer for the Castellano crime family. When Don Castellano is gunned down at his own birthday dinner, the family fractures. Three lieutenants — including you — scramble for control. The city is up for grabs.

**Inspirations:** King of Chicago (1986), Scarface, The Godfather, The Sopranos

---

## 2. The Seven Veils

The Seven Veils are the beating heart of the game. Every choice, action sequence, territory decision, and NPC interaction shifts one or more Veils. Your dominant Veils at the end of Act 5 determine your ending.

| Veil | Fantasy | Description |
|------|---------|-------------|
| **Dread** | The Monster | Violence, executions, and calculated cruelty make people obey on sight |
| **Respect** | The Honorable | Old-school respect earned through keeping your word and "fairness" among thieves. Your capos would walk through fire for you |
| **Sway** | The Puppeteer | The system is yours. Judges, cops, aldermen, and union bosses are bought, blackmailed, or mutually beneficial |
| **Empire** | The Mogul | You don't just have money — you own the legitimate and illegitimate arteries of the city. Cash flows like blood |
| **Guile** | The Chessmaster | You are the unseen chessmaster. You pit rivals against each other, leak false intel, and strike only when victory is guaranteed |
| **Legend** | The Icon | Your name is bigger than you. Street ballads, tabloid headlines, or whispered folklore. You're either folk hero or public enemy #1 |
| **Kinship** | The Patriarch | The unbreakable core of blood, marriage, and chosen family. Your inner circle is ride-or-die... or your greatest vulnerability |

### Veil Interactions

- Some axes naturally tension against each other — high Dread erodes Respect, high Legend undermines Guile (hard to scheme when everyone's watching you)
- Choices often boost one Veil while lowering another
- Your top 2-3 Veils at the end of Act 5 determine your ending (20+ meaningful variations from 4-5 hand-authored major endings)
- Certain story paths and action sequences only unlock at Veil thresholds (e.g., high Guile lets you set up a rival instead of fighting him head-on)

### Respect as the Center Modifier

Respect occupies the center of the dialogue wheel as the "humanity" axis. Every extreme build has a Respect cost — you can be the most feared, connected, or cunning boss in Chicago, but at what cost to your soul? This is the entire thematic engine of every great mob story.

### Reputation Flashback Motifs

Every Veil shift triggers a 2-second signature visual cut — the game's DNA:

| Veil | Motif |
|------|-------|
| Dread | Street whisper montage with blood drip |
| Respect | Old-school handshake that either holds or slips |
| Sway | Courtroom sketch or gavel slam |
| Empire | Ledger pages flipping with coin sounds |
| Guile | Chess piece sliding across a board |
| Legend | Newspaper headline spinning onto screen |
| Kinship | Cracked family photo / dinner table reaction |

These motifs appear in every scene, QTE, and management screen. After 30 minutes players recognize them subconsciously.

---

## 3. Narrative Structure

### Five Acts

| Act | Title | Length | Focus |
|-----|-------|--------|-------|
| Act 1 | The Funeral | 30-45 min | Power vacuum forms. Pick your first alliance or betrayal |
| Act 2 | The Streets | 45-60 min | Claim territory. Establish rackets. First major action sequences |
| Act 3 | The War | 45-60 min | Open conflict with rival factions. Drive-bys, ambushes, retaliation |
| Act 4 | The Machine | 45-60 min | Politics, corruption, bribing city hall. Bigger stakes |
| Act 5 | The Crown | 45-60 min | Final showdown. Multiple endings based on your Veils |

### Branching Architecture: River with Rapids

Full branching for every choice is a content nightmare. Instead, use a river model:

- **The River** — The main story flows forward through 5 Acts regardless. Everyone hits the same major story beats (Don's funeral, the warehouse war, the federal investigation, the final betrayal, the coronation)
- **The Rapids** — How you experience each beat varies wildly based on your Veils and prior choices. Same destination, completely different journey
- **The Tributaries** — 2-3 major branch points per Act where the story genuinely forks for 3-4 scenes before rejoining. These are the "holy shit" moments
- **The Falls** — Point of no return moments (one per Act). A character dies, an alliance locks in, a territory is permanently lost. These shape which ending you get

### Phoenix Branches (Failure as Storytelling)

30% of failures unlock hidden "phoenix" tributary chapters:

- Botched protection of Sal -> short "Joliet Prison" chapter (2-3 scenes) where you flip a guard (Sway), earn inmate respect (Dread/Legend), or call in family (Kinship)
- Failed Shakedown where target fights back -> unexpected alliance if you show Respect by letting them live

This turns "I screwed up" into "this is the best story beat yet" — pure Sopranos/Godfather energy.

---

## 4. Dialogue System

### 7-Veil Radial Wheel

```
[Guile]          <- Calculated / Chessmaster
       /          \
[Dread]               [Sway]   <- Ruthless / Diplomatic
     \               /
      [Kinship]   [Empire]     <- Loyal / Generous
           \     /
          [Legend]          <- Bold / Showman
              |
          (Respect lives in the center as the "balanced" modifier)
```

**How it works:**

- Each slice is 100% locked to one Veil + an optional Respect modifier (because Respect is the "humanity" axis that tensions with everything)
- Each slice has its signature icon + color
- Greyed-out slices show the exact threshold ("Guile 45+")
- Subtext hint: tiny Veil icon + predicted delta (e.g., +3 Dread, -1 Respect)
- Not every scene shows all options — typically 2-4 based on context
- Hidden options only appear if a prior choice or territory state unlocked them

### Example Scene

> **Location:** Back room of Sal's Barbershop, Little Italy
>
> **Sal:** "The O'Banion boys came by yesterday. Said they want 'protection money' from every shop on Taylor Street. My Taylor Street, Vince."
>
> - [Dread] "I'll nail their heads to your door." [Dread +3, Respect +1, Heat +2]
> - [Sway] "I'll talk to their boss. This was a misunderstanding." [Sway +2, Guile +1]
> - [Empire] "Double your payments to me and I guarantee nobody touches you." [Empire +2, Respect -1]
> - [Kinship] "Sal, you're family. Nobody pays on my streets." [Kinship +3, Empire -1]
> - [Locked: Sway 60+] "I already bought their boss." [Guile +3, Legend +1]

### Three-Outcome Structure (Dialogue)

- **Clean Success** -> positive Veil moves + smooth ripple
- **Messy Success** -> mixed Veils + heat/complications
- **Failure** -> 30% chance of phoenix branch, otherwise territory loss + story consequences

---

## 5. Character Roster

| Role | Name | Primary Veil Tension | Territory Anchor | Late-Game Role |
|------|------|---------------------|-----------------|----------------|
| Rival | Mickey O'Banion | Dread vs Respect mirror | North Side | Final Act betrayal or uneasy truce |
| Mentor/Family | Enzo "The Barber" Castellano | Kinship / Respect anchor | Little Italy | Moral compass or sacrifice moment |
| Wildcard/Romance | "Diamond" Dolly | Guile + Legend | Levee District | Information broker or tragic love |
| Fed Threat | Agent Margaret Holt | Sway vs Legend | The Loop | Escalating investigation |
| Right Hand | Tommy "Two-Tone" Rizzo | Kinship barometer | South Side | Loyalty test every Act |
| Politician | Alderman Finnegan | Sway / Empire | Stockyards / Gold Coast | Bribe or blackmail vector |
| Sister/Compass | Rosa Moretti | Kinship / Respect | Little Italy | Personal stakes & endings |
| Upstart | Nicky "The Kid" Palazzo | Guile / Dread wildcard | West Side | Ally, successor, or betrayer |

Each NPC has a hidden -100 to +100 relationship meter shaped by your choices.

**NPCs react to your dominant Veils:**

- High Dread Vince: Tommy is afraid of you. Rosa won't return your calls. Mickey respects you grudgingly.
- High Kinship Vince: Tommy would die for you. Rosa brings you Sunday dinner. But Agent Holt sees a soft target.
- High Guile Vince: Nobody is sure what you're planning. Diamond Dolly is intrigued. Alderman Finnegan is terrified.

---

## 6. Territory Map — Chicago's Wards (1930s)

8 territories, each with its own flavor, primary racket, Veil synergies, and risk:

| Territory | Character | Primary Racket | Veil Synergies & Tension | Special Flavor / Risk |
|-----------|-----------|---------------|--------------------------|----------------------|
| The Loop | Downtown power center | Gambling halls, speakeasies | +Empire, +Sway / -Dread (too public) | High income, but feds love it |
| South Side | Castellano family home turf | Bootlegging, distilleries | +Kinship, +Respect / -Guile (too visible) | Your roots — family events trigger here |
| North Side | Rival Irish gang (O'Banion crew) | Smuggling, docks | +Dread, +Legend / -Respect (brutal turf wars) | Constant rival pressure — war or truce? |
| West Side | Contested no-man's land | Protection rackets | +Dread or +Guile (your choice) | High heat spikes; perfect for Guile plays |
| Stockyards | Working-class union territory | Labor racketeering | +Sway, +Empire / -Legend (looks too "legit") | Union bosses = political gold |
| Gold Coast | Old money, high society | Extortion & blackmail | +Sway, +Guile / -Dread (subtle threats only) | Elite connections but fragile reputation |
| Little Italy | Immigrant community, your roots | Loan sharking & community | +Kinship, +Respect / -Empire (low cash ceiling) | Loyalty missions and heartbreaking choices |
| Levee District | Vice district, red-light | Nightclubs & prostitution | +Legend, +Empire / -Respect (vice draws attention) | High notoriety & heat; great for shows |

### Empire Management (Medium Depth, High Drama)

**Capo Assignment:**
- Drag capos onto territories. Each capo has two Veil affinities (e.g., "Dread +2 / Kinship -1") and one weakness
- Wrong match = veiled penalties or story events

**Racket Upgrades:**
- Three tiers per racket (e.g., Speakeasy -> Jazz Club -> Supper Club)
- Empire-focused upgrades boost cash but raise heat
- Respect-focused upgrades cost less cash but require crew loyalty

**Weekly Empire Screen:**
- Income waterfall (green arrows)
- Outgoing (wages + bribes in red)
- Territory heat bars (color-coded: blue -> yellow -> blood red)
- Veil impact icons that pulse when they shift
- No walls of numbers — elegant bars, icons, and flavor text

**Heat & Rival Pressure:**
- Heat is per-territory and tied to your dominant Veils
- High Dread = faster heat decay but triggers "assassination attempt" events
- High Guile = slower heat buildup and surprise rival sabotage options
- Undefended or mismanaged territories flash red warnings. Ignore them and you lose ground and Veil points

---

## 7. Action Sequences (Hybrid System)

### QTEs — Reactive Chaos

| Trigger | Example | Mechanic (with Veil sauce) | Frequency |
|---------|---------|---------------------------|-----------|
| Ambush | Rival goons kick in the speakeasy door | Tap targets + one Veil-gated "intimidate" option | Common |
| Bar Fight | Disrespected capo throws a punch | Swipe directions; high Respect auto-counters once | Common |
| Police Chase | Raid during a deal | Timed swipes; high Sway = crooked cop radio tip | Medium |
| Interrogation | Cop grills you in the station | Bluff / Silence / Bribe wheel; high Guile adds "plant evidence" escape | Medium |

**80+ Veil Skip Rule:** If any Veil is 80+, certain QTEs can be skipped entirely with a cinematic payoff:
- 80+ Dread: Goons freeze, camera slow-mo, you just stare them down
- 80+ Legend: A fanboy goon switches sides mid-fight

### Mini-Games — Planned Power Moves (60-90 seconds each)

**1. Shakedown (Dialogue + Stat Negotiation Wheel)**
- Circular dialogue wheel with hidden Veil checks
- Push (Dread), Leverage (Guile), Protect (Respect), Bribe (Empire), or Call in Favor (Kinship/Sway)
- Success = new racket or flipped asset. Failure = violence fallback or lost territory influence
- The most "King of Chicago" mini-game — pure personality-driven power fantasy

**2. Shootout (Cover-based Tap-Shooter)**
- Pop in/out of cover, aim, fire
- Crew allies fight alongside you (Kinship = more loyal shooters, Empire = better guns)
- High Dread = enemies panic and miss more. High Respect = one enemy can be convinced to surrender

**3. Drive-By (Side-Scrolling Car Run)**
- Tap to shoot windows/guards, swipe to dodge
- High Dread = heavier car armor & more damage. High Guile = pre-planted bomb option (skip to explosion cinematic)

**4. Bomb Run (Top-Down Stealth Timing Puzzle)**
- Sneak past patrols, timing mini-game for lockpicking & charge placement
- High Sway = crooked cop reveals patrol route. High Legend = civilians warn you (but also risk recognition)

**5. The Heist (Multi-Phase Planning + Execution)**
- Pick your crew (Kinship affects loyalty mid-job), choose entry strategy (Guile = stealth, Dread = brute force, Sway = inside man)
- 2-3 quick phases: infiltrate -> grab -> escape, each a 30-second micro-challenge
- Only available 1-2 times per Act as a "big score" moment. Ties into Empire (the cash payoff)

### Action Outcome Structure

Every action sequence has three possible outcomes:
- **Clean Win** -> +Veil points + income boost
- **Messy Win** -> +Dread/Legend but +heat
- **Failure** -> territory loss + story consequences (capo death, rival gains ground, potential phoenix branch)

### Pacing Rules

- 2-3 full mini-games per Act (chosen via planning on the Empire map)
- 4-6 QTEs sprinkled through dialogue and travel scenes
- Maximum 10-12 minutes between any interactive moment
- 70% narrative/management, 30% action

### Veil Gating & Progression

- Early game: Most sequences are mandatory and punishing
- Late game: High-Veil players get alternative paths that feel god-like (e.g., 90+ Guile lets you skip a Shootout entirely and have the rival's own crew turn on him)
- Every mini-game has a "reputation flashback" moment tied to the Veil motifs

---

## 8. Technical Architecture

### Stack

- **Framework:** Flutter (UI, navigation, management screens)
- **Game Engine:** Flame (action sequences, sprite rendering)
- **State Management:** Riverpod (immutable state, single source of truth)
- **Narrative Engine:** Custom, data-driven (YAML scene files)
- **Persistence:** Hive (local NoSQL, 3 save slots)
- **Pixel Art Tool:** Aseprite
- **Audio:** Flame audio system (OGG files)

### System Architecture

```
+---------------------------------------------+
|                   App Shell                  |
|              (Flutter / Material)            |
+----------+----------+-----------------------+
| Narrative|  Empire  |    Action Engine       |
|  Engine  |  Manager |    (Flame)             |
|          |          |                        |
| Dialogue | Territory| Shootout  Drive-By     |
| Scenes   | Map      | Bomb Run  Heist        |
| Choices  | Capos    | Shakedown QTEs         |
| Branching| Rackets  |                        |
| NPC Meter| Income   | Sprite    Collision    |
|          | Heat     | Engine    Detection    |
+----------+----------+-----------------------+
|              Seven Veils Engine              |
|  (Core state: all 7 axes + NPC meters +     |
|   territory states + story flags)            |
+---------------------------------------------+
|           Save / Persistence Layer           |
|        (Hive for local, JSON export)         |
+---------------------------------------------+
```

### Narrative Engine (Data-Driven)

Story content lives in YAML files, not hardcoded Dart. Each scene is a node with location, characters, dialogue, and choices (with Veil thresholds, deltas, and locked/hidden flags). Branching logic is a directed graph with river/rapids/tributary/falls markers.

```yaml
scene: sals_barbershop_act1
location: little_italy
characters: [sal, vince]
mood: tense
dialogue:
  - speaker: sal
    line: "The O'Banion boys came by yesterday..."
choices:
  - id: threaten
    line: "I'll nail their heads to your door."
    veils: { dread: +3, respect: +1 }
    heat: { little_italy: +2 }
    next: sal_relieved_violent
  - id: diplomacy
    line: "I'll talk to their boss."
    veils: { sway: +2, guile: +1 }
    next: sal_skeptical
  - id: exploit
    line: "Double your payments to me."
    veils: { empire: +2, respect: -1 }
    next: sal_disappointed
  - id: protect
    line: "Sal, you're family."
    veils: { kinship: +3, empire: -1 }
    next: sal_grateful
  - id: power_move
    line: "I already bought their boss."
    requires: { sway: 60 }
    veils: { guile: +3, legend: +1 }
    next: sal_stunned
```

### Pixel Art Pipeline

- Aseprite for sprite creation
- Sprite sheets exported as PNG + JSON atlas
- Base resolution: 320x180 scaled up (classic 16-bit feel on modern screens)
- Character portraits: 64x64 px with expression variants (neutral, angry, scared, smug, etc.)
- Reputation flashback motifs: 7 short sprite animations

### Audio

- Background: Period-appropriate jazz, blues, ambient city sounds
- SFX: Gunshots, car engines, rain, typewriter (for newspaper motif)
- Music shifts based on territory and current scene mood

### Project Structure

```
king_of_chicago/
├── lib/
│   ├── app.dart                    # App entry + routing
│   ├── core/
│   │   ├── veils/                  # Seven Veils engine
│   │   ├── save/                   # Persistence layer
│   │   └── audio/                  # Audio manager
│   ├── narrative/
│   │   ├── engine/                 # Scene parser, graph walker
│   │   ├── dialogue/               # Dialogue wheel widget
│   │   └── characters/             # NPC relationship logic
│   ├── empire/
│   │   ├── territory/              # Territory map + state
│   │   ├── capos/                  # Capo assignment logic
│   │   ├── rackets/                # Racket upgrade system
│   │   └── dashboard/              # Weekly income screen
│   ├── action/
│   │   ├── qte/                    # Quick-time event system
│   │   ├── shootout/               # Flame game
│   │   ├── driveby/                # Flame game
│   │   ├── bomb_run/               # Flame game
│   │   ├── heist/                  # Flame game
│   │   └── shakedown/              # Dialogue-based mini-game
│   └── ui/
│       ├── theme/                  # Pixel art theme, colors, fonts
│       ├── widgets/                # Shared components
│       └── motifs/                 # Reputation flashback animations
├── assets/
│   ├── story/                      # YAML scene files
│   │   ├── act1/
│   │   ├── act2/
│   │   ├── act3/
│   │   ├── act4/
│   │   └── act5/
│   ├── sprites/                    # Character + environment art
│   ├── portraits/                  # 64x64 character faces
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/                      # Period-appropriate pixel font
├── test/
│   ├── veils/                      # Veil calculation tests
│   ├── narrative/                  # Scene graph tests
│   ├── empire/                     # Territory + racket tests
│   └── action/                     # Mini-game logic tests
└── docs/
    └── plans/                      # Design docs
```

---

## 9. Phased Development

### Phase 1 — MVP ("The Pilot Episode")

Ship Act 1 only. Prove the core loop works.

| System | MVP Scope |
|--------|-----------|
| Narrative | Act 1 complete (~30-45 min) — The Funeral through first territory claim |
| Seven Veils | Full engine, all 7 axes tracking and displaying |
| Dialogue | Full radial wheel with at least one Respect-centered choice that visibly tensions against another Veil (e.g., protect family vs make money) |
| Territory | 3 of 8 territories active (South Side, Little Italy, The Loop) |
| Empire | Capo assignment + basic racket income. No upgrades yet |
| Action | 1 QTE type (Ambush) + 1 mini-game (Shakedown) |
| Characters | 4 NPCs active (Mickey, Enzo, Tommy, Rosa) |
| Art | Character portraits + 3 location backgrounds + Veil motifs |
| Audio | 1 background track + essential SFX |
| Save | Single save slot, auto-save at Act 1 "falls" |

### Phase 2 — "Season One"

| Addition | Details |
|----------|---------|
| Acts 2-3 | Full war arc, ~2 hours of new content |
| Remaining territories | All 8 active |
| Racket upgrades | 3-tier system live |
| Shootout + Drive-By | Two more mini-games |
| Weekly Empire Screen | Full dashboard with income waterfall + heat bars |
| All 8 NPCs | Diamond Dolly, Agent Holt, Finnegan, Nicky join |
| 3 save slots | Plus act-boundary auto-saves |
| More art + audio | Full sprite sheets, 3-4 music tracks |

### Phase 3 — "The Complete Saga"

| Addition | Details |
|----------|---------|
| Acts 4-5 | Politics, feds, final showdown. Full 5-6 hour game |
| Bomb Run + Heist | All 5 mini-games complete |
| Multiple endings | 4-5 hand-authored major endings shaped by top 2-3 Veils (20+ meaningful variations) |
| Phoenix branches | Failure tributaries (prison chapter, exile, etc.) |
| Replay incentives | Veil-locked scenes revealed on second playthrough |
| Polish | Full soundtrack, sound design, screen transitions, particle effects |

### Phase 4 — "Director's Cut" (Stretch)

| Addition | Details |
|----------|---------|
| New Game+ | Start with one Veil at 50, see how it changes everything |
| Side stories | Optional 10-minute tributary arcs per territory |
| Cloud save | Cross-device sync |
| Accessibility | Font scaling, colorblind Veil icons, QTE timing options |
