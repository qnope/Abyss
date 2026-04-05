# Army System — Architecture

## Overview

The army system lets the player recruit military units from a barracks. Six unit types are available, each with unique stats, costs, and barracks-level requirements. Recruitment is instantaneous but limited to one action per unit type per turn.

## Domain Model

```
UnitType (enum, Hive typeId: 8)
  scout | harpoonist | guardian | domeBreaker | siphoner | saboteur

UnitStats (immutable)
  ├── hp: int
  ├── attack: int
  └── defense: int
  └── forType(UnitType) → UnitStats

Unit (HiveObject, typeId: 9)
  ├── type: UnitType
  └── count: int            (mutable)

UnitCostCalculator (stateless)
  ├── recruitmentCost(UnitType) → Map<ResourceType, int>
  ├── maintenanceCost(UnitType) → Map<ResourceType, int>
  ├── unlockLevel(UnitType) → int
  ├── isUnlocked(UnitType, barracksLevel) → bool
  └── maxRecruitableCount(UnitType, barracksLevel, resources) → int

Game
  ├── units: Map<UnitType, Unit>
  └── recruitedUnitTypes: List<UnitType>    ← reset each turn
```

## Units

| Unit | HP | ATK | DEF | Unlock | Cost | Maintenance |
|------|---:|----:|----:|--------|------|-------------|
| Scout | 10 | 2 | 1 | Barracks 1 | 10 algae, 5 coral | 1 algae/turn |
| Harpoonist | 15 | 5 | 2 | Barracks 1 | 15 algae, 10 coral, 5 ore | 2 algae/turn |
| Guardian | 25 | 2 | 6 | Barracks 3 | 20 coral, 15 ore | 3 algae/turn |
| Dome Breaker | 20 | 8 | 3 | Barracks 3 | 25 ore, 15 energy | 2 algae/turn |
| Siphoner | 12 | 3 | 2 | Barracks 5 | 20 algae, 10 energy, 2 pearls | 3 algae/turn |
| Saboteur | 8 | 10 | 1 | Barracks 5 | 15 coral, 20 energy, 3 pearls | 2 algae/turn |

## Recruitment Flow

1. Player opens Army tab → sees 6 `UnitCard` (locked ones greyed out)
2. Taps a card → `UnitDetailSheet` opens with stats and `RecruitmentSection`
3. Slider selects quantity (1 to `maxRecruitableCount`)
4. On recruit: `RecruitUnitAction` + `ActionExecutor` handle validation and mutation
5. `setState` refreshes `ArmyListView` and `ResourceBar`

### Max Recruitable Formula

```
maxRecruitableCount = min(
  barracksLevel * 100,
  floor(min(playerResource / unitCost for each resource))
)
```

### Per-Turn Limit

`recruitedUnitTypes` tracks which unit types have been recruited this turn. `TurnResolver` resets this list on turn resolution. A unit type that's already in the list cannot be recruited again until next turn.

## Presentation Layer

```
UnitTypeExtensions
  ├── UnitTypeColor  → color mapping
  └── UnitTypeInfo   → displayName, role, iconPath

Widgets
  ├── UnitIcon          → SVG with greyscale when locked
  ├── UnitCard          → icon + name + count, dimmed when locked
  ├── ArmyListView      → scrollable list of UnitCard
  ├── UnitDetailSheet   → modal bottom sheet with stats + recruitment
  └── RecruitmentSection → slider + recruit button
```

## Design Decisions

1. **Mirrors building pattern** — Same widget decomposition (Icon → Card → ListView → DetailSheet → ActionSection) for consistency.
2. **Per-type-per-turn limit via List** — Uses `List<UnitType>` instead of `Set` due to Hive serialization constraints.
3. **Stateless calculator** — `UnitCostCalculator` has no dependencies, same pattern as `BuildingCostCalculator`.
4. **Instant recruitment** — Resources deducted immediately, no queue. Keeps the turn-based flow simple.
5. **Barracks as gate** — Unit unlock tiers are tied to barracks level, creating a natural progression.

## File Structure

```
lib/domain/
  ├── unit_type.dart
  ├── unit_stats.dart
  ├── unit.dart
  ├── unit_cost_calculator.dart
  └── recruit_unit_action.dart
lib/presentation/
  ├── extensions/unit_type_extensions.dart
  └── widgets/
        ├── unit_icon.dart
        ├── unit_card.dart
        ├── army_list_view.dart
        ├── unit_detail_sheet.dart
        └── recruitment_section.dart
test/domain/
  ├── unit_type_test.dart
  ├── unit_stats_test.dart
  ├── unit_test.dart
  ├── unit_cost_calculator_test.dart
  └── recruit_unit_action_test.dart
test/presentation/widgets/
  ├── unit_icon_test.dart
  ├── unit_card_test.dart
  ├── army_list_view_test.dart
  ├── unit_detail_sheet_test.dart
  └── recruitment_section_test.dart
```
