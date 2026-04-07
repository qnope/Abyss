# Task 08 — Create MonsterLairSheet widget

## Summary

Create a bottom sheet for monster lair cells showing the monster's difficulty and a "Combat non disponible" message. No action button.

## Implementation Steps

1. **Create `lib/presentation/widgets/map/monster_lair_sheet.dart`**

   - Create `showMonsterLairSheet(BuildContext, {required int targetX, required int targetY, required MonsterDifficulty difficulty})` top-level function
   - Uses `showModalBottomSheet`
   - Internal `_MonsterLairSheet` stateless widget:
     - Monster difficulty SVG icon (64px, centered) — use `difficulty.svgPath`
     - Title: `'Monstre ($targetX, $targetY)'` (headlineSmall, biolumCyan)
     - Info row: `'Difficulté'` → `difficulty.label` ("Facile"/"Moyen"/"Difficile")
     - Divider
     - Warning text: `'Combat non disponible'` (bodyMedium, `AbyssColors.warning`)
     - Padding: `EdgeInsets.fromLTRB(24, 0, 24, 32)`

## Dependencies

- None (standalone widget)

## Test Plan

- **File:** `test/presentation/widgets/map/monster_lair_sheet_test.dart`
- Test: difficulty label is displayed for each difficulty level
- Test: "Combat non disponible" text is displayed
- Test: no action button is present

## Notes

- Uses existing `MonsterDifficultyExtensions` for `label` and `svgPath`.
- Keep under 80 lines.
