# Task 06 — Update architecture documentation

## Summary

Reflect the new `CollectTreasureResult` and `ResourceGainDialog`, plus the rebalanced ruins reward table, in the architecture docs.

## Implementation Steps

1. **Edit `specs/architecture/domain/action/README.md`**

2. **Update the `CollectTreasureAction` section**
   - Mention that `execute` now returns a `CollectTreasureResult` (a subclass of `ActionResult`) carrying the per-resource delta actually applied (post-clamp at `maxStorage`).
   - Update the reward table for `ruins`:

     | Content type     | Reward roll                                                  |
     |------------------|--------------------------------------------------------------|
     | `resourceBonus`  | algae 50-100, coral 30-50, ore 30-50 (no pearl)              |
     | `ruins`          | algae 0-100, coral 0-25, ore 0-25, pearl 0-2                 |

3. **Add `CollectTreasureResult` to the file map**
   - Add an entry under `## ActionResult` (or below it) that names `collect_treasure_result.dart` and one-line describes it as: *Sub-class of `ActionResult` returned by `CollectTreasureAction`. Carries `Map<ResourceType, int> deltas` so the presentation layer can show what was gained.*
   - Add the row to the file map table at the bottom.

4. **Edit `specs/architecture/presentation/widgets/README.md`**

5. **Update the Resource Widgets table**
   - Add a row for `ResourceGainDialog`:

     | `ResourceGainDialog` | Modal dialog showing a list of resources gained (icon + `+amount`) after collecting a treasure or ruins. Shows an empty message when all deltas are zero. |

6. **Update the Map Widgets table**
   - Update the `TreasureSheet` row to mention that on collect, the sheet closes and a `ResourceGainDialog` is opened by `game_screen_map_actions.dart` with the per-resource deltas returned by `CollectTreasureAction`.

## Dependencies

- Tasks 01–05 (the architecture must describe what was actually built).

## Test Plan

- No code tests; manually re-read both READMEs and confirm:
  - The reward table in `domain/action/README.md` matches the SPEC ruins ranges.
  - `CollectTreasureResult` is mentioned exactly once and named correctly.
  - `ResourceGainDialog` appears in the `Resource Widgets` table.

## Notes

- Keep wording terse — these READMEs are reference docs, not tutorials.
- If you add new files, also add them to the file map at the bottom of the action README (`collect_treasure_result.dart` row).
