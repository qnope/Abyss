# Unit Domain

## Unit Types

`UnitType` is a Hive-persisted enum with six values:

| Type         | Role          | HP | ATK | DEF | Unlock (barracks level) |
|--------------|---------------|----|-----|-----|-------------------------|
| scout        | Recon         | 10 |  2  |  1  | 1                       |
| harpoonist   | Ranged DPS    | 15 |  5  |  2  | 1                       |
| guardian      | Tank          | 25 |  2  |  6  | 3                       |
| domeBreaker  | Siege         | 20 |  8  |  3  | 3                       |
| siphoner     | Resource raid | 12 |  3  |  2  | 5                       |
| saboteur     | Glass cannon  | 8  | 10  |  1  | 5                       |

## Unit

Hive-persisted class representing a group of units of the same type. Units are count-based, not individual.

| Field  | Type     | Description                 |
|--------|----------|-----------------------------|
| `type` | UnitType | The kind of unit            |
| `count`| int      | Number of units (default 0) |

## UnitStats

Value object with `hp`, `atk`, and `def` fields. The static factory `UnitStats.forType(type)` returns the stats for each unit type (see table above).

## UnitCostCalculator

Instance-method utility for recruitment economics:

- **`recruitmentCost(type)`** -- per-unit resource cost. Basic units cost algae/coral; advanced units add ore, energy, or pearls.
- **`maintenanceCost(type)`** -- per-unit per-turn algae upkeep (1-3 algae depending on type).
- **`unlockLevel(type)`** -- minimum barracks level required: 1 for scout/harpoonist, 3 for guardian/domeBreaker, 5 for siphoner/saboteur.
- **`isUnlocked(type, barracksLevel)`** -- checks barracks level against `unlockLevel`.
- **`maxRecruitableCount(type, barracksLevel, resources)`** -- returns the maximum affordable count, capped at `barracksLevel * 100`.

## UnitLossCalculator

Static utility that computes starvation losses when algae is insufficient.

- Compares total unit algae consumption against `algaeProduction + algaeStock`.
- When there is a deficit, a `lossRatio` (deficit / total consumption) is computed.
- Each unit type loses `ceil(count * lossRatio)` units, capped at its current count.
- Returns an empty map when supply meets or exceeds consumption.
