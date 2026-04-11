# Transition — Feature Specification

> **PRD Step**: 11 — Vertical Progression
> **Dependencies**: Step 5 (Combat), Step 6 (Technologies)
> **Status**: Draft

---

## 1. Feature Overview

The Transition system introduces **vertical progression** to ABYSSES. The world is extended into 3 depth levels connected by guarded passage points called **Transition Bases** (Failles Abyssales and Cheminees du Noyau). The player must discover these passages, defeat their guardians in boss fights, and descend to explore deeper levels.

Key mechanics:
- **Discovery**: transition bases are hidden under fog of war and found through exploration.
- **Boss combat**: each transition base is guarded by a boss + escort. The player must win AND keep their Abyss Admiral alive to capture it.
- **Descent**: once captured, the player can send units down to a newly generated level. Descent is **one-way** — units cannot return.
- **Shared economy**: all levels share a single global resource pool. Production stays on Level 1; units transit via captured failles.
- **Prerequisites**: each descent tier requires a special building.

### Scope boundaries

- **In scope**: transition base generation/placement, boss combat, capture mechanic, descent, reinforcements, multi-level map management, level selector UI, unit type rename (`siphoner` → `abyssAdmiral`).
- **Out of scope**: Level 3 content/final objective (Step 12), AI faction interaction with failles (no AI system yet), counter-attacks on captured failles, defensive structures at failles, unit ascent (one-way only).

---

## 2. User Stories

### US-1: Discover a transition base

**As a** player exploring the map,
**I want to** find transition bases hidden in the fog of war,
**So that** I can plan my vertical progression.

**Acceptance criteria:**
- Transition bases are placed on the map during generation as `CellContentType.transitionBase`.
- On Level 1: 4 Failles Abyssales, placed one per quadrant on the outer edges (distance > 8 from center), minimum 5 tiles apart.
- On Level 2: 3 Cheminees du Noyau, placed on outer edges (distance > 10 from center), minimum 5 tiles apart.
- When a scout reveals a transition base tile, a special marker appears (glowing rift icon).
- A bottom sheet displays: name (generated), difficulty rating (4/5 for failles, 5/5 for cheminees), status (neutral / captured), and prerequisite checklist.

---

### US-2: Check prerequisites for assault

**As a** player who discovered a transition base,
**I want to** see if the transition base is owned by itself, or by another one (IA or monsters)
**So that** I know what can I do.

**Acceptance criteria:**
- If player owns it: aura green
- If monster owns it: aura red
- If other player owns it: aura orange

---

### US-3: Build a descent building

**As a** player preparing for descent,
**I want to** build the required special building in my base,
**So that** I can unlock the ability to assault a transition base.

**Acceptance criteria:**
- Two new building types: `descentModule` and `pressureCapsule`.
- **Descent Module** cost: 200 Coral, 150 Ore, 80 Energy, 5 Pearls.
- **Pressure Capsule** cost: 400 Coral, 300 Ore, 150 Energy, 15 Pearls.
- Each can only be built once (not upgradable).
- Building follows the standard `upgradeBuilding` action pattern.
- The Pressure Capsule is only available once the player has reached Level 2.

---

### US-4: Assault a transition base (boss fight)

**As a** player
**I want to** send my army to fight the guardians of a transition base,
**So that** I can capture it and unlock descent.

**Acceptance criteria:**
- New action: `attackTransitionBase`.
- The player selects units to send. At least 1 Abyss Admiral is mandatory.
- Combat uses the standard `FightEngine`.
- **Guardians for Faille Abyssale**: 1 Leviathan (boss: 100 HP, 15 ATK, 10 DEF) + 5 Sentinelles (30 HP, 8 ATK, 5 DEF).
- **Guardians for Cheminee du Noyau**: 1 Titan Volcanique (boss: 200 HP, 25 ATK, 15 DEF) + 8 Golems de magma (50 HP, 12 ATK, 8 DEF).
- Guardian creatures have a `isBoss` flag used for victory condition checks and narrative display.
- **Victory + Admiral alive**: transition base is captured. Narrative event displayed.
- **Victory + Admiral dead**: combat won but capture fails. Surviving army returns to base. Guardians reform at full strength.
- **Defeat**: army is lost. Guardians reform at full strength.

---

### US-5: Descend to the next level

**As a** player who captured a transition base,
**I want to** send units down to explore the next depth level,
**So that** I can progress deeper into the abyss.

**Acceptance criteria:**
- New action: `descend`.
- Available from the bottom sheet of a captured transition base ("Descend to Level X" button).
- A full-screen dialog lets the player select which units to send (no capacity limit).
- A new 20x20 map is generated for the next level, entirely under fog of war.
- Units arrive at a fixed spawn point on the new level and are resolved at the end of the turn.
- Descent is **one-way**: units sent down cannot return to the previous level.
- The new level is generated with its own transition bases (Cheminees on Level 2) and content appropriate to the depth.
- Prerequesites is to have build the special building associated to descent.

