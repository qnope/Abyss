# Task 20 - FightSummaryScreen

## Summary

Full-page screen shown after a `FightMonsterAction` resolves. It
displays the result (victory or defeat), the per-unit-type accounting
(sent / intact / wounded / dead), the loot in case of victory, and
the per-turn list. Tapping 'Retour à la carte' pops back to the
game screen.

## Implementation steps

1. Create `lib/presentation/screens/game/fight/fight_summary_screen.dart`:
   - `StatelessWidget` `FightSummaryScreen`.
   - Constructor:
     - `required FightMonsterResult result`
     - `required MonsterLair lair`
     - `required int targetX`
     - `required int targetY`
   - Build:
     - `AppBar` titled 'Combat ($targetX, $targetY)'.
     - Body in a `ListView`:
       1. Big result banner: 'VICTOIRE' (cyan) or 'DÉFAITE' (warning).
          Shows 'Combat en ${result.fight!.turnCount} tours'.
       2. `MonsterPreview(lair: lair)` (reused from Task 17) so the
          player remembers what they fought.
       3. **Player accounting section**: for each `UnitType` present
          in `result.sent`, a row showing:
          'Envoyés: $sent / Intactes: $intact / Blessés: $wounded / Morts: $dead'.
          Use `UnitIcon` for the leading icon.
       4. **Monster section**: 'Ennemis tués: ${initial - finalCount}/${initial}'.
       5. **Loot section** (only on victory): list each
          `ResourceType` with a non-zero delta as
          `<icon> +amount`. Reuse `ResourceIcon` if available.
       6. `FightTurnList(summaries: result.fight!.turnSummaries)`
          (Task 19).
       7. Bottom 'Retour à la carte' `ElevatedButton` calling
          `Navigator.of(context).pop()`.

2. Keep the screen under 150 lines. Extract sections into private
   helpers (`_buildHeader`, `_buildPlayerAccounting`, `_buildLoot`)
   in a sibling file
   `lib/presentation/screens/game/fight/fight_summary_screen_sections.dart`
   if the main file gets too long.

## Dependencies

- **Internal**: `FightMonsterResult` (Task 13), `MonsterLair`
  (Task 01), `MonsterPreview` (Task 17), `FightTurnList` (Task 19),
  existing `UnitIcon`, `ResourceIcon`, `AbyssTheme`, `AbyssColors`.
- **External**: Flutter Material.

## Test plan

- New `test/presentation/screens/game/fight/fight_summary_screen_test.dart`:
  - Renders 'VICTOIRE' when `result.victory == true` and the loot
    section is visible.
  - Renders 'DÉFAITE' when victory is false; loot section is absent.
  - Player accounting rows match the maps in `result`.
  - 'Retour à la carte' button pops the route.
  - Mock SVG assets.

## Notes

- File target: < 150 lines.
- The screen is purely a presentation surface; no domain mutation.
- No `initialize()`.
