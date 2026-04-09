# Task 08 — "Bouclier de la base" badge in Army tab and HQ sheet

## Summary

Display a synthetic summary of the current Coral Citadel bonus in two places:
1. The **Army tab** (header above the unit list).
2. The **HQ building detail sheet** (under the description, next to existing HQ info).

Both call-sites reuse the same small stateless widget `BaseShieldBadge` to ensure consistency.

## Implementation steps

1. **Create** `lib/presentation/widgets/building/base_shield_badge.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import '../../../domain/building/building.dart';
   import '../../../domain/building/building_type.dart';
   import '../../../domain/building/coral_citadel_defense_bonus.dart';
   import '../../theme/abyss_colors.dart';

   /// Synthetic "Bouclier de la base : +X%" badge. Hidden when the Citadel
   /// has not yet been built (level 0).
   class BaseShieldBadge extends StatelessWidget {
     final Map<BuildingType, Building> buildings;
     const BaseShieldBadge({super.key, required this.buildings});

     @override
     Widget build(BuildContext context) {
       final level = buildings[BuildingType.coralCitadel]?.level ?? 0;
       if (level == 0) return const SizedBox.shrink();
       final label = CoralCitadelDefenseBonus.bonusLabel(level);
       return Container(
         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
         decoration: BoxDecoration(
           color: AbyssColors.surfaceDim,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: AbyssColors.coralPink, width: 1),
         ),
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Icon(Icons.shield, size: 16, color: AbyssColors.coralPink),
             const SizedBox(width: 8),
             Text(
               'Bouclier de la base : $label',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
           ],
         ),
       );
     }
   }
   ```
   - Keep the file under 100 lines.
   - The widget is a pure function of `buildings`, so it can be dropped into any parent that already owns the player's buildings map.

2. **Edit** `lib/presentation/widgets/unit/army_list_view.dart`
   - Add a new **required** parameter `required Map<BuildingType, Building> buildings`.
   - Replace the bare `ListView.builder` with a `Column` whose first child is the `BaseShieldBadge(buildings: buildings)` and whose `Expanded` second child is the existing list. Example:
     ```dart
     return Column(
       children: [
         BaseShieldBadge(buildings: buildings),
         Expanded(child: ListView.builder(...)),
       ],
     );
     ```
   - Keep the file under 150 lines (currently 48; will become ~70).

3. **Edit** `lib/presentation/screens/game/game_screen.dart`
   - In `_buildTabContent` branch `2 => ArmyListView(...)`, pass the new `buildings: human.buildings` argument.

4. **Edit** `lib/presentation/widgets/building/building_detail_sheet.dart`
   - Import `BaseShieldBadge` and `BuildingType`.
   - You also need the `allBuildings` map — it is already passed into the sheet. Under the branch that handles `coralCitadel` (added in task 07), do **not** add the badge (the Citadel sheet already shows the same info in detail).
   - When the current building is `BuildingType.headquarters`, inject the badge between the description and the divider:
     ```dart
     if (building.type == BuildingType.headquarters) ...[
       const SizedBox(height: 8),
       BaseShieldBadge(buildings: allBuildings),
     ],
     ```
   - Keep the file under 150 lines. If the conditional blocks push it over, extract an inline helper method `_typeSpecificSection(Building, Map)` that returns the right child — stay in the same file.

## Files touched

- `lib/presentation/widgets/building/base_shield_badge.dart` (new)
- `lib/presentation/widgets/unit/army_list_view.dart` (modified, new required param)
- `lib/presentation/screens/game/game_screen.dart` (modified, pass buildings)
- `lib/presentation/widgets/building/building_detail_sheet.dart` (modified)

## Dependencies

- **Internal**:
  - Task 01 (enum), task 03 (bonus helper), task 05 (extensions).
  - Task 07 can land before or after this task; they both touch `building_detail_sheet.dart`, so merge order matters if they run in parallel. Default landing order: 07 before 08 (avoid the merge conflict).
- **External**: none.

## Test plan

1. **`test/presentation/widgets/building/base_shield_badge_test.dart`** (new)
   - Level 0 → widget renders `SizedBox.shrink()` (assert zero text matches).
   - Level 3 → widget renders `Bouclier de la base : +60%`.
   - Level 5 → renders `Bouclier de la base : +100%`.

2. **`test/presentation/widgets/unit/army_list_view_test.dart`** (extend or create)
   - With Citadel level 0 → no shield badge in the tree.
   - With Citadel level 2 → one `BaseShieldBadge` above the unit cards, content `+40%`.

3. **`test/presentation/widgets/building/building_detail_sheet_test.dart`** (extend)
   - Opening the HQ sheet with Citadel level 4 shows the badge `+80%`.
   - Opening the HQ sheet with Citadel level 0 shows no badge.
   - Opening any other non-HQ, non-Citadel sheet shows no badge.

4. Run `flutter test test/presentation/` — entire presentation suite must be green.

## Notes

- The badge is intentionally low-visual-cost (small row, no heavy decoration) — the star of the SPEC is the building SVG, not the badge.
- The badge uses `AbyssColors.coralPink` on purpose to visually connect to the Citadel's color language.
- Do **not** show the dormant mention in the badge — the SPEC requires it only on the detail sheet (task 07). The badge is a raw stat readout.
- `ArmyListView`'s new required parameter is a breaking change for every call site — `game_screen.dart` is the only one in production code; grep for other usages before merging.
