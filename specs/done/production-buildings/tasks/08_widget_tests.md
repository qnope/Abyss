# Task 08 — Widget Tests for Production Buildings

## Summary
Add widget tests verifying that BuildingListView displays all 5 buildings and BuildingDetailSheet shows correct costs/prerequisites for production buildings.

## Implementation Steps

### 1. Edit `test/presentation/widgets/building_list_view_test.dart`

Add test:
- `'displays all 5 buildings including production buildings'` — use `Game.defaultBuildings()`, verify all 5 display names appear: 'Quartier Général', 'Ferme d\'algues', 'Mine de corail', 'Extracteur de minerai', 'Panneau solaire'

### 2. Edit `test/presentation/widgets/building_detail_sheet_test.dart`

Update the `_app` helper to accept `allBuildings` parameter (currently hardcodes `{building.type: building}`). This is needed to test prerequisite display with HQ included.

Add tests:
- `'shows costs for algaeFarm level 0->1'` — open detail sheet for algaeFarm at level 0, verify coral cost "200/20" is displayed (using default resources where coral=80... actually adjust resources to make amounts clear)
- `'shows HQ prerequisite for algaeFarm when HQ not built'` — algaeFarm level 0 with HQ level 0, verify "Quartier Général" and "Niv. 1" appear in prerequisite row
- `'upgrade button disabled when HQ prerequisite not met'` — algaeFarm level 0, HQ level 0, sufficient coral → button disabled (because prerequisite not met)
- `'shows max level message for algaeFarm at level 5'` — algaeFarm level 5, verify "Niveau maximum atteint"

### 3. Verify existing tests still pass
All existing BuildingDetailSheet tests use HQ which has no prerequisites — they should be unaffected.

## Dependencies
- Task 01, Task 02, Task 04, Task 05

## Test Plan
- **Files**:
  - `test/presentation/widgets/building_list_view_test.dart`
  - `test/presentation/widgets/building_detail_sheet_test.dart`
- 5 new widget tests total.
