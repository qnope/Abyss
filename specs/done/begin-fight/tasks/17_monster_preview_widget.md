# Task 17 - MonsterPreview widget

## Summary

Small widget that summarizes the lair the player is about to fight:
difficulty SVG, level, unit count, per-unit stats. Shown at the top
of the army selection screen and reused on the fight summary screen.

## Implementation steps

1. Create `lib/presentation/widgets/fight/monster_preview.dart`:
   - Stateless widget `MonsterPreview` with constructor
     `MonsterPreview({required this.lair})`.
   - Layout: a `Card` (or themed `Container`) with:
     - Top row: difficulty SVG (use the existing
       `MonsterDifficulty.svgPath` extension) + difficulty label.
     - Subtitle: 'Niveau ${lair.level}' + 'Unités: ${lair.unitCount}'.
     - Stats row: 'PV: $hp'  'ATK: $atk'  'DEF: $def' from
       `MonsterUnitStats.forLevel(lair.level)`.
   - Use `AbyssColors` for accents and `AbyssTheme` text styles.

## Dependencies

- **Internal**: `MonsterLair` (Task 01), `MonsterUnitStats` (Task 03),
  `MonsterDifficulty` extension (existing svgPath/label),
  `AbyssTheme` / `AbyssColors`.
- **External**: `flutter_svg`.

## Test plan

- New `test/presentation/widgets/fight/monster_preview_test.dart`:
  - Renders the difficulty label, level, unit count.
  - Renders the per-level stats: for `MonsterDifficulty.medium`,
    expects `PV 20`, `ATK 4`, `DEF 2`.
  - Mock SVG assets via the existing helper.

## Notes

- File target: < 120 lines.
- No state.
