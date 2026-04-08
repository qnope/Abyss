# Task 08 — Update architecture documentation

## Summary

Reflect the four spec changes in `specs/architecture/`:

1. **`domain/fight/README.md`** — `CombatantBuilder.playerCombatantsFrom`
   gains a `militaryResearchLevel` parameter.
2. **`domain/action/README.md`** — `FightMonsterAction.execute` now
   restores intact survivors **and** wounded; reads the player's
   military level. `FightMonsterHelpers.restoreWounded` is renamed
   to `restoreToStock`.
3. **`presentation/widgets/README.md`** — document the new
   `SelectionSummaryCard` widget and the `Slider` added to
   `UnitQuantityRow`.
4. **`presentation/screens/README.md`** — document the new
   `ArmySelectionScreen` body layout (rows + summary card).

## Files

- `specs/architecture/domain/fight/README.md`
- `specs/architecture/domain/action/README.md`
- `specs/architecture/presentation/widgets/README.md`
- `specs/architecture/presentation/screens/README.md`

## Implementation steps

1. **fight/README.md**:
   - In the "CombatantBuilder" bullet under "Calculators and helpers",
     update the description to:
     `playerCombatantsFrom(Map<UnitType, int>, {int militaryResearchLevel = 0})`
     reads `UnitStats` and applies a `+20% / level` multiplier on
     `atk` (formula `(atk * (1 + 0.20 * level)).round()`). The
     `monsterCombatantsFrom` path is unaffected.
2. **action/README.md**:
   - Under "Execution flow" of `FightMonsterAction`, update step 1 to
     mention that the player combatants are built with the player's
     `techBranches[military].researchLevel` (or `0` if missing /
     locked).
   - Update step 6 to read: "Restore both `alive` (intact survivors)
     and `split.wounded` to player stocks via
     `FightMonsterHelpers.restoreToStock`."
   - Update the `FightMonsterHelpers` line in the file map: rename
     `restoreWounded` → `restoreToStock`, generic restore.
3. **presentation/widgets/README.md**:
   - Add `selection_summary_card.dart` to the fight widget table
     with the description: "Reusable card showing total ATK/DEF of a
     selection plus the active military bonus label."
   - Update the `unit_quantity_row.dart` line to mention the embedded
     `Slider` synced with the `+/-` buttons.
4. **presentation/screens/README.md**:
   - In the `ArmySelectionScreen` paragraph (or table row), mention
     that the body now stacks: monster preview → per-unit rows
     (slider + buttons) → `SelectionSummaryCard` → launch row.

## Test plan

Documentation only — no automated test. After editing, ensure:
- `flutter analyze` still clean (touches no Dart code).
- The Dependency.md `Dependencies` section of this project still lines
  up with the listed task numbers.

## Dependencies

- Internal: tasks 01-06 (the actual code changes).
- External: none.
- Blocks: task 09 (final analyze/test sweep).

## Notes

- Keep the doc edits **minimal**. Don't rewrite paragraphs that are
  unaffected by the spec.
- Do not add ASCII diagrams unless one would replace something
  already in place — see CLAUDE.md "Don't add… beyond what was
  asked".
