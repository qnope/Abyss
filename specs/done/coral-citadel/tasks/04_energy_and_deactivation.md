# Task 04 — Energy consumption & deactivation priority

## Summary

Plug the Coral Citadel into the energy economy:
- Consumes `1 × level` energy per turn (same baseline as a solar panel, light drain).
- Is **deactivated last** in an energy shortage (just above the HQ, which is never deactivated).

## Implementation steps

1. **Edit** `lib/domain/resource/consumption_calculator.dart`
   - In `buildingEnergyConsumption`, add:
     ```dart
     BuildingType.coralCitadel => 1 * level,
     ```
   - Keep the early `if (level == 0) return 0;` guard. Order the case near `solarPanel` for readability.

2. **Edit** `lib/domain/building/building_deactivator.dart`
   - Update the `_priority` list so `coralCitadel` sits **just above** `headquarters` — meaning it's the *last* building to be deactivated among the deactivatable ones.
   - New ordering:
     ```dart
     static const List<BuildingType> _priority = [
       BuildingType.headquarters,  // 0 — never disabled
       BuildingType.coralCitadel,  // 1 — last to be disabled
       BuildingType.solarPanel,    // 2
       BuildingType.barracks,      // 3
       BuildingType.laboratory,    // 4
       BuildingType.algaeFarm,     // 5
       BuildingType.coralMine,     // 6
       BuildingType.oreExtractor,  // 7 — disabled first
     ];
     ```
   - No logic change is required: the loop `for (var i = _priority.length - 1; i > 0; i--)` already deactivates from highest index downwards and stops at index 1, so index 1 = Citadel is deactivated only if *all* other buildings have been shut down and there is still a deficit.

3. **Update** `specs/architecture/domain/building/README.md` — extend the priority list doc and add a row under *Building Types* for `coralCitadel`. (The rest of the architecture doc update is handled in task 09.)

## Files touched

- `lib/domain/resource/consumption_calculator.dart`
- `lib/domain/building/building_deactivator.dart`
- `specs/architecture/domain/building/README.md` (doc-only)

## Dependencies

- **Internal**: task 01 (enum case must exist for the switch and the list literal to compile).
- **External**: none.

## Test plan

1. **Extend** `test/domain/building/building_deactivator_test.dart`
   - **Citadel is deactivated last**: build a scenario where every building is at level 1 and a big energy deficit requires deactivating everything except HQ — assert that `coralCitadel` ends up in the returned list *last* (i.e. only if other buildings were not enough to close the deficit).
   - **Citadel is spared when possible**: small deficit that can be absorbed by shutting down `oreExtractor` alone — assert `coralCitadel` is **not** in the returned list.
   - **Skipping level-0 Citadel**: scenario with `coralCitadel.level == 0` — the deactivator should not include it (the existing `building.level == 0 continue` guard covers this, but we need an explicit test).

2. **Extend** `test/domain/resource/consumption_calculator_test.dart` (create the file's citadel group if missing)
   - `buildingEnergyConsumption(coralCitadel, 0)` → 0.
   - `buildingEnergyConsumption(coralCitadel, 1)` → 1.
   - `buildingEnergyConsumption(coralCitadel, 5)` → 5.
   - `totalBuildingConsumption` includes the citadel contribution when present.

3. Run `flutter test test/domain/building/` and `flutter test test/domain/resource/` — both directories must be green.

## Notes

- The Citadel does **not** produce any resource: do **not** touch `lib/domain/resource/production_formulas.dart`.
- Priority order matters: index 0 (HQ) is never reached by the loop (`i > 0`), so putting Citadel at index 1 makes it deactivated only after the entire fallback chain has failed.
- Energy cost of `1 × level` matches the user's explicit decision on the planning question (low drain, flavor: the Citadel is mostly self-powered via its defensive crystals).