---

### US-6: Send reinforcements

**As a** player with units on a lower level,
**I want to** send additional units through a captured faille,
**So that** I can strengthen my forces below.

**Acceptance criteria:**
- New action: `sendReinforcements`.
- Available from the bottom sheet of a captured transition base ("Send reinforcements" button).
- The player selects units from their base's army.
- Units arrive on the lower level after **1 turn** of transit.
- During transit, units are unavailable on both levels.
- Reinforcements appear at the faille's spawn point on the lower level.

---

### US-7: Navigate between levels

**As a** player with presence on multiple levels,
**I want to** switch between level views on the map,
**So that** I can manage my forces across all depths.

**Acceptance criteria:**
- A level selector appears at the top of the map tab: `[Niv 1: Surface] [Niv 2: Profondeurs] [Niv 3: Noyau]`.
- Locked levels are grayed out with a padlock icon.
- The active level is highlighted in `biolumCyan`.
- Each level shows the number of captured failles as an indicator.
- Switching levels changes the displayed map grid to the corresponding level's map.
- Resources and HQ status remain visible regardless of which level is displayed (shared economy).

---

### US-8: Rename Siphoner to Abyss Admiral

**As a** developer maintaining consistency between design and code,
**I want to** rename the `siphoner` unit type to `abyssAdmiral`,
**So that** the codebase matches the game design.

**Acceptance criteria:**
- `UnitType.siphoner` is renamed to `UnitType.abyssAdmiral` throughout the codebase.
- Display name updated to "Amiral des Abysses" in French UI strings.
- Stats changes (HP: 100, ATK: 0, DEF: 0).
- Hive persistence handles migration from old saved games (typeId remains the same).
- All references in tests, actions, and UI are updated.

---

### US-9: Transition base visual states on the map

**As a** player viewing the map,
**I want to** see the status of transition bases at a glance,
**So that** I can quickly assess my progression.

**Acceptance criteria:**
- **Undiscovered**: normal fog of war tile.
- **Discovered, not captured**: rift icon with red pulsing glow + danger halo.
- **Captured**: rift icon with cyan glow.

---

## 3. Resolved Design Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Level 3 content | Out of scope | Deferred to PRD Step 12 (Fin de partie). This spec only enables descent to Level 3. |
| Unit recall (ascent) | No — one-way only | Descent is a permanent commitment. Creates strategic tension around which units to send. |
| Boss stat balancing | Keep as-is | Stats from transition.md are used as baseline. Tuning will happen via playtesting. |
| AI faction interaction | Skipped | No AI system exists yet. Will be addressed when AI factions are implemented. |
| Level 2 base | No separate base | The captured faille serves as the entry point. Resources are shared globally. Units are sent from Level 1 base → faille → Level 2. Same pattern for Level 2 → 3. |

---

## 4. Testing and Validation

### Unit tests

- **Map generation**: verify transition base count, placement constraints (quadrant distribution, minimum spacing, edge distance), and `CellContentType.transitionBase` assignment.
- **Boss combat setup**: verify guardian armies are correctly assembled with proper stats and `isBoss` flags.
- **Capture logic**: verify all 3 outcomes (victory+admiral alive → capture, victory+admiral dead → no capture, defeat → army lost + guardians reform).
- **Descent action**: verify new level generation, unit transfer, spawn point placement, and one-way constraint.
- **Reinforcement transit**: verify 1-turn delay, unit unavailability during transit, arrival at spawn point.
- **Building costs**: verify `descentModule` and `pressureCapsule` resource costs and single-build constraint.
- **Unit rename**: verify `abyssAdmiral` enum works throughout the system with no regressions.
- **Hive migration**: verify old saves with `siphoner` load correctly as `abyssAdmiral`.

### Integration tests

- **Full assault flow**: discover faille → build module → send army with admiral → win → capture → descend → explore Level 2.
- **Failed assault recovery**: send army without enough strength → lose → verify guardians reform → retry.
- **Multi-level resource sharing**: produce on Level 1 → spend on Level 2 recruitment prerequisites → verify global stock consistency.
- **Reinforcement pipeline**: send reinforcements → advance turn → verify arrival on lower level.

### Manual / visual tests

- **Map rendering**: verify transition base icons in all 3 visual states (fog, discovered, captured).
- **Bottom sheet**: verify both uncaptured and captured states display correctly.
- **Level selector**: verify switching between levels, locked state display, capture count indicators.
- **Descent dialog**: verify unit selection UI and animation flow.

### Test tools

- Flutter test framework for unit and widget tests.
- `flutter analyze` for static analysis (zero warnings policy).

---

> You can launch `/plan-project transition` to plan the different tasks now or later.
