# Task 19 - FightTurnList widget

## Summary

Reusable scrollable widget that renders the per-turn summaries from
a `FightResult`. Displayed on the fight summary screen so the player
can read what happened on each round.

## Implementation steps

1. Create `lib/presentation/widgets/fight/fight_turn_list.dart`:
   - Stateless widget `FightTurnList` with constructor
     `FightTurnList({required this.summaries})` taking a
     `List<FightTurnSummary>`.
   - Layout: bounded `ListView.separated`:
     - For each summary, a tile showing:
       - Title 'Tour ${turnNumber}'.
       - Two columns of stats:
         - Left: 'Alliés vivants: ${playerAliveAtEnd}',
                 'PV alliés: ${playerHpAtEnd}',
                 'Dégâts infligés: ${damageDealtByPlayer}'.
         - Right: 'Ennemis vivants: ${monsterAliveAtEnd}',
                  'PV ennemis: ${monsterHpAtEnd}',
                  'Dégâts subis: ${damageDealtByMonster}'.
       - Optional badge 'Coups critiques: ${critCount}' if > 0.
   - Use `AbyssColors` and theme text styles. Wrap in a `Card` for
     visual separation.

## Dependencies

- **Internal**: `FightTurnSummary` (Task 08), `AbyssTheme` /
  `AbyssColors`.
- **External**: Flutter Material.

## Test plan

- New `test/presentation/widgets/fight/fight_turn_list_test.dart`:
  - Renders one tile per summary.
  - Tile content includes the right values for `playerAliveAtEnd`,
    `monsterAliveAtEnd`, and damage totals.
  - Tile shows the crit badge when `critCount > 0` and hides it
    otherwise.

## Notes

- File target: < 130 lines.
- The widget is shrink-wrapped (`shrinkWrap: true`) and
  `physics: NeverScrollableScrollPhysics` so it can be embedded in
  the parent summary `ListView`.
