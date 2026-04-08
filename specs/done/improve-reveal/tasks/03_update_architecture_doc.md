# Task 3 — Update the map module architecture doc

## Summary
Bring the map module's architecture documentation in sync with the new
reveal-area behavior delivered by Tasks 1 and 2. The doc currently advertises
the even/odd dual mode and the old level→side table; both must be replaced.

## Implementation steps

### 3.1 — Rewrite the `RevealAreaCalculator` paragraph and table
File: `specs/architecture/domain/map/README.md`

In the `## Exploration` section, locate the `RevealAreaCalculator` bullet:

> Computes which cells are revealed based on Explorer tech level. Even-sized
> squares anchor the target at bottom-left; odd-sized squares center on the
> target.

Replace it with text describing the new invariant:

> Computes which cells are revealed based on Explorer tech level. **All
> sides are odd**, so the target cell is always exactly at the center of the
> revealed square. When the square overflows the grid, out-of-bounds cells
> are simply skipped (no shifting).

Replace the level→side table with the new progression:

| Explorer Level | Square Side | Cells Revealed |
|----------------|-------------|----------------|
| 0              | 3           | 9              |
| 1              | 3           | 9              |
| 2              | 5           | 25             |
| 3              | 5           | 25             |
| 4              | 7           | 49             |
| 5              | 9           | 81             |

### 3.2 — Refresh the "Fog of War (per-player)" paragraph
Same file. The paragraph currently says:

> When a new player is built via `Player.withBase`, the initial reveal window
> is seeded via `RevealAreaCalculator` at Explorer level 0 centered on the
> base.

Update it to reflect the new initialization:

> When a new player is built via `Player.withBase`, the initial reveal window
> is seeded via `RevealAreaCalculator` at Explorer level 2 (a 5x5 square)
> centered on the base. This is a deliberate choice so the player can orient
> themselves in every direction from the very first turn; it is independent
> of the explorer tech level the player actually owns.

### 3.3 — Sanity check the rest of the file
Same file. Skim the document for any other references to "2x2", "even-sized
squares", "bottom-left", or the old table. Update or delete anything that
contradicts the new model. The `## Files` table at the bottom does not need
to change.

## Dependencies
- **Internal:** depends on **Task 1** and **Task 2** — the doc should
  describe the shipped behavior, so the code changes must already be in
  place (or at least decided) before this task is reviewed.
- **External:** none.

## Test plan
- This task changes only Markdown, so there is nothing to run with
  `flutter test`.
- Verify visually that the new table renders correctly and that no stale
  numbers remain by re-reading the file end-to-end after the edits.
- Run `flutter analyze` once more to confirm nothing else has slipped.

## Notes / design considerations
- Keep the doc concise and consistent with the rest of `specs/architecture/`
  — the existing tone is descriptive, not prescriptive.
- Do not duplicate the table elsewhere (e.g. inside the project SPEC). The
  architecture doc is the single source of truth for the cell counts.
