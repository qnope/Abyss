# Task 07 — Defense bonus + dormant notice in the building detail sheet

## Summary

When the player opens the detail sheet for a Coral Citadel, the sheet must show:
- Current DEF bonus (e.g. `+60% DEF en défense`).
- Next-level bonus (e.g. `Prochain niveau : +80% DEF`).
- A "dormant effect" notice explaining the bonus is stocked but not yet consumed.

For every other building, the sheet behavior stays identical.

## Implementation steps

1. **Create a small dedicated section widget**: `lib/presentation/widgets/building/coral_citadel_info_section.dart` (new file, ≤ 100 lines).

   Responsibilities:
   - Take a `Building` (assumed to be of type `coralCitadel`).
   - Render three text rows:
     1. `Bonus DEF actuel : {bonusLabel}` — use `CoralCitadelDefenseBonus.bonusLabel(building.level)`. Grey it out (via `AbyssColors.disabled`) when level == 0.
     2. `Prochain niveau : {bonusLabel(level+1)}` — only shown when not at max level. When at max level, show `Bouclier à son apogée`.
     3. Dormant notice row: an `Icon(Icons.schedule)` + text `"Effet dormant — en attente du système d'attaque de base"`, with `AbyssColors.onSurfaceDim` color.
   - Layout: a `Column` with `crossAxisAlignment: CrossAxisAlignment.start`, small vertical spacing, wrapped by a `Padding` so it slots cleanly into the existing sheet.

   Example skeleton:
   ```dart
   import 'package:flutter/material.dart';
   import '../../../domain/building/building.dart';
   import '../../../domain/building/building_cost_calculator.dart';
   import '../../../domain/building/coral_citadel_defense_bonus.dart';
   import '../../theme/abyss_colors.dart';

   class CoralCitadelInfoSection extends StatelessWidget {
     final Building building;
     const CoralCitadelInfoSection({super.key, required this.building});

     @override
     Widget build(BuildContext context) {
       final textTheme = Theme.of(context).textTheme;
       final level = building.level;
       final current = CoralCitadelDefenseBonus.bonusLabel(level);
       final maxLevel = BuildingCostCalculator().maxLevel(building.type);
       final next = level < maxLevel
           ? CoralCitadelDefenseBonus.bonusLabel(level + 1)
           : null;
       // ... render three rows
     }
   }
   ```

2. **Edit** `lib/presentation/widgets/building/building_detail_sheet.dart`
   - Import the new section.
   - Between the `Text(building.type.description, ...)` and the existing `Divider(height: 24)`, add:
     ```dart
     if (building.type == BuildingType.coralCitadel) ...[
       const SizedBox(height: 12),
       CoralCitadelInfoSection(building: building),
     ],
     ```
   - Keep the file under 150 lines (currently 89; will become ~95).

3. **Do not touch `UpgradeSection`** — the existing cost / prereq rendering already works for the Citadel because task 02 made `BuildingCostCalculator` return the right values (including pearls). Pearls will render via the existing `_costRow` iteration because `ResourceIcon` and `ResourceType.displayName` already handle `pearl` (verify by grep before starting; if pearl is missing from either, that is a scope-creep bug to file separately — **do not** expand this task).

## Files touched

- `lib/presentation/widgets/building/coral_citadel_info_section.dart` (new)
- `lib/presentation/widgets/building/building_detail_sheet.dart` (modified)

## Dependencies

- **Internal**:
  - Task 01 (enum).
  - Task 02 (costs / max level).
  - Task 03 (`CoralCitadelDefenseBonus`).
  - Task 05 (display name / description — no direct code dep, but the sheet looks broken without it).
  - Task 06 (SVG — the icon at the top of the sheet is rendered by `BuildingIcon`).
- **External**: none.

## Test plan

Add `test/presentation/widgets/building/coral_citadel_info_section_test.dart`:

1. **Level 0** — renders `"Bonus DEF actuel : aucun"`, `"Prochain niveau : +20%"`, and the dormant notice text.
2. **Level 3** — renders `"Bonus DEF actuel : +60%"` and `"Prochain niveau : +80%"`.
3. **Max level (5)** — renders `"Bonus DEF actuel : +100%"`, `"Bouclier à son apogée"`, and the dormant notice.
4. **Dormant notice always present** — assert `find.byIcon(Icons.schedule)` returns one widget regardless of level.

Add one integration-ish widget test in `test/presentation/widgets/building/building_detail_sheet_test.dart` (or extend the file if it already exists):
- Build a `MaterialApp` hosting `showBuildingDetailSheet` for a Coral Citadel.
- Verify the `CoralCitadelInfoSection` rows appear alongside the existing upgrade button.
- Verify that for a non-citadel building, the section does NOT appear.

Run `flutter test test/presentation/widgets/building/`.

## Notes

- Keep the section **stateless and widget-level**. Do not route anything through the game layer — the helpers in task 03 are pure.
- Do not localize further than the rest of the UI: all text in French, matching `displayName` style.
- Do not gate the dormant notice on a feature flag or future branch condition: the SPEC says it must stay visible until the base-attack system lands, which is an explicit future feature.
- Accessibility: wrap the dormant text in a `Semantics(label: ...)` if the text inside `Row` proves awkward for screen readers — but don't over-engineer this; matching existing sheet style is fine.
