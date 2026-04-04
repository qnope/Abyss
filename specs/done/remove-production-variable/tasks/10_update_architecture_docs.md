# Task 10 — Update architecture documentation

## Summary

Update `specs/architecture/resource_system.md` to reflect the removal of `productionPerTurn` and the new dynamic calculation.

## Implementation Steps

### Step 1: Edit `specs/architecture/resource_system.md`

**Domain Model section** — remove `productionPerTurn` line:

```
Resource (HiveObject, typeId: 3)
  +-- type: ResourceType
  +-- amount: int          (mutable -- updated on turn)
  +-- maxStorage: int
```

**Starting Values table** — remove "Production/turn" column:

```
| Resource | Amount | Max storage |
|----------|--------|-------------|
| Algae    | 100    | 500         |
| Coral    | 80     | 500         |
| Ore      | 50     | 500         |
| Energy   | 60     | 500         |
| Pearl    | 5      | 100         |
```

**Design Decisions** — replace decision 3:

```
3. **Dynamic production** — Production per turn is calculated from building levels
   via `ProductionCalculator.fromBuildings()` instead of being stored on `Resource`.
   This avoids sync issues when multiple systems affect production.
```

**File Structure** — add production_calculator:

```
lib/domain/
  +-- resource_type.dart
  +-- resource.dart
  +-- production_calculator.dart   # Dynamic production from buildings
  +-- game.dart
```

## Dependencies

- Task 01 (ProductionCalculator exists)
